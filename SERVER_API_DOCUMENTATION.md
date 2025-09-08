# 蝎聊服务端 API 文档

## WebSocket 连接

### 连接地址
```
ws://120.46.85.43:80/websocket
```

### 连接头信息
```
Connection: Upgrade
Upgrade: websocket
token: {用户token}
uid: {用户ID}
```

## 会话列表相关接口

### 1. 获取会话列表

**客户端请求:**
```json
{
  "url": "xzll/im/conversation/list",
  "body": {
    "userId": "111",
    "page": 1,
    "size": 50
  }
}
```

**服务端响应:**
```json
{
  "url": "xzll/im/conversation/list",
  "code": 200,
  "message": "success",
  "data": [
    {
      "name": "Alice",
      "headImage": "assets/other_headImage.png",
      "lastMessage": "Hello, how are you?",
      "timestamp": "2024-08-15T10:00:00Z",
      "userId": "222",
      "unreadCount": 2
    },
    {
      "name": "Bob",
      "headImage": "assets/other_headImage.png", 
      "lastMessage": "Are we still meeting today?",
      "timestamp": "2024-08-15T09:45:00Z",
      "userId": "333",
      "unreadCount": 0
    }
  ]
}
```

### 2. 会话更新推送

**服务端主动推送:**
```json
{
  "url": "xzll/im/conversation/update",
  "code": 200,
  "message": "success",
  "data": {
    "name": "Alice",
    "headImage": "assets/other_headImage.png",
    "lastMessage": "New message content",
    "timestamp": "2024-08-15T10:30:00Z",
    "userId": "222",
    "unreadCount": 3
  }
}
```

## 消息相关接口

### 1. 获取消息ID

**客户端请求:**
```json
{
  "url": "xzll/im/c2c/get/batch/msgId",
  "body": {
    "fromUserId": "111"
  }
}
```

**服务端响应:**
```json
{
  "url": "xzll/im/c2c/get/batch/msgId",
  "code": 200,
  "message": "success",
  "msgIds": ["msgId1", "msgId2", "msgId3", "msgId4", "msgId5"]
}
```

### 2. 发送消息

**客户端请求:**
```json
{
  "url": "xzll/im/c2c/send",
  "body": {
    "msgId": "msgId1",
    "msgContent": "Hello, how are you?",
    "toUserId": "222",
    "fromUserId": "111",
    "msgCreateTime": 1692086400000,
    "msgFormat": 1
  }
}
```

**服务端响应:**
```json
{
  "url": "xzll/im/c2c/send",
  "code": 200,
  "message": "success",
  "body": {
    "msgId": "msgId1",
    "msgContent": "Hello, how are you?",
    "toUserId": "222",
    "fromUserId": "111",
    "msgCreateTime": 1692086400000,
    "msgFormat": 1
  }
}
```

### 3. 消息接收确认

**客户端请求:**
```json
{
  "url": "xzll/im/c2c/receivedAck",
  "body": {
    "msgId": "msgId1",
    "fromUserId": "222",
    "toUserId": "111",
    "msgStatus": 0
  }
}
```

### 4. 消息已读确认

**客户端请求:**
```json
{
  "url": "xzll/im/c2c/toUserReadAck",
  "body": {
    "msgId": "msgId1",
    "fromUserId": "222",
    "toUserId": "111",
    "msgStatus": 1
  }
}
```

## 服务端实现建议

### 1. 会话列表管理

```java
// 会话实体类
public class Conversation {
    private String name;
    private String headImage;
    private String lastMessage;
    private String timestamp;
    private String userId;
    private Integer unreadCount;
    
    // getters and setters
}

// 会话服务
@Service
public class ConversationService {
    
    // 获取用户会话列表
    public List<Conversation> getUserConversations(String userId, int page, int size) {
        // 实现逻辑：从数据库查询用户的会话列表
        // 按最后消息时间排序
        // 分页返回
    }
    
    // 更新会话信息
    public void updateConversation(String userId, String otherUserId, String lastMessage) {
        // 实现逻辑：更新会话的最后消息和时间
        // 推送更新给客户端
    }
}
```

### 2. WebSocket 消息处理

