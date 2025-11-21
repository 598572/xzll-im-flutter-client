import 'dart:convert';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_info.dart';
import '../api/user_api.dart';

/// 用户信息缓存服务
/// 实现好友信息本地缓存 + 服务端兜底的混合策略
class UserCacheService {
  static UserCacheService? _instance;
  static UserCacheService get instance => _instance ??= UserCacheService._();
  
  UserCacheService._();
  
  Database? _database;
  SharedPreferences? _prefs;
  
  // 内存缓存，提供最快访问速度
  final Map<String, UserInfo> _memoryCache = {};
  
  /// 初始化缓存服务
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
    
    // 加载好友信息到内存缓存
    await _loadFriendsToMemory();
    
    log('UserCacheService initialized');
  }
  
  /// 初始化SQLite数据库
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'user_cache.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // 好友信息表
        await db.execute('''
          CREATE TABLE friends (
            user_id TEXT PRIMARY KEY,
            user_name TEXT,
            user_full_name TEXT,
            head_image TEXT,
            sex INTEGER,
            last_update INTEGER,
            is_friend INTEGER DEFAULT 1
          )
        ''');
        
        // 临时用户信息表（非好友）
        await db.execute('''
          CREATE TABLE temp_users (
            user_id TEXT PRIMARY KEY,
            user_name TEXT,
            user_full_name TEXT,
            head_image TEXT,
            sex INTEGER,
            last_update INTEGER,
            expire_time INTEGER
          )
        ''');
        
        log('UserCache database created');
      },
    );
  }
  
  /// 从好友列表更新缓存（主要数据源）
  Future<void> updateFriendsCache(List<UserInfo> friends) async {
    if (_database == null) return;
    
    final batch = _database!.batch();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // 批量更新好友信息
    for (final friend in friends) {
      batch.insert(
        'friends',
        {
          'user_id': friend.userId,
          'user_name': friend.userName,
          'user_full_name': friend.userFullName,
          'head_image': friend.headImage,
          'sex': friend.sex,
          'last_update': currentTime,
          'is_friend': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      
      // 同时更新内存缓存
      _memoryCache[friend.userId] = friend;
    }
    
    await batch.commit(noResult: true);
    
    // 保存最后更新时间
    await _prefs?.setInt('friends_last_update', currentTime);
    
    log('Updated ${friends.length} friends to cache');
  }
  
  /// 获取用户信息（智能缓存策略）
  Future<UserInfo?> getUserInfo(String userId) async {
    if (userId.isEmpty) return null;
    
    // 1. 优先从内存缓存获取
    if (_memoryCache.containsKey(userId)) {
      return _memoryCache[userId];
    }
    
    // 2. 从SQLite好友表查询
    final friendInfo = await _getFriendFromDb(userId);
    if (friendInfo != null) {
      _memoryCache[userId] = friendInfo; // 加载到内存缓存
      return friendInfo;
    }
    
    // 3. 从临时用户表查询（未过期）
    final tempInfo = await _getTempUserFromDb(userId);
    if (tempInfo != null && !_isExpired(tempInfo)) {
      _memoryCache[userId] = tempInfo;
      return tempInfo;
    }
    
    // 4. 缓存未命中，返回null（由上层调用批量查询）
    return null;
  }
  
  /// 批量获取用户信息（高效策略）
  Future<Map<String, UserInfo>> batchGetUserInfo(List<String> userIds) async {
    final result = <String, UserInfo>{};
    final missingIds = <String>[];
    
    // 1. 从缓存中获取已有的用户信息
    for (final userId in userIds) {
      final cachedInfo = await getUserInfo(userId);
      if (cachedInfo != null) {
        result[userId] = cachedInfo;
      } else {
        missingIds.add(userId);
      }
    }
    
    // 2. 批量查询未命中的用户信息
    if (missingIds.isNotEmpty) {
      try {
        final serverUsers = await UserApi.batchGetUserInfo(missingIds);
        
        // 3. 更新临时缓存
        await _updateTempUsersCache(serverUsers);
        
        // 4. 添加到结果中
        for (final user in serverUsers) {
          result[user.userId] = user;
          _memoryCache[user.userId] = user; // 加载到内存缓存
        }
        
        log('Batch fetched ${serverUsers.length} users from server');
      } catch (e) {
        log('Failed to batch fetch users: $e');
      }
    }
    
    return result;
  }
  
  /// 为会话列表构建用户信息映射（使用服务端返回的otherUserId）
  Future<List<ChatItem>> buildChatListWithUserInfo(List<ChatItem> chatList) async {
    // 提取服务端已经解析好的otherUserId
    final userIds = chatList
        .map((chat) => chat.otherUserId)
        .where((id) => id?.isNotEmpty == true)
        .cast<String>()
        .toSet()
        .toList();
    
    if (userIds.isEmpty) return chatList;
    
    // 批量获取用户信息
    final userInfoMap = await batchGetUserInfo(userIds);
    
    // 构建带用户信息的会话列表
    return chatList.map((chat) {
      if (chat.otherUserId != null && userInfoMap.containsKey(chat.otherUserId)) {
        final userInfo = userInfoMap[chat.otherUserId]!;
        return chat.copyWith(
          otherUserName: userInfo.userName,
          otherUserAvatar: userInfo.headImage,
          otherUserFullName: userInfo.userFullName,
        );
      }
      return chat; // 没有找到用户信息，保持原样（服务端可能提供了兜底数据）
    }).toList();
  }
  
  /// 用户信息变更时更新缓存
  Future<void> updateUserInfo(String userId, UserInfo newInfo) async {
    // 更新内存缓存
    _memoryCache[userId] = newInfo;
    
    // 检查是否为好友，决定更新哪个表
    final isFriend = await _isFriend(userId);
    final tableName = isFriend ? 'friends' : 'temp_users';
    
    await _database?.update(
      tableName,
      {
        'user_name': newInfo.userName,
        'user_full_name': newInfo.userFullName,
        'head_image': newInfo.headImage,
        'sex': newInfo.sex,
        'last_update': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    log('Updated user info for $userId');
  }
  
  /// 清理过期缓存
  Future<void> cleanExpiredCache() async {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    
    // 删除过期的临时用户信息
    await _database?.delete(
      'temp_users',
      where: 'expire_time < ?',
      whereArgs: [currentTime],
    );
    
    // 清理内存缓存中的过期数据
    _memoryCache.removeWhere((key, value) {
      // 这里可以添加更复杂的过期逻辑
      return false; // 暂时保留所有内存缓存
    });
    
    log('Cleaned expired cache');
  }
  
  /// 获取缓存统计信息
  Future<Map<String, int>> getCacheStats() async {
    final friendsCount = await _database?.rawQuery('SELECT COUNT(*) as count FROM friends');
    final tempUsersCount = await _database?.rawQuery('SELECT COUNT(*) as count FROM temp_users');
    
    return {
      'memory_cache': _memoryCache.length,
      'friends_cache': friendsCount?.first['count'] as int? ?? 0,
      'temp_cache': tempUsersCount?.first['count'] as int? ?? 0,
    };
  }
  
  // 私有方法
  
  Future<void> _loadFriendsToMemory() async {
    final friends = await _database?.query('friends');
    if (friends != null) {
      for (final friend in friends) {
        final userInfo = UserInfo.fromDb(friend);
        _memoryCache[userInfo.userId] = userInfo;
      }
      log('Loaded ${friends.length} friends to memory cache');
    }
  }
  
  Future<UserInfo?> _getFriendFromDb(String userId) async {
    final result = await _database?.query(
      'friends',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (result?.isNotEmpty == true) {
      return UserInfo.fromDb(result!.first);
    }
    return null;
  }
  
  Future<UserInfo?> _getTempUserFromDb(String userId) async {
    final result = await _database?.query(
      'temp_users',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    
    if (result?.isNotEmpty == true) {
      return UserInfo.fromDb(result!.first);
    }
    return null;
  }
  
  Future<void> _updateTempUsersCache(List<UserInfo> users) async {
    if (_database == null || users.isEmpty) return;
    
    final batch = _database!.batch();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final expireTime = currentTime + (24 * 60 * 60 * 1000); // 24小时后过期
    
    for (final user in users) {
      batch.insert(
        'temp_users',
        {
          'user_id': user.userId,
          'user_name': user.userName,
          'user_full_name': user.userFullName,
          'head_image': user.headImage,
          'sex': user.sex,
          'last_update': currentTime,
          'expire_time': expireTime,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }
  
  bool _isExpired(UserInfo userInfo) {
    // 这里可以添加过期检查逻辑
    // 暂时返回false，表示不过期
    return false;
  }
  
  Future<bool> _isFriend(String userId) async {
    final result = await _database?.query(
      'friends',
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return result?.isNotEmpty == true;
  }
}
