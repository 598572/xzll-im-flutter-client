# 蝎聊 Flutter 项目结构

## 目录结构说明

```
lib/
├── main.dart                           # 应用程序入口
├── main_backup.dart                    # 原始main.dart的备份
├── models/                             # 数据模型
│   ├── conversation.dart               # 会话模型
│   └── message.dart                    # 消息模型（包含MessageType和MessageStatus枚举）
├── screens/                            # 页面/屏幕
│   ├── home_screen.dart                # 主页（底部导航栏）
│   ├── recent_conversations_screen.dart # 最近会话列表
│   └── chat_screen.dart                # 聊天窗口
├── services/                           # 服务层
│   └── websocket_service.dart          # WebSocket服务
├── widgets/                            # 可复用组件
│   └── message_bubble.dart             # 消息气泡组件
└── utils/                              # 工具类
    └── time_utils.dart                 # 时间工具类
```

## 代码分离说明

### 1. 模型层 (models/)
- **message.dart**: 包含消息相关的数据模型和枚举
  - `MessageType`: 消息类型枚举（文本、图片、语音、系统）
  - `MessageStatus`: 消息状态枚举（发送中、已发送、已送达、已读、失败）
  - `ChatMessage`: 聊天消息模型类

- **conversation.dart**: 会话相关的数据模型
  - `Conversation`: 会话模型类

### 2. 服务层 (services/)
- **websocket_service.dart**: WebSocket通信服务
  - 单例模式管理WebSocket连接
  - 处理消息发送、接收、确认等逻辑
  - 管理消息ID获取和状态更新

### 3. 页面层 (screens/)
- **home_screen.dart**: 主页面，包含底部导航栏
- **recent_conversations_screen.dart**: 最近会话列表页面
- **chat_screen.dart**: 聊天窗口页面

### 4. 组件层 (widgets/)
- **message_bubble.dart**: 消息气泡组件
  - 可复用的消息显示组件
  - 包含消息状态图标显示逻辑

### 5. 工具层 (utils/)
- **time_utils.dart**: 时间相关工具函数
  - 时间格式化等通用方法

## 优势

1. **代码分离**: 每个文件职责单一，便于维护
2. **可复用性**: 组件和服务可以在多个地方复用
3. **可测试性**: 分离的代码更容易进行单元测试
4. **可扩展性**: 新功能可以按模块添加，不影响现有代码
5. **团队协作**: 不同开发者可以同时开发不同模块

## 使用说明

1. 原始代码已备份到 `main_backup.dart`
2. 新的 `main.dart` 只包含应用入口和主题配置
3. 所有功能模块都已分离到对应目录
4. 导入路径已正确配置，可以直接运行
