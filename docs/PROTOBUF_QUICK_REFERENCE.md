# Protobuf 协议快速参考

## 消息类型对照表

| 类型值 | 名称 | 方向 | 说明 |
|-------|------|------|------|
| 1 | C2C_SEND | 上行 | 发送单聊消息 |
| 2 | C2C_ACK | 上行/下行 | 消息确认 |
| 3 | C2C_WITHDRAW | 上行/下行 | 消息撤回 |
| 4 | GET_BATCH_MSG_IDS | 上行 | 批量获取消息ID |
| 5 | C2C_MSG_PUSH | 下行 | 服务端推送单聊消息 |
| 6 | PUSH_BATCH_MSG_IDS | 下行 | 服务端推送消息ID列表 |
| 7 | GROUP_SEND | 上行 | 群聊发送消息（预留） |
| 8 | GROUP_MSG_PUSH | 下行 | 服务端推送群聊消息（预留） |
| 9 | GROUP_ACK | 上行 | 群聊消息确认（预留） |
| 10 | GROUP_WITHDRAW | 上行/下行 | 群聊撤回消息（预留） |
| 11 | FRIEND_REQUEST | 下行 | 好友请求推送 |
| 12 | FRIEND_RESPONSE | 下行 | 好友响应推送 |

## 消息格式对照表

| 格式值 | 说明 |
|-------|------|
| 1 | 文本消息 |
| 2 | 图片消息 |
| 3 | 语音消息 |
| 4 | 视频消息 |
| 5 | 文件消息 |
| 6 | 位置消息 |

## 消息状态对照表

| 状态值 | 说明 |
|-------|------|
| 1 | 服务器已接收 |
| 3 | 对方未读 |
| 4 | 对方已读 |

## 好友请求状态对照表

| 状态值 | 说明 |
|-------|------|
| 0 | 待处理 |
| 1 | 已同意 |
| 2 | 已拒绝 |

## 常用代码示例

### 1. 发送文本消息

```dart
final webSocketService = Get.find<WebSocketService>();
final appData = Get.find<AppData>();

// 生成 chatId
String chatId = generateChatId(
  appData.user.value.id,
  targetUserId,
);

// 创建消息
ChatMessage message = ChatMessage(
  msgId: '', // 空字符串，sendMessage会自动获取
  content: '你好',
  fromUserId: appData.user.value.id,
  toUserId: targetUserId,
  type: 1, // 文本消息
  status: MessageStatus.sending,
  timestamp: DateTime.now(),
  chatId: chatId,
  withdrawStatus: MessageWithdrawStatus.no,
);

// 发送消息
bool success = await webSocketService.sendMessage(message);
```

### 2. 发送已读确认

```dart
webSocketService.sendReadAck(
  msgId,
  fromUserId,
  toUserId,
  chatId,
);
```

### 3. 撤回消息

```dart
webSocketService.withdrawMessage(
  msgId,
  fromUserId,
  toUserId,
  chatId,
);
```

### 4. 监听消息接收

```dart
AppEvent.onMessageReceived.listen((ChatMessage message) {
  // 处理收到的消息
  print('收到消息: ${message.content}');
});
```

### 5. 监听消息状态变化

```dart
AppEvent.onMessageStatusChanged.listen((MessageStatusChangedModel model) {
  // 更新消息状态
  print('消息 ${model.messageId} 状态变为 ${model.messageStatus}');
});
```

### 6. 监听好友请求

```dart
AppEvent.onFriendRequestPush.listen((FriendRequestPushMessage pushMessage) {
  // 处理好友请求
  print('收到好友请求: ${pushMessage.pushContent}');
});
```

## 调试技巧

### 1. 查看 WebSocket 消息日志

所有 WebSocket 消息都会通过日志输出，可以在控制台看到：

```
📨 收到 Protobuf 消息 - 类型: C2C_MSG_PUSH, 响应码: 0
【收到单聊消息】
  消息ID: 123456
  发送人: 1966479049087913984
  接收人: 1966369607918948352
  消息格式: 1
  消息内容: 你好
```

### 2. 检查消息ID缓存

```dart
// WebSocketService 内部维护了消息ID缓存
// 会自动管理，无需手动干预
```

### 3. 重新生成 Protobuf 代码

```bash
cd /Users/hzz/myself_project/im-app/20250923_02/xzll-im-flutter-client
export PATH="$PATH:$HOME/.pub-cache/bin"
rm -rf lib/generated
mkdir -p lib/generated
protoc --dart_out=lib/generated --proto_path=protos protos/im_message.proto
```

## 故障排查

### 问题1: WebSocket 连接失败

**检查项**：
1. 网络连接是否正常
2. 服务器地址和端口是否正确（`lib/constant/app_config_env.dart`）
3. Token 是否有效

### 问题2: 消息发送失败

**检查项**：
1. WebSocket 是否已连接
2. 是否有可用的消息ID
3. chatId 格式是否正确

### 问题3: 收不到消息

**检查项**：
1. WebSocket 连接状态
2. 是否正确监听了 `AppEvent.onMessageReceived`
3. 检查服务器日志

### 问题4: Protobuf 解析错误

**检查项**：
1. 客户端和服务端的 Proto 定义是否一致
2. Protobuf 版本是否兼容（当前使用 5.0.0）
3. 重新生成 Dart Protobuf 代码

## 性能优化建议

1. **消息ID预取**: 系统会自动批量获取消息ID，无需手动管理
2. **连接重试**: WebSocket 自动重连机制，默认重试 5 次
3. **二进制传输**: Protobuf 比 JSON 小约 30-50%
4. **内存管理**: 消息ID缓存会在用完后自动清理

## 安全注意事项

1. 所有请求都需要携带有效的 Token
2. chatId 必须使用标准格式（通过 `generateChatId()` 生成）
3. 不要在客户端存储敏感信息
4. 定期检查 Token 有效性

## 相关文件

- **Proto 定义**: `protos/im_message.proto`
- **生成的代码**: `lib/generated/im_message.pb.dart`
- **WebSocket 服务**: `lib/services/websocket_service.dart`
- **消息模型**: `lib/models/domain/chat_message.dart`
- **工具函数**: `lib/constant/app_tools.dart`
- **事件管理**: `lib/constant/app_event.dart`

