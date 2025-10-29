# IM 客户端 Protobuf 协议改造文档

## 改造概述

本次改造将 Flutter IM 客户端从 JSON 协议升级到 Protobuf 二进制协议，与后端保持一致。

## 主要变更

### 1. Proto 定义文件

创建了 `protos/im_message.proto` 文件，定义了所有消息类型和数据结构，与后端完全一致：

- **消息类型枚举** (`MsgType`)
  - 单聊相关：`C2C_SEND`, `C2C_ACK`, `C2C_WITHDRAW`, `C2C_MSG_PUSH`
  - 群聊相关：`GROUP_SEND`, `GROUP_MSG_PUSH`, `GROUP_ACK`, `GROUP_WITHDRAW` (预留)
  - 好友相关：`FRIEND_REQUEST`, `FRIEND_RESPONSE`
  - 通用功能：`GET_BATCH_MSG_IDS`, `PUSH_BATCH_MSG_IDS`

- **主要消息结构**
  - `ImProtoRequest`: 客户端请求封装
  - `ImProtoResponse`: 服务端响应封装
  - `C2CSendReq`: C2C发送消息请求
  - `C2CMsgPush`: 服务端推送单聊消息
  - `C2CAckReq`: 消息确认请求
  - `C2CWithdrawReq`: 消息撤回请求
  - `GetBatchMsgIdsReq`: 批量获取消息ID请求
  - `BatchMsgIdsPush`: 批量消息ID推送
  - `FriendRequestPush`: 好友请求推送
  - `FriendResponsePush`: 好友响应推送

### 2. 依赖更新

在 `pubspec.yaml` 中添加了 Protobuf 依赖：

```yaml
protobuf: ^5.0.0
fixnum: ^1.1.0
```

### 3. 生成 Dart Protobuf 代码

使用 `protoc` 编译器生成了 Dart 代码：

```bash
protoc --dart_out=lib/generated --proto_path=protos protos/im_message.proto
```

生成的文件位于 `lib/generated/` 目录：
- `im_message.pb.dart`: 主要消息类
- `im_message.pbenum.dart`: 枚举定义
- `im_message.pbjson.dart`: JSON 转换支持

### 4. WebSocketService 重构

完全重写了 `lib/services/websocket_service.dart`，支持 Protobuf 二进制协议：

- **消息发送**：使用 `ImProtoRequest` 封装，通过 `writeToBuffer()` 序列化为二进制
- **消息接收**：接收二进制数据，使用 `ImProtoResponse.fromBuffer()` 反序列化
- **消息ID管理**：自动从服务器获取批量消息ID并缓存
- **消息类型处理**：根据 `MsgType` 分发到不同的处理函数

主要方法：
- `sendMessage()`: 发送单聊消息
- `sendReceivedAck()`: 发送接收确认
- `sendReadAck()`: 发送已读确认
- `withdrawMessage()`: 撤回消息
- `getMsgIdsFromServer()`: 获取批量消息ID

### 5. ChatMessage 模型更新

更新了 `lib/models/domain/chat_message.dart`：

- 将 `type` 字段从 `MessageType` 枚举改为 `int` 类型（与 Proto 定义一致）
  - 1: 文本
  - 2: 图片
  - 3: 语音
  - 4: 视频
  - 5: 文件
  - 6: 位置
- 添加了 `chatId` 字段（会话ID）
- 添加了 `copyWith()` 方法方便消息拷贝

### 6. 工具函数更新

更新了 `lib/constant/app_tools.dart`：

- 修改 `formatLastMessage()` 以适配 int 类型的消息格式
- 添加 `generateChatId()` 函数生成标准格式的 chatId：
  ```dart
  // 格式: 100-1-{userId1}-{userId2}
  // userId 按字典序排序，保证同一对话的 chatId 一致
  String generateChatId(String userId1, String userId2)
  ```

### 7. 好友服务

好友相关功能继续使用 HTTP API（不通过 WebSocket）：
- `/api/friend/request/send`: 发送好友请求
- `/api/friend/request/handle`: 处理好友请求
- `/api/friend/list`: 获取好友列表
- `/api/friend/request/list`: 获取好友请求列表

好友请求和响应的**推送**通过 WebSocket 的 Protobuf 协议进行。

## 消息流程

### 发送消息流程

1. 从本地缓存获取消息ID（如无则自动向服务器请求）
2. 构建 `C2CSendReq` 消息对象
3. 封装为 `ImProtoRequest`
4. 序列化为二进制数据
5. 通过 WebSocket 发送

### 接收消息流程

1. WebSocket 接收到二进制数据
2. 反序列化为 `ImProtoResponse`
3. 根据 `type` 字段判断消息类型
4. 解析 `payload` 得到具体消息内容
5. 触发相应的事件通知UI更新

### ACK 确认流程

- **接收确认（status=3）**: 收到消息后自动发送
- **已读确认（status=4）**: 用户查看消息时发送

### 撤回流程

1. 客户端发送 `C2CWithdrawReq`
2. 服务器广播撤回通知
3. 双方客户端收到 `C2C_WITHDRAW` 推送并更新UI

## chatId 格式说明

chatId 用于标识唯一的会话，格式为：`100-1-{userId1}-{userId2}`

- `100`: 会话类型（100表示单聊）
- `1`: 业务类型
- `userId1` 和 `userId2`: 两个用户ID，按字典序排序

示例：
```dart
generateChatId("1966479049087913984", "1966369607918948352")
// 返回: "100-1-1966369607918948352-1966479049087913984"
```

## 编译和运行

1. 安装依赖：
```bash
flutter pub get
```

2. 运行应用：
```bash
flutter run
```

3. 如需修改 Proto 定义：
```bash
# 修改 protos/im_message.proto 后重新生成
export PATH="$PATH:$HOME/.pub-cache/bin"
rm -rf lib/generated
mkdir -p lib/generated
protoc --dart_out=lib/generated --proto_path=protos protos/im_message.proto
```

## 注意事项

1. **消息ID管理**: 客户端会自动管理消息ID缓存，用完后自动向服务器请求新的批量ID
2. **二进制传输**: WebSocket 现在传输的是二进制数据（Uint8List），不再是 JSON 字符串
3. **类型安全**: Protobuf 提供了强类型检查，减少了运行时错误
4. **向后兼容**: 好友请求等功能仍使用 HTTP API，保证兼容性
5. **chatId 生成**: 始终使用 `generateChatId()` 函数生成 chatId，确保格式一致

## 性能优势

相比 JSON 协议，Protobuf 协议具有以下优势：

- **更小的数据包**: 二进制编码比 JSON 文本编码更紧凑
- **更快的解析**: 无需 JSON 解析，直接二进制反序列化
- **类型安全**: 编译时类型检查，减少运行时错误
- **版本兼容**: 支持字段的前向和后向兼容

## 后续工作

- [ ] 实现群聊相关功能（目前已定义 Proto 但未实现业务逻辑）
- [ ] 完善聊天界面（chat_view.dart）
- [ ] 添加离线消息处理
- [ ] 添加消息重发机制
- [ ] 优化消息ID缓存策略

## 参考资料

- [Protocol Buffers 官方文档](https://protobuf.dev/)
- [Dart Protobuf 插件](https://pub.dev/packages/protobuf)
- [后端 Proto 定义](../javademo/)