```java
@Component
public class WebSocketHandler {
    
    @OnMessage
    public void handleMessage(String message, Session session) {
        JSONObject request = JSON.parseObject(message);
        String url = request.getString("url");
        
        switch (url) {
            case "xzll/im/conversation/list":
                handleConversationList(request, session);
                break;
            case "xzll/im/c2c/send":
                handleSendMessage(request, session);
                break;
            // 其他消息类型处理
        }
    }
    
    private void handleConversationList(JSONObject request, Session session) {
        String userId = request.getJSONObject("body").getString("userId");
        int page = request.getJSONObject("body").getIntValue("page");
        int size = request.getJSONObject("body").getIntValue("size");
        
        List<Conversation> conversations = conversationService.getUserConversations(userId, page, size);
        
        JSONObject response = new JSONObject();
        response.put("url", "xzll/im/conversation/list");
        response.put("code", 200);
        response.put("message", "success");
        response.put("data", conversations);
        
        session.getBasicRemote().sendText(response.toJSONString());
    }
    
    private void handleSendMessage(JSONObject request, Session session) {
        // 处理消息发送逻辑
        // 更新会话列表
        // 推送消息给接收方
        // 推送会话更新给发送方
    }
}
```

### 3. 实时推送机制

```java
@Component
public class ConversationPushService {
    
    // 推送会话更新
    public void pushConversationUpdate(String userId, Conversation conversation) {
        JSONObject message = new JSONObject();
        message.put("url", "xzll/im/conversation/update");
        message.put("code", 200);
        message.put("message", "success");
        message.put("data", conversation);
        
        // 发送给指定用户的所有连接
        WebSocketManager.sendToUser(userId, message.toJSONString());
    }
    
    // 推送新消息时更新会话
    public void updateConversationOnNewMessage(String fromUserId, String toUserId, String messageContent) {
        // 更新发送方的会话
        Conversation senderConversation = new Conversation();
        senderConversation.setUserId(toUserId);
        senderConversation.setLastMessage(messageContent);
        senderConversation.setTimestamp(new Date());
        // 设置其他字段...
        
        pushConversationUpdate(fromUserId, senderConversation);
        
        // 更新接收方的会话
        Conversation receiverConversation = new Conversation();
        receiverConversation.setUserId(fromUserId);
        receiverConversation.setLastMessage(messageContent);
        receiverConversation.setTimestamp(new Date());
        receiverConversation.setUnreadCount(getUnreadCount(toUserId, fromUserId) + 1);
        // 设置其他字段...
        
        pushConversationUpdate(toUserId, receiverConversation);
    }
}
```

## 数据库设计建议

### 会话表 (conversations)
```sql
CREATE TABLE conversations (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    user_id VARCHAR(50) NOT NULL,
    other_user_id VARCHAR(50) NOT NULL,
    last_message TEXT,
    last_message_time TIMESTAMP,
    unread_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_conversation (user_id, other_user_id),
    INDEX idx_user_time (user_id, last_message_time DESC)
);
```

### 消息表 (messages)
```sql
CREATE TABLE messages (
    id BIGINT PRIMARY KEY AUTO_INCREMENT,
    msg_id VARCHAR(100) UNIQUE NOT NULL,
    from_user_id VARCHAR(50) NOT NULL,
    to_user_id VARCHAR(50) NOT NULL,
    msg_content TEXT,
    msg_format INT DEFAULT 1,
    msg_status INT DEFAULT 1,
    msg_create_time TIMESTAMP,
    withdraw_status INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_from_user (from_user_id, msg_create_time DESC),
    INDEX idx_to_user (to_user_id, msg_create_time DESC)
);
```

## 实现要点

1. **实时性**: 使用 WebSocket 长连接实现实时推送
2. **性能**: 会话列表按时间排序，支持分页
3. **一致性**: 消息发送时同步更新会话列表
4. **可靠性**: 消息状态跟踪，支持重发机制
5. **扩展性**: 支持群聊、文件消息等扩展功能

## 测试数据

可以使用以下测试数据来验证功能：

```json
{
  "conversations": [
    {
      "name": "Alice",
      "headImage": "assets/other_headImage.png",
      "lastMessage": "Hello, how are you?",
      "timestamp": "2024-08-15T10:00:00Z",
      "userId": "222",
      "unreadCount": 2
    },
    {
      "name": "Bob", 
      "headImage": "assets/other_headImage.png",
      "lastMessage": "Are we still meeting today?",
      "timestamp": "2024-08-15T09:45:00Z",
      "userId": "333",
      "unreadCount": 0
    },
    {
      "name": "Charlie",
      "headImage": "assets/other_headImage.png", 
      "lastMessage": "Please review the document I sent.",
      "timestamp": "2024-08-15T09:30:00Z",
      "userId": "444",
      "unreadCount": 1
    }
  ]
}
```
