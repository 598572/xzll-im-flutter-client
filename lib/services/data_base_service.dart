import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';
import 'package:xzll_im_flutter_client/models/user_info.dart';

class DataBaseService extends GetxService {
  Database? _database;

  ///根据用户ID初始化数据库
  Future<void> initDatabase({required String userId}) async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'xzll_$userId.db');
      _database = await openDatabase(path, version: 6, onCreate: _onCreate, onUpgrade: _onUpgrade);
      info("初始化数据库成功");
    } catch (e) {
      error("初始化本地数据库失败：${e.toString()}");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建消息ID表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS msg_ids (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        msg_id TEXT UNIQUE
      )
    ''');

    // ✅ 创建用户信息表
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_info (
        user_id TEXT PRIMARY KEY,
        user_name TEXT NOT NULL,
        user_full_name TEXT,
        phone TEXT,
        email TEXT,
        head_image TEXT,
        sex INTEGER,
        register_time TEXT,
        last_login_time TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // 创建会话表（使用驼峰命名以匹配Conversation.toJson()）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        headImage TEXT NOT NULL,
        userId TEXT NOT NULL,
        targetUserId TEXT NOT NULL,
        targetUserName TEXT,
        targetUserAvatar TEXT,
        lastMessage TEXT,
        lastMsgId TEXT,
        lastMsgTime INTEGER,
        lastMsgFormat INTEGER,
        unreadCount INTEGER DEFAULT 0,
        timestamp TEXT NOT NULL,
        chatId TEXT,
        created_at INTEGER DEFAULT (strftime('%s', 'now')),
        updated_at INTEGER DEFAULT (strftime('%s', 'now')),
        UNIQUE(userId, targetUserId)
      )
    ''');

    // 创建消息表（使用驼峰命名以匹配ChatMessage.toJson()）
    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        clientMsgId TEXT UNIQUE NOT NULL,
        msgId TEXT,
        content TEXT NOT NULL,
        fromUserId TEXT NOT NULL,
        toUserId TEXT NOT NULL,
        type INTEGER NOT NULL,
        status INTEGER DEFAULT 1,
        timestamp TEXT NOT NULL,
        withdrawStatus INTEGER DEFAULT 0,
        chatId TEXT NOT NULL,
        created_at INTEGER DEFAULT (strftime('%s', 'now'))
      )
    ''');

    // 为消息表创建索引
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_fromUserId ON messages(fromUserId)',
    );
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_toUserId ON messages(toUserId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_clientMsgId ON messages(clientMsgId)');

    debug("数据库表创建成功");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debug("数据库升级：从版本 $oldVersion 到 $newVersion");

    if (oldVersion < 2) {
      // 版本1到版本2：更新消息表结构
      await _upgradeToV2(db);
    }

    if (oldVersion < 3) {
      // 版本2到版本3：更新会话表结构
      await _upgradeToV3(db);
    }

    if (oldVersion < 4) {
      // 版本3到版本4：添加双轨制ID支持
      await _upgradeToV4(db);
    }

    if (oldVersion < 5) {
      // 版本4到版本5：添加用户信息表
      await _upgradeToV5(db);
    }

    if (oldVersion < 6) {
      // 版本5到版本6：修复消息表UNIQUE约束问题
      await _upgradeToV6(db);
    }
  }
  
  /// 升级到版本2：修复字段名匹配问题
  Future<void> _upgradeToV2(Database db) async {
    try {
      // 1. 创建新的messages表（备份旧数据）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          msgId TEXT UNIQUE NOT NULL,
          content TEXT NOT NULL,
          fromUserId TEXT NOT NULL,
          toUserId TEXT NOT NULL,
          type INTEGER NOT NULL,
          status INTEGER DEFAULT 1,
          timestamp TEXT NOT NULL,
          withdrawStatus INTEGER DEFAULT 0,
          chatId TEXT NOT NULL,
          created_at INTEGER DEFAULT (strftime('%s', 'now'))
        )
      ''');
      
      // 2. 检查旧表是否存在数据
      final List<Map<String, dynamic>> oldData = await db.query('messages');
      
      if (oldData.isNotEmpty) {
        // 3. 迁移旧数据到新表（字段名映射）
        Batch batch = db.batch();
        for (Map<String, dynamic> row in oldData) {
          batch.insert('messages_backup', {
            'msgId': row['msg_id'] ?? row['msgId'] ?? '',
            'content': row['content'] ?? '',
            'fromUserId': row['from_user_id'] ?? row['fromUserId'] ?? '',
            'toUserId': row['to_user_id'] ?? row['toUserId'] ?? '',
            'type': row['type'] ?? 1,
            'status': row['status'] ?? 1,
            'timestamp': row['timestamp'] ?? DateTime.now().toIso8601String(),
            'withdrawStatus': row['withdraw_status'] ?? row['withdrawStatus'] ?? 0,
            'chatId': row['chatId'] ?? '', // 新字段，可能为空
            'created_at': row['created_at'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
        debug("迁移 ${oldData.length} 条消息数据");
      }
      
      // 4. 删除旧表
      await db.execute('DROP TABLE IF EXISTS messages');
      
      // 5. 重命名备份表为正式表
      await db.execute('ALTER TABLE messages_backup RENAME TO messages');
      
      // 6. 重建索引
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_fromUserId ON messages(fromUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_toUserId ON messages(toUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)');
      
      debug("数据库升级到V2完成");
    } catch (e) {
      error("数据库升级失败: $e");
      rethrow;
    }
  }
  
  /// 升级到版本3：修复会话表字段名匹配问题
  Future<void> _upgradeToV3(Database db) async {
    try {
      // 1. 创建新的conversations表（备份旧数据）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS conversations_backup (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          headImage TEXT NOT NULL,
          userId TEXT NOT NULL,
          targetUserId TEXT NOT NULL,
          targetUserName TEXT,
          targetUserAvatar TEXT,
          lastMessage TEXT,
          lastMsgId TEXT,
          lastMsgTime INTEGER,
          lastMsgFormat INTEGER,
          unreadCount INTEGER DEFAULT 0,
          timestamp TEXT NOT NULL,
          chatId TEXT,
          created_at INTEGER DEFAULT (strftime('%s', 'now')),
          updated_at INTEGER DEFAULT (strftime('%s', 'now')),
          UNIQUE(userId, targetUserId)
        )
      ''');
      
      // 2. 检查旧表是否存在数据
      final List<Map<String, dynamic>> oldData = await db.query('conversations');
      
      if (oldData.isNotEmpty) {
        // 3. 迁移旧数据到新表（字段名映射）
        Batch batch = db.batch();
        for (Map<String, dynamic> row in oldData) {
          batch.insert('conversations_backup', {
            'name': row['target_user_name'] ?? row['targetUserName'] ?? row['name'] ?? '',
            'headImage': row['target_user_avatar'] ?? row['targetUserAvatar'] ?? row['headImage'] ?? 'assets/other_headImage.png',
            'userId': row['user_id'] ?? row['userId'] ?? '',
            'targetUserId': row['target_user_id'] ?? row['targetUserId'] ?? '',
            'targetUserName': row['target_user_name'] ?? row['targetUserName'] ?? '',
            'targetUserAvatar': row['target_user_avatar'] ?? row['targetUserAvatar'] ?? '',
            'lastMessage': row['last_message'] ?? row['lastMessage'] ?? '',
            'lastMsgId': row['last_msg_id'] ?? row['lastMsgId'] ?? '',
            'lastMsgTime': row['last_msg_time'] ?? row['lastMsgTime'] ?? 0,
            'lastMsgFormat': row['last_msg_format'] ?? row['lastMsgFormat'] ?? 1,
            'unreadCount': row['unread_count'] ?? row['unreadCount'] ?? 0,
            'timestamp': row['timestamp'] ?? DateTime.now().toIso8601String(),
            'chatId': row['chatId'] ?? '', // 新字段，可能为空
            'created_at': row['created_at'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
            'updated_at': row['updated_at'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
        debug("迁移 ${oldData.length} 条会话数据");
      }
      
      // 4. 删除旧表
      await db.execute('DROP TABLE IF EXISTS conversations');
      
      // 5. 重命名备份表为正式表
      await db.execute('ALTER TABLE conversations_backup RENAME TO conversations');
      
      debug("数据库升级到V3完成");
    } catch (e) {
      error("会话表升级失败: $e");
      rethrow;
    }
  }
  
  /// 升级到版本4：添加双轨制ID支持（clientMsgId字段）
  Future<void> _upgradeToV4(Database db) async {
    try {
      // 1. 创建新的messages表，包含clientMsgId字段
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages_v4 (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientMsgId TEXT,
          msgId TEXT UNIQUE NOT NULL,
          content TEXT NOT NULL,
          fromUserId TEXT NOT NULL,
          toUserId TEXT NOT NULL,
          type INTEGER NOT NULL,
          status INTEGER DEFAULT 1,
          timestamp TEXT NOT NULL,
          withdrawStatus INTEGER DEFAULT 0,
          chatId TEXT NOT NULL,
          created_at INTEGER DEFAULT (strftime('%s', 'now'))
        )
      ''');
      
      // 2. 检查旧表是否存在数据
      final List<Map<String, dynamic>> oldData = await db.query('messages');
      
      if (oldData.isNotEmpty) {
        // 3. 迁移旧数据到新表，为旧数据生成UUID作为clientMsgId
        Batch batch = db.batch();
        for (Map<String, dynamic> row in oldData) {
          // 为旧消息生成clientMsgId（使用msgId + 时间戳作为简单的唯一标识）
          String clientMsgId = 'legacy_${row['msgId']}_${DateTime.now().millisecondsSinceEpoch}';
          
          batch.insert('messages_v4', {
            'clientMsgId': clientMsgId, // 新字段：为旧数据生成clientMsgId
            'msgId': row['msgId'],
            'content': row['content'],
            'fromUserId': row['fromUserId'],
            'toUserId': row['toUserId'],
            'type': row['type'],
            'status': row['status'],
            'timestamp': row['timestamp'],
            'withdrawStatus': row['withdrawStatus'],
            'chatId': row['chatId'],
            'created_at': row['created_at'],
          }, conflictAlgorithm: ConflictAlgorithm.ignore);
        }
        await batch.commit(noResult: true);
        debug("迁移 ${oldData.length} 条消息数据到V4，并生成clientMsgId");
      }
      
      // 4. 删除旧表
      await db.execute('DROP TABLE IF EXISTS messages');
      
      // 5. 重命名新表为正式表
      await db.execute('ALTER TABLE messages_v4 RENAME TO messages');
      
      // 6. 重建索引
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_fromUserId ON messages(fromUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_toUserId ON messages(toUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_clientMsgId ON messages(clientMsgId)'); // 新增clientMsgId索引
      
      debug("数据库升级到V4完成 - 添加双轨制ID支持");
    } catch (e) {
      error("数据库升级到V4失败: $e");
      rethrow;
    }
  }

  ///关闭数据库成功
  Future<void> close() async {
    if (_database != null) {
      await _database?.close();
    }
    debug("数据库已关闭");
  }

  ///批量插入从数据库获取的消息ID
  Future<void> insertAllMsgId(List<String> msgIds) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }
    Batch batch = _database!.batch();
    for (String msgId in msgIds) {
      batch.insert('msg_ids', {'msg_id': msgId}, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
    debug("批量插入消息ID完成");
  }

  ///获取一个消息ID并删除获取的ID
  Future<String?> getAndDeleteOneMsgId() async {
    if (_database == null) {
      error("数据库未初始化");
      return null;
    }
    List<Map<String, dynamic>> result = await _database!.query('msg_ids', limit: 1);
    if (result.isNotEmpty) {
      String msgId = result.first['msg_id'];
      await _database!.delete('msg_ids', where: 'msg_id = ?', whereArgs: [msgId]);
      debug("获取并删除消息ID: $msgId");
      return msgId;
    } else {
      debug("没有可用的消息ID");
      return null;
    }
  }

  ///获取消息ID数量
  Future<int> getMsgIdCount() async {
    if (_database == null) {
      error("数据库未初始化");
      return 0;
    }
    int? count = Sqflite.firstIntValue(await _database!.rawQuery('SELECT COUNT(*) FROM msg_ids'));
    return count ?? 0;
  }

  // ==================== 会话相关操作 ====================

  /// 插入或更新会话
  Future<void> insertOrUpdateConversation(Conversation conversation) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.insert(
      'conversations',
      conversation.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debug("会话已插入/更新: ${conversation.targetUserId}");
  }

  /// 获取所有会话列表
  Future<List<Conversation>> getAllConversations(String userId) async {
    if (_database == null) {
      error("数据库未初始化");
      return [];
    }

    final List<Map<String, dynamic>> result = await _database!.query(
      'conversations',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastMsgTime DESC, updated_at DESC',
    );

    return result.map((map) {
      return Conversation.fromJson(map);
    }).toList();
  }

  /// 更新会话未读数
  Future<void> updateConversationUnreadCount(
    String userId,
    String targetUserId,
    int unreadCount,
  ) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.update(
      'conversations',
      {'unreadCount': unreadCount, 'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000},
      where: 'userId = ? AND targetUserId = ?',
      whereArgs: [userId, targetUserId],
    );
    debug("会话未读数已更新: $targetUserId -> $unreadCount");
  }

  /// 删除会话
  Future<void> deleteConversation(String userId, String targetUserId) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.delete(
      'conversations',
      where: 'userId = ? AND targetUserId = ?',
      whereArgs: [userId, targetUserId],
    );
    debug("会话已删除: $targetUserId");
  }

  // ==================== 消息相关操作 ====================

  /// 插入消息
  Future<void> insertMessage(ChatMessage message) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }
    await _database!.insert(
      'messages',
      message.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    debug("消息已插入: ${message.msgId}");
  }

  /// 批量插入消息
  Future<void> insertMessages(List<ChatMessage> messages) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    Batch batch = _database!.batch();
    for (ChatMessage message in messages) {
      batch.insert('messages', message.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
    debug("批量插入消息完成，共${messages.length}条");
  }

  /// 获取两个用户之间的聊天消息
  Future<List<ChatMessage>> getMessagesBetweenUsers(
    String userId1,
    String userId2, {
    int limit = 50,
    int offset = 0,
  }) async {
    if (_database == null) {
      error("数据库未初始化");
      return [];
    }

    final List<Map<String, dynamic>> result = await _database!.query(
      'messages',
      where: '(fromUserId = ? AND toUserId = ?) OR (fromUserId = ? AND toUserId = ?)',
      whereArgs: [userId1, userId2, userId2, userId1],
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return result.map((map) {
      return ChatMessage.fromJson(map);
    }).toList();
  }

  /// 更新消息状态（双轨制：优先使用clientMsgId，其次使用msgId）
  Future<void> updateMessageStatus(String messageId, MessageStatus status, {String? serverMsgId}) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    // 构建更新数据
    Map<String, dynamic> updateData = {'status': status.code};
    if (serverMsgId != null && serverMsgId.isNotEmpty) {
      updateData['msgId'] = serverMsgId; // 同时更新serverMsgId
    }

    // 双轨制查找：优先使用clientMsgId
    int count = await _database!.update(
      'messages',
      updateData,
      where: 'clientMsgId = ?',
      whereArgs: [messageId],
    );
    
    // 如果clientMsgId未找到，使用msgId查找
    if (count == 0) {
      count = await _database!.update(
        'messages',
        updateData,
        where: 'msgId = ?',
        whereArgs: [messageId],
      );
    }
    
    if (count > 0) {
      debug("消息状态已更新: $messageId -> ${status.desc}${serverMsgId != null ? ' (serverMsgId: $serverMsgId)' : ''}");
    } else {
      debug("未找到要更新的消息: $messageId");
    }
  }

  /// 通过clientMsgId更新消息状态
  Future<void> updateMessageStatusByClientId(String clientMsgId, MessageStatus status, {String? serverMsgId}) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    Map<String, dynamic> updateData = {'status': status.code};
    if (serverMsgId != null && serverMsgId.isNotEmpty) {
      updateData['msgId'] = serverMsgId; // 同时更新serverMsgId
    }

    int count = await _database!.update(
      'messages',
      updateData,
      where: 'clientMsgId = ?',
      whereArgs: [clientMsgId],
    );
    
    if (count > 0) {
      debug("消息状态已更新(clientMsgId): $clientMsgId -> ${status.desc}${serverMsgId != null ? ' (serverMsgId: $serverMsgId)' : ''}");
    } else {
      debug("未找到要更新的消息(clientMsgId): $clientMsgId");
    }
  }

  /// 撤回消息（双轨制：优先使用clientMsgId，其次使用msgId）
  Future<void> withdrawMessage(String messageId) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    // 双轨制查找：优先使用clientMsgId
    int count = await _database!.update(
      'messages',
      {'withdrawStatus': MessageWithdrawStatus.yes.code},
      where: 'clientMsgId = ?',
      whereArgs: [messageId],
    );
    
    // 如果clientMsgId未找到，使用msgId查找
    if (count == 0) {
      count = await _database!.update(
        'messages',
        {'withdrawStatus': MessageWithdrawStatus.yes.code},
        where: 'msgId = ?',
        whereArgs: [messageId],
      );
    }
    
    if (count > 0) {
      debug("消息已撤回: $messageId");
    } else {
      debug("未找到要撤回的消息: $messageId");
    }
  }

  /// 删除消息（双轨制：优先使用clientMsgId，其次使用msgId）
  Future<void> deleteMessage(String messageId) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    // 双轨制查找：优先使用clientMsgId
    int count = await _database!.delete(
      'messages', 
      where: 'clientMsgId = ?', 
      whereArgs: [messageId]
    );
    
    // 如果clientMsgId未找到，使用msgId查找
    if (count == 0) {
      count = await _database!.delete(
        'messages', 
        where: 'msgId = ?', 
        whereArgs: [messageId]
      );
    }
    
    if (count > 0) {
      debug("消息已删除: $messageId");
    } else {
      debug("未找到要删除的消息: $messageId");
    }
  }

  /// 升级到版本5：添加用户信息表
  Future<void> _upgradeToV5(Database db) async {
    try {
      info("升级数据库到版本5：添加用户信息表");

      // 创建用户信息表
      await db.execute('''
        CREATE TABLE IF NOT EXISTS user_info (
          user_id TEXT PRIMARY KEY,
          user_name TEXT NOT NULL,
          user_full_name TEXT,
          phone TEXT,
          email TEXT,
          head_image TEXT,
          sex INTEGER,
          register_time TEXT,
          last_login_time TEXT,
          created_at INTEGER DEFAULT (strftime('%s', 'now')),
          updated_at INTEGER DEFAULT (strftime('%s', 'now'))
        )
      ''');

      info("✅ 用户信息表创建成功");
    } catch (e) {
      error("❌ 升级到版本5失败: $e");
    }
  }

  /// 升级到版本6：修复消息表UNIQUE约束问题
  /// 将UNIQUE约束从msgId改到clientMsgId，解决发送消息时msgId为空导致覆盖的问题
  Future<void> _upgradeToV6(Database db) async {
    try {
      info("升级数据库到版本6：修复消息表UNIQUE约束");

      // 1. 创建新的消息表（使用clientMsgId作为UNIQUE约束）
      await db.execute('''
        CREATE TABLE IF NOT EXISTS messages_new (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          clientMsgId TEXT UNIQUE NOT NULL,
          msgId TEXT,
          content TEXT NOT NULL,
          fromUserId TEXT NOT NULL,
          toUserId TEXT NOT NULL,
          type INTEGER NOT NULL,
          status INTEGER DEFAULT 1,
          timestamp TEXT NOT NULL,
          withdrawStatus INTEGER DEFAULT 0,
          chatId TEXT NOT NULL,
          created_at INTEGER DEFAULT (strftime('%s', 'now'))
        )
      ''');

      // 2. 迁移数据从旧表到新表
      final List<Map<String, dynamic>> oldMessages = await db.query('messages');

      info("📦 找到 ${oldMessages.length} 条消息需要迁移");

      if (oldMessages.isNotEmpty) {
        Batch batch = db.batch();

        for (var msg in oldMessages) {
          // 如果clientMsgId为空，生成一个临时的
          final clientMsgId = msg['clientMsgId']?.toString() ?? 'temp-${DateTime.now().millisecondsSinceEpoch}-${msg["id"]}';

          batch.insert('messages_new', {
            'clientMsgId': clientMsgId,
            'msgId': msg['msgId']?.toString(),
            'content': msg['content']?.toString() ?? '',
            'fromUserId': msg['fromUserId']?.toString() ?? '',
            'toUserId': msg['toUserId']?.toString() ?? '',
            'type': msg['type'] ?? 1,
            'status': msg['status'] ?? 1,
            'timestamp': msg['timestamp']?.toString() ?? DateTime.now().toIso8601String(),
            'withdrawStatus': msg['withdrawStatus'] ?? 0,
            'chatId': msg['chatId']?.toString() ?? '',
            'created_at': msg['created_at']?.toString(),
          });
        }

        await batch.commit(noResult: true);
        info("✅ 成功迁移 ${oldMessages.length} 条消息");
      }

      // 3. 删除旧表
      await db.execute('DROP TABLE IF EXISTS messages');

      // 4. 重命名新表
      await db.execute('ALTER TABLE messages_new RENAME TO messages');

      // 5. 重新创建索引
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_fromUserId ON messages(fromUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_toUserId ON messages(toUserId)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_clientMsgId ON messages(clientMsgId)');

      info("✅ 数据库升级到版本6完成");
    } catch (e) {
      error("❌ 升级到版本6失败: $e");
    }
  }

  // ==================== 用户信息相关操作 ====================

  /// 保存或更新用户信息到本地数据库
  Future<bool> saveUserInfo(UserInfo userInfo) async {
    if (_database == null) {
      error("❌ 数据库未初始化");
      return false;
    }

    try {
      info('📋 保存用户信息到本地数据库: ${userInfo.userId}');
      
      final Map<String, dynamic> data = {
        'user_id': userInfo.userId,
        'user_name': userInfo.userName,
        'user_full_name': userInfo.userFullName,
        'phone': userInfo.phone,
        'email': userInfo.email,
        'head_image': userInfo.headImage,
        'sex': userInfo.sex,
        'register_time': userInfo.registerTime,
        'last_login_time': userInfo.lastLoginTime,
        'updated_at': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      };

      // 使用 INSERT OR REPLACE 实现保存或更新
      await _database!.insert(
        'user_info',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      info('✅ 用户信息保存成功');
      return true;
    } catch (e) {
      error('❌ 保存用户信息失败: $e');
      return false;
    }
  }

  /// 从本地数据库获取用户信息
  Future<UserInfo?> getUserInfo(String userId) async {
    if (_database == null) {
      error("❌ 数据库未初始化");
      return null;
    }

    try {
      info('📋 从本地数据库获取用户信息: $userId');
      
      final List<Map<String, dynamic>> results = await _database!.query(
        'user_info',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (results.isNotEmpty) {
        final userInfo = UserInfo.fromDb(results.first);
        info('✅ 用户信息获取成功: ${userInfo.userName}');
        return userInfo;
      } else {
        info('⚠️ 本地数据库中未找到用户信息: $userId');
        return null;
      }
    } catch (e) {
      error('❌ 获取用户信息失败: $e');
      return null;
    }
  }

  /// 删除用户信息
  Future<bool> deleteUserInfo(String userId) async {
    if (_database == null) {
      error("❌ 数据库未初始化");
      return false;
    }

    try {
      info('📋 删除用户信息: $userId');
      
      final count = await _database!.delete(
        'user_info',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (count > 0) {
        info('✅ 用户信息删除成功');
        return true;
      } else {
        info('⚠️ 未找到要删除的用户信息');
        return false;
      }
    } catch (e) {
      error('❌ 删除用户信息失败: $e');
      return false;
    }
  }
}
