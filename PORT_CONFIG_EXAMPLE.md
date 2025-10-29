# 端口配置示例 🔌

## HTTP和WebSocket使用不同端口

现在配置系统已支持HTTP和WebSocket使用不同的端口！

### 📝 配置示例

**文件**: `lib/constant/app_config_env.dart`

```dart
/// 开发环境配置
factory ServerConfig.development() => const ServerConfig(
  host: '120.46.85.43',
  httpPort: 80,          // HTTP API 端口
  wsPort: 8080,          // WebSocket 端口（不同！）
  useHttps: false,
  enableDebugLog: true,
  connectionTimeout: 30,
  receiveTimeout: 30,
  webSocketRetryCount: 5,
);
```

### 🌐 生成的URL

根据上面的配置，将生成：

- **HTTP URL**: `http://120.46.85.43:80`
  - 用于所有REST API调用
  - 登录、好友列表、搜索等接口

- **WebSocket URL**: `ws://120.46.85.43:8080`
  - 用于实时消息推送
  - 聊天消息、好友申请通知等

### 💡 常见配置场景

#### 场景1: HTTP和WebSocket使用相同端口
```dart
factory ServerConfig.development() => const ServerConfig(
  host: '120.46.85.43',
  httpPort: 80,
  wsPort: 80,        // 相同端口
  // ...
);
```
生成:
- HTTP: `http://120.46.85.43:80`
- WS: `ws://120.46.85.43:80`

#### 场景2: HTTP和WebSocket使用不同端口
```dart
factory ServerConfig.development() => const ServerConfig(
  host: '120.46.85.43',
  httpPort: 8080,
  wsPort: 9090,      // 不同端口
  // ...
);
```
生成:
- HTTP: `http://120.46.85.43:8080`
- WS: `ws://120.46.85.43:9090`

#### 场景3: 生产环境使用HTTPS/WSS
```dart
factory ServerConfig.production() => const ServerConfig(
  host: 'api.yourapp.com',
  httpPort: 443,
  wsPort: 443,
  useHttps: true,     // 使用HTTPS/WSS
  // ...
);
```
生成:
- HTTPS: `https://api.yourapp.com:443`
- WSS: `wss://api.yourapp.com:443`

### ✅ 已自动应用到

所有使用配置的文件会自动获取正确的端口：

- ✅ `websocket_service.dart` - 使用 `wsPort`
- ✅ `friend_service.dart` - 使用 `httpPort`
- ✅ `dio_client.dart` - 使用 `httpPort`
- ✅ 所有API调用 - 使用 `httpPort`

### 🎯 快速开始

1. **打开配置文件**: `lib/constant/app_config_env.dart`

2. **找到开发环境配置**:
   ```dart
   factory ServerConfig.development() => const ServerConfig(
   ```

3. **修改端口**:
   ```dart
   httpPort: 你的HTTP端口,    // 比如 80, 8080
   wsPort: 你的WebSocket端口,  // 比如 80, 9090
   ```

4. **保存并重新运行**:
   ```bash
   flutter run
   ```

就这么简单！所有地方会自动使用正确的端口。🎉

### 📋 验证配置

运行验证脚本查看当前配置：
```bash
./verify_config.sh
```

### ❓ 常见问题

**Q: 我的HTTP用80端口，WebSocket用9090端口，怎么配置？**
```dart
httpPort: 80,
wsPort: 9090,
```

**Q: 端口一样怎么办？**
```dart
httpPort: 80,
wsPort: 80,     // 设置相同即可
```

**Q: 需要重启应用吗？**
A: 是的，修改配置后需要重新运行 `flutter run`

**Q: 会影响现有代码吗？**
A: 不会！所有服务会自动使用新配置，无需修改任何业务代码。

