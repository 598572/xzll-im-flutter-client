# 数据库结构修复指南

## 问题描述
用户报告了以下SQLite错误：
```
DatabaseException(table messages has no column named msgId (code 1 SQLITE_ERROR))
```

## 根本原因
数据库表结构使用的是下划线命名（如 `msg_id`, `from_user_id`），但 `ChatMessage.toJson()` 方法生成的是驼峰命名的字段（如 `msgId`, `fromUserId`），导致字段名不匹配。

## 解决方案

### 🔧 **已修复的问题**

1. **字段名统一**：将数据库表字段名改为驼峰命名，与JSON序列化保持一致
2. **添加缺失字段**：在 `messages` 表和 `conversations` 表中添加了缺失字段
3. **数据库升级**：提供了完整的自动升级机制（版本1→2→3）
4. **数据迁移**：保留现有用户的聊天记录和会话数据
5. **查询语句更新**：所有相关查询都已更新为新的字段名

### 📊 **字段名对照表**

**Messages 表（版本1→2）：**
| 旧字段名 (v1) | 新字段名 (v2+) | 类型 | 说明 |
|---------------|---------------|------|------|
| `msg_id` | `msgId` | TEXT | 消息唯一ID |
| `from_user_id` | `fromUserId` | TEXT | 发送者用户ID |
| `to_user_id` | `toUserId` | TEXT | 接收者用户ID |
| `withdraw_status` | `withdrawStatus` | INTEGER | 撤回状态 |
| (新增) | `chatId` | TEXT | 会话ID |
| `timestamp` | `timestamp` | TEXT | ISO8601格式时间戳 |

**Conversations 表（版本2→3）：**
| 旧字段名 (v2) | 新字段名 (v3) | 类型 | 说明 |
|---------------|---------------|------|------|
| `user_id` | `userId` | TEXT | 当前用户ID |
| `target_user_id` | `targetUserId` | TEXT | 目标用户ID |
| `target_user_name` | `targetUserName` | TEXT | 目标用户名 |
| `target_user_avatar` | `targetUserAvatar` | TEXT | 目标用户头像 |
| `last_message` | `lastMessage` | TEXT | 最后消息内容 |
| `last_msg_id` | `lastMsgId` | TEXT | 最后消息ID |
| `last_msg_time` | `lastMsgTime` | INTEGER | 最后消息时间戳 |
| `last_msg_format` | `lastMsgFormat` | INTEGER | 最后消息格式 |
| `unread_count` | `unreadCount` | INTEGER | 未读消息数 |
| (新增) | `name` | TEXT | 会话显示名称 |
| (新增) | `headImage` | TEXT | 会话头像 |
| (新增) | `chatId` | TEXT | 会话ID |

### 🔄 **数据库版本升级**

**版本1 → 版本2：修复Messages表**
1. **创建备份表** - 使用新的messages字段结构
2. **数据迁移** - 将旧数据按字段映射迁移到新表
3. **删除旧表** - 安全删除旧的messages表
4. **重命名表** - 将备份表重命名为正式表
5. **重建索引** - 为新字段创建查询索引

**版本2 → 版本3：修复Conversations表**
1. **创建备份表** - 使用新的conversations字段结构
2. **数据迁移** - 将旧会话数据按字段映射迁移到新表
3. **字段补充** - 为缺失字段提供默认值
4. **删除旧表** - 安全删除旧的conversations表
5. **重命名表** - 将备份表重命名为正式表

### 💡 **自动升级逻辑**

```dart
// 数据库版本升级到3
_database = await openDatabase(path, version: 3, onCreate: _onCreate, onUpgrade: _onUpgrade);

// 自动检测和迁移旧数据
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 2) {
    await _upgradeToV2(db);  // 修复Messages表
  }
  if (oldVersion < 3) {
    await _upgradeToV3(db);  // 修复Conversations表
  }
}
```

### 🎯 **用户体验**

- **无缝升级**：现有用户的聊天记录会自动迁移
- **兼容性处理**：支持从旧字段名和新字段名读取数据
- **错误恢复**：升级失败时保护原始数据不丢失

### 📱 **对用户的影响**

1. **首次启动**：升级版本后第一次打开应用会稍微慢一些（执行数据迁移）
2. **数据保留**：所有聊天记录都会被保留
3. **功能正常**：修复后发送和接收消息功能恢复正常

### 🔍 **验证修复效果**

升级成功后，您应该在日志中看到：
```
数据库升级：从版本 X 到 3
数据库升级到V2完成  (如果从版本1升级)
迁移 X 条消息数据
数据库升级到V3完成  (如果从版本2升级) 
迁移 X 条会话数据
初始化数据库成功
```

### 🚨 **故障排除**

**如果遇到升级问题：**

1. **清除应用数据** (最后手段)：
   - Android: 设置 > 应用 > [应用名] > 存储 > 清除数据
   - iOS: 删除并重新安装应用

2. **查看日志**：
   - 搜索 "数据库升级" 相关日志
   - 检查是否有 "升级失败" 的错误信息

3. **手动重置**（开发调试用）：
   ```dart
   // 临时添加到 initDatabase 方法中，仅用于测试
   await deleteDatabase(path);  // 强制重建数据库
   ```

### 📈 **性能优化**

新的数据库结构包含以下优化：

1. **索引优化**：
   - `fromUserId` 字段索引 - 提升发送者查询速度
   - `toUserId` 字段索引 - 提升接收者查询速度  
   - `timestamp` 字段索引 - 提升时间排序速度

2. **查询效率**：
   ```sql
   -- 优化的查询语句
   SELECT * FROM messages 
   WHERE (fromUserId = ? AND toUserId = ?) OR (fromUserId = ? AND toUserId = ?) 
   ORDER BY timestamp DESC;
   ```

### ✅ **修复验证清单**

- [x] Messages表字段名与JSON字段名一致
- [x] Conversations表字段名与JSON字段名一致
- [x] 添加缺失的 `chatId`, `name`, `headImage` 字段
- [x] 实现完整的自动数据库升级机制（V1→V2→V3）
- [x] 保留现有用户的消息和会话数据
- [x] 更新所有相关查询语句使用新字段名
- [x] 重建优化索引
- [x] 增强聊天调试日志输出
- [x] 通过代码分析检查

现在您的应用应该可以：
✅ 正常保存和读取聊天消息  
✅ 正常保存和读取会话列表  
✅ 消息状态正确显示（而不是一直转圈）  
✅ 本地数据库正常工作
