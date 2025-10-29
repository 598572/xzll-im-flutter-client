# 开发环境IP配置说明 🔧

## 📱 127.0.0.1 的问题

### ❌ 错误配置

```dart
host: '127.0.0.1',  // 这在Android模拟器/真机上不工作！
```

**为什么不工作？**
- `127.0.0.1` 是**本地回环地址**
- 在Android设备/模拟器上，`127.0.0.1` 指向的是**设备本身**，而不是你的开发电脑
- 所以会出现 `Connection refused` 错误

### ✅ 正确配置

```dart
host: '10.66.253.227',  // 你的开发电脑的局域网IP
```

## 🎯 如何获取正确的IP地址

### macOS / Linux
```bash
# 方法1：使用ifconfig
ifconfig | grep "inet " | grep -v 127.0.0.1

# 方法2：快速获取
ifconfig en0 | grep "inet " | awk '{print $2}'
```

### Windows
```cmd
ipconfig
```
查找 `IPv4 地址`，通常是 `192.168.x.x` 或 `10.x.x.x`

## 📊 不同场景的配置

### 场景1: 本地开发（模拟器/真机）

**后端服务运行在你的电脑上**

```dart
factory ServerConfig.development() => const ServerConfig(
  host: '10.66.253.227',    // ✅ 使用你电脑的局域网IP
  httpPort: 8081,
  wsPort: 10001,
  // ...
);
```

**生成的URL**:
- HTTP: `http://10.66.253.227:8081`
- WebSocket: `ws://10.66.253.227:10001`

### 场景2: 连接远程服务器

**后端服务运行在远程服务器上**

```dart
factory ServerConfig.development() => const ServerConfig(
  host: '120.46.85.43',     // ✅ 远程服务器IP
  httpPort: 80,
  wsPort: 80,
  // ...
);
```

**生成的URL**:
- HTTP: `http://120.46.85.43:80`
- WebSocket: `ws://120.46.85.43:80`

### 场景3: iOS模拟器

**iOS模拟器可以直接使用 localhost**

```dart
factory ServerConfig.development() => const ServerConfig(
  host: 'localhost',        // ✅ iOS模拟器支持
  httpPort: 8081,
  wsPort: 10001,
  // ...
);
```

## 🔄 使用Android模拟器的特殊地址

如果你使用的是Android模拟器（不是真机），还有一个特殊选择：

```dart
factory ServerConfig.development() => const ServerConfig(
  host: '10.0.2.2',         // Android模拟器专用：指向宿主机的127.0.0.1
  httpPort: 8081,
  wsPort: 10001,
  // ...
);
```

**注意**: `10.0.2.2` 只在Android模拟器上工作，真机上不行！

## 📝 当前配置

根据你的网络环境，当前已配置：

```dart
/// 开发环境 - 本地后端服务
factory ServerConfig.development() => const ServerConfig(
  host: '10.66.253.227',    // 本机局域网IP
  httpPort: 8081,           // gateway端口
  wsPort: 10001,            // WebSocket端口
  // ...
);

/// 测试环境 - 远程服务器
factory ServerConfig.testing() => const ServerConfig(
  host: '120.46.85.43',     // 远程服务器
  httpPort: 80,
  wsPort: 80,
  // ...
);
```

## 🚀 快速切换

### 开发时（连接本地服务）
```bash
flutter run  # 使用默认的 development 环境
```

### 测试时（连接远程服务器）
```bash
flutter run --dart-define=ENVIRONMENT=testing
```

## ⚠️ 常见错误

### 错误1: Connection refused
```
Connection refused
```
**原因**: 使用了 `127.0.0.1`  
**解决**: 改为局域网IP

### 错误2: 无法访问
```
Failed to connect to /10.66.253.227:8081
```
**原因**: 
- 后端服务未启动
- 防火墙阻止
- IP地址错误

**检查**:
```bash
# 检查后端服务是否运行
curl http://10.66.253.227:8081/health

# 检查端口是否开放
telnet 10.66.253.227 8081
```

### 错误3: IP地址变化
**原因**: WiFi网络变化导致IP地址改变  
**解决**: 重新获取IP并更新配置

## 💡 最佳实践

1. **开发环境**: 使用局域网IP或Android模拟器专用地址 `10.0.2.2`
2. **测试环境**: 使用固定的远程服务器IP
3. **生产环境**: 使用域名而不是IP

## 🔧 快速诊断

运行以下命令检查网络配置：

```bash
# 1. 获取本机IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# 2. 测试后端服务
curl http://你的IP:8081/

# 3. 测试从手机访问（确保手机和电脑在同一WiFi）
# 在手机浏览器访问: http://你的IP:8081/
```

## 📱 真机调试注意事项

1. **确保设备和电脑在同一WiFi网络**
2. **关闭电脑防火墙或允许端口访问**
3. **使用局域网IP，不要用127.0.0.1**

---

现在重新运行应用，应该就能正常连接了！🎉

