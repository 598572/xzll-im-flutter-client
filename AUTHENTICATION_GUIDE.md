# 蝎聊IM客户端 - 认证和会话管理指南

## 功能概述

本项目已经成功集成了完整的用户认证和会话管理系统，包括：

### ✅ 已完成功能

1. **用户认证系统**
   - 用户注册
   - 用户登录
   - Token管理（自动刷新）
   - 用户登出
   - 本地状态持久化

2. **界面和交互**
   - 现代化的登录界面
   - 用户注册界面
   - 主界面重构（包含个人中心）
   - 启动页面和自动登录检查

3. **会话管理**
   - 会话列表服务
   - 真实API调用（带降级到模拟数据）
   - 下拉刷新功能
   - WebSocket集成（用于实时消息）

## 文件结构

```
lib/
├── models/
│   ├── user.dart              # 用户模型和认证数据模型
│   ├── conversation.dart      # 会话模型
│   └── message.dart          # 消息模型
├── services/
│   ├── auth_service.dart      # 认证服务（单例）
│   ├── conversation_service.dart  # 会话服务
│   └── websocket_service.dart # WebSocket服务
├── screens/
│   ├── login_screen.dart      # 登录界面
│   ├── register_screen.dart   # 注册界面
│   ├── home_screen.dart       # 主界面（含个人中心）
│   ├── recent_conversations_screen.dart  # 会话列表
│   └── chat_screen.dart       # 聊天界面
└── main.dart                  # 应用入口（含认证检查）
```

## API 接口配置

### 认证相关接口

1. **用户注册**
   - URL: `POST /im-auth/user/register`
   - 请求体: `{ "userName", "password", "phone", "sex", "registerTerminalType" }`

2. **用户登录**
   - URL: `POST /im-auth/oauth/token`
   - 表单数据: `grant_type=password&client_id=client-app&client_secret=123456&username=xxx&password=xxx&device_type=1`

3. **Token验证**
   - URL: `POST /im-auth/oauth/validate?token=xxx`
   - 请求体: `{ "token", "deviceType" }`

4. **Token刷新**
   - URL: `POST /im-auth/oauth/refresh`
   - 请求体: `{ "refreshToken", "deviceType" }`

5. **用户登出**
   - URL: `POST /im-auth/oauth/logout`
   - 请求头: `Authorization: Bearer {token}`
   - 请求体: `{ "userId", "deviceType" }`

### 会话相关接口

1. **获取会话列表**
   - URL: `POST /hbase/test/send`
   - 请求头: `Authorization: Bearer {token}`
   - 请求体: `{ "userId", "currentPage", "pageSize" }`

## 使用说明

### 1. API地址配置

在以下文件中修改API基础地址：

```dart
// lib/services/auth_service.dart
static const String _baseUrl = 'http://localhost:8081'; // 认证服务地址

// lib/services/conversation_service.dart  
static const String _baseUrl = 'http://localhost:8083'; // 会话服务地址
```

### 2. 运行应用

```bash
# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 3. 测试流程

1. **首次启动**：显示登录界面
2. **注册新用户**：点击"注册新账号"
3. **登录**：使用注册的用户名和密码登录
4. **查看会话**：登录后自动显示会话列表
5. **个人中心**：点击底部"我"查看个人信息和退出登录

### 4. 功能特性

- **自动登录**：应用启动时检查本地登录状态
- **Token管理**：自动刷新过期的Token
- **错误处理**：网络异常时显示友好提示
- **降级处理**：真实API不可用时使用模拟数据
- **持久化**：用户登录状态本地保存

## 开发注意事项

1. **设备类型**：当前默认使用Android设备类型(1)，iOS设备可修改为(2)
2. **网络权限**：确保应用有网络访问权限
3. **HTTPS**：生产环境建议使用HTTPS协议
4. **错误处理**：所有网络请求都有完善的错误处理机制
5. **日志输出**：开发时会输出详细的调试日志

## 后续开发建议

1. **通讯录功能**：实现好友列表和添加好友
2. **群聊功能**：支持群组会话
3. **消息类型**：扩展支持图片、语音、视频等
4. **推送通知**：集成Firebase或其他推送服务
5. **安全增强**：添加生物识别、设备绑定等安全功能

## 故障排除

### 常见问题

1. **登录失败**
   - 检查API地址配置
   - 确认用户名密码正确
   - 查看网络连接状态

2. **会话列表为空**
   - 检查Token是否有效
   - 确认会话API地址正确
   - 查看是否有模拟数据降级

3. **WebSocket连接失败**
   - 不影响基本功能使用
   - 只影响实时消息接收
   - 检查WebSocket服务器状态

### 调试技巧

- 开启Flutter调试模式查看详细日志
- 使用网络抓包工具检查API调用
- 查看应用日志了解错误详情

---

## 联系支持

如有问题，请查看代码注释或联系开发团队。
