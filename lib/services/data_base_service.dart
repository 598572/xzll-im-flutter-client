import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:xzll_im_flutter_client/constant/constant.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/domain/conversation.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';

class DataBaseService extends GetxService {
  Database? _database;

  ///根据用户ID初始化数据库
  Future<void> initDatabase({required String userId}) async {
    try {
      String databasesPath = await getDatabasesPath();
      String path = join(databasesPath, 'xzll_$userId.db');
      _database = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);
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

    // 为消息表创建索引
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_messages_fromUserId ON messages(fromUserId)',
    );
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_toUserId ON messages(toUserId)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_messages_timestamp ON messages(timestamp)');

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

  /// 更新消息状态
  Future<void> updateMessageStatus(String msgId, MessageStatus status) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.update(
      'messages',
      {'status': status.code},
      where: 'msg_id = ?',
      whereArgs: [msgId],
    );
    debug("消息状态已更新: $msgId -> ${status.desc}");
  }

  /// 撤回消息
  Future<void> withdrawMessage(String msgId) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.update(
      'messages',
      {'withdraw_status': MessageWithdrawStatus.yes.code},
      where: 'msg_id = ?',
      whereArgs: [msgId],
    );
    debug("消息已撤回: $msgId");
  }

  /// 删除消息
  Future<void> deleteMessage(String msgId) async {
    if (_database == null) {
      error("数据库未初始化");
      return;
    }

    await _database!.delete('messages', where: 'msg_id = ?', whereArgs: [msgId]);
    debug("消息已删除: $msgId");
  }
}
