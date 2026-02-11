import 'package:flutter/material.dart';
import 'package:xzll_im_sdk/xzll_im_sdk.dart';

/// XZLL IM SDK 使用示例页面
///
/// 这个页面演示了如何使用XZLL IM SDK的核心功能
class SDKDemoPage extends StatefulWidget {
  const SDKDemoPage({Key? key}) : super(key: key);

  @override
  State<SDKDemoPage> createState() => _SDKDemoPageState();
}

class _SDKDemoPageState extends State<SDKDemoPage> {
  // SDK客户端实例
  final XZLLIMClient _imClient = XZLLIMClient();

  // UI状态
  XZLLConnectionStatus _connectionStatus = XZLLConnectionStatus.disconnected;
  final List<String> _messageLog = [];
  final TextEditingController _userIdController = TextEditingController(text: '10001');
  final TextEditingController _tokenController = TextEditingController(text: 'your-token');
  final TextEditingController _toUserIdController = TextEditingController(text: '10002');
  final TextEditingController _messageController = TextEditingController(text: 'Hello from SDK!');

  /// 是否已连接
  bool get isConnected => _imClient.isConnected;

  @override
  void initState() {
    super.initState();
    _initSDK();
  }

  /// 初始化SDK
  void _initSDK() {
    // 1. 创建SDK配置
    final config = XZLLIMConfig.dev(
      appId: 'demo-app',
      baseUrl: 'http://192.168.1.150:8080',
      wsBaseUrl: 'ws://192.168.1.150:8081',
    );

    // 2. 初始化SDK
    _imClient.init(config);

    // 3. 监听连接状态
    _imClient.connectionStatusStream.listen((status) {
      setState(() {
        _connectionStatus = status;
      });
      _addLog('连接状态: ${_getStatusText(status)}');
    });

    // 4. 设置消息监听器
    _imClient.setMessageListener((message) {
      _addLog('📨 收到新消息:');
      _addLog('  发送人: ${message.fromUserId}');
      _addLog('  内容: ${message.content}');
      _addLog('  状态: ${message.status.desc}');
    });

    // 5. 设置消息状态监听器
    _imClient.setMessageStatusListener((messageId, status) {
      _addLog('✓ 消息状态变化:');
      _addLog('  消息ID: $messageId');
      _addLog('  状态码: $status');
    });

    _addLog('✅ SDK初始化完成');
  }

  /// 连接服务器
  Future<void> _connect() async {
    final userId = _userIdController.text.trim();
    final token = _tokenController.text.trim();

    if (userId.isEmpty || token.isEmpty) {
      _addLog('❌ 请输入用户ID和Token');
      return;
    }

    _addLog('🔗 开始连接服务器...');
    _addLog('  用户ID: $userId');

    await _imClient.connect(
      userId,
      token,
      '', // refreshToken暂时为空
      callback: (success, {errorMsg}) {
        if (success) {
          _addLog('✅ 连接成功');
        } else {
          _addLog('❌ 连接失败: $errorMsg');
        }
      },
    );
  }

  /// 断开连接
  void _disconnect() {
    _imClient.disconnect();
    _addLog('🔌 已断开连接');
  }

  /// 发送消息
  Future<void> _sendMessage() async {
    if (!isConnected) {
      _addLog('❌ 未连接到服务器');
      return;
    }

    final toUserId = _toUserIdController.text.trim();
    final content = _messageController.text.trim();

    if (toUserId.isEmpty || content.isEmpty) {
      _addLog('❌ 请输入接收人ID和消息内容');
      return;
    }

    _addLog('📤 发送消息...');
    _addLog('  接收人: $toUserId');
    _addLog('  内容: $content');

    await _imClient.sendTextMessage(
      toUserId,
      content,
      callback: (success, {clientMsgId, serverMsgId, errorMsg}) {
        if (success) {
          _addLog('✅ 消息已发送');
          _addLog('  客户端ID: $clientMsgId');
          _addLog('  服务器ID: $serverMsgId');
        } else {
          _addLog('❌ 发送失败: $errorMsg');
        }
      },
    );
  }

  /// 获取连接状态文本
  String _getStatusText(XZLLConnectionStatus status) {
    switch (status) {
      case XZLLConnectionStatus.disconnected:
        return '未连接';
      case XZLLConnectionStatus.connecting:
        return '连接中';
      case XZLLConnectionStatus.connected:
        return '已连接';
      case XZLLConnectionStatus.reconnecting:
        return '重连中';
    }
  }

  /// 添加日志
  void _addLog(String message) {
    setState(() {
      _messageLog.insert(0, '[${DateTime.now().toString().substring(11, 19)}] $message');
      // 只保留最近100条日志
      if (_messageLog.length > 100) {
        _messageLog.removeLast();
      }
    });
  }

  /// 清空日志
  void _clearLog() {
    setState(() {
      _messageLog.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('XZLL IM SDK 演示'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 连接状态指示器
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: isConnected ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(_connectionStatus),
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 连接配置卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '连接配置',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: '用户ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        labelText: 'Token',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.key),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isConnected ? null : _connect,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text('连接'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isConnected ? _disconnect : null,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('断开'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 发送消息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '发送消息',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _toUserIdController,
                      decoration: const InputDecoration(
                        labelText: '接收人ID',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _messageController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: '消息内容',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.message),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: isConnected ? _sendMessage : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('发送消息'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 日志卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '运行日志',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _clearLog,
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ListView.builder(
                        itemCount: _messageLog.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              _messageLog[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imClient.dispose();
    _userIdController.dispose();
    _tokenController.dispose();
    _toUserIdController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}
