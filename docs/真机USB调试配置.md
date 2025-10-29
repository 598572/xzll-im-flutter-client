# 真机USB调试网络配置指南 📱

## 问题说明

**误区**：通过USB连接手机到Android Studio，以为可以直接访问电脑的服务

**实际情况**：
- ✅ USB连接：用于应用部署和日志调试
- ❌ 网络请求：仍然走手机的WiFi/移动数据网络

**结果**：如果手机和电脑不在同一WiFi，手机无法访问电脑的局域网IP

## 三种解决方案

### 方案A：手机和电脑连同一WiFi ⭐推荐

**最简单、最稳定的方案**

#### 步骤：

1. **让手机连接到和Mac一样的WiFi**
   - Mac当前WiFi：（查看Mac的WiFi名称）
   - 手机：连接到同一个WiFi

2. **保持USB连接**
   - USB用于调试和查看日志

3. **确认配置正确**
   ```dart
   // lib/constant/app_config_env.dart
   factory ServerConfig.development() => const ServerConfig(
     host: '10.66.253.227',  // Mac的局域网IP
     httpPort: 8081,
     wsPort: 10001,
     // ...
   );
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

#### 优点：
- ✅ 最稳定
- ✅ 最简单
- ✅ 支持所有功能
- ✅ 适合日常开发

#### 缺点：
- ⚠️ 需要手机和电脑在同一WiFi

---

### 方案B：ADB反向端口转发 🔧

**无需改WiFi，通过USB转发端口**

#### 原理：
使用 `adb reverse` 命令，让手机通过USB访问电脑的端口

#### 步骤：

1. **确保USB连接并启用调试**
   ```bash
   adb devices
   ```
   应该看到你的设备

2. **设置端口转发**
   ```bash
   # 转发HTTP端口
   adb reverse tcp:8081 tcp:8081
   
   # 转发WebSocket端口
   adb reverse tcp:10001 tcp:10001
   
   # 验证转发
   adb reverse --list
   ```

3. **修改配置使用localhost**
   ```dart
   // lib/constant/app_config_env.dart
   factory ServerConfig.development() => const ServerConfig(
     host: 'localhost',      // 使用localhost
     httpPort: 8081,
     wsPort: 10001,
     // ...
   );
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

#### 工作原理：
```
手机请求 localhost:8081
    ↓
通过USB转发
    ↓
Mac的 localhost:8081
```

#### 优点：
- ✅ 无需WiFi
- ✅ 无需网络配置
- ✅ 适合移动办公

#### 缺点：
- ⚠️ 每次重新连接需要重新设置
- ⚠️ 拔USB后失效
- ⚠️ 需要记得设置转发

#### 取消转发：
```bash
# 取消所有转发
adb reverse --remove-all
```

---

### 方案C：使用远程测试服务器 🌐

**最省事的方案**

#### 步骤：

1. **修改默认环境**
   ```dart
   // lib/constant/app_config.dart
   static const AppEnvironment environment = AppEnvironment.testing;
   ```

2. **运行应用**
   ```bash
   flutter run
   ```

3. **应用会连接到**
   ```
   http://120.46.85.43:80
   ws://120.46.85.43:80
   ```

#### 优点：
- ✅ 无需配置网络
- ✅ 任何设备都能用
- ✅ 立即可用

#### 缺点：
- ⚠️ 需要网络连接
- ⚠️ 可能有延迟
- ⚠️ 不适合调试后端

---

## 快速对比

| 方案 | 需要WiFi | 需要USB | 配置复杂度 | 稳定性 | 适用场景 |
|------|---------|---------|-----------|--------|---------|
| A. 同一WiFi | ✅ 是 | 可选 | ⭐ 简单 | ⭐⭐⭐ | 日常开发 |
| B. ADB转发 | ❌ 否 | ✅ 是 | ⭐⭐ 中等 | ⭐⭐ | 移动办公 |
| C. 远程服务器 | 网络即可 | 可选 | ⭐ 简单 | ⭐⭐ | 快速测试 |

## 推荐流程

### 当前（立即可用）
使用**方案C - 远程服务器**
```bash
# 已配置，直接运行
flutter run
```

### 长期开发
使用**方案A - 同一WiFi**
- 让手机连Mac的WiFi
- 修改配置回 `development` 环境

### 特殊场景（外出、没WiFi）
使用**方案B - ADB转发**
```bash
adb reverse tcp:8081 tcp:8081
adb reverse tcp:10001 tcp:10001
```

## 验证方法

### 验证手机和Mac在同一网络
```bash
# 在Mac上运行，查看IP
ifconfig | grep "inet " | grep -v 127.0.0.1

# 在手机浏览器访问
http://你的Mac-IP:8081/actuator/health
```

### 验证ADB转发
```bash
# 查看转发列表
adb reverse --list

# 应该看到
# tcp:8081 -> tcp:8081
# tcp:10001 -> tcp:10001
```

## 常见问题

### Q: USB连接了为什么还要WiFi？
A: USB只用于部署和调试，网络请求走的是WiFi/移动数据

### Q: 能不能让网络也走USB？
A: 可以！使用 `adb reverse` 端口转发（方案B）

### Q: 哪种方案最好？
A: 
- 日常开发：方案A（同一WiFi）
- 外出无WiFi：方案B（ADB转发）
- 快速测试：方案C（远程服务器）

### Q: ADB转发设置一次永久有效吗？
A: 否，每次重新连接USB需要重新设置

### Q: 能不能写个脚本自动设置ADB转发？
A: 可以！创建 `setup_adb.sh`：
```bash
#!/bin/bash
echo "设置ADB端口转发..."
adb reverse tcp:8081 tcp:8081
adb reverse tcp:10001 tcp:10001
adb reverse --list
echo "完成！"
```

---

现在你明白为什么连不上了吧？赶紧让手机连上Mac的WiFi，或者先用远程服务器测试！🚀

