import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:web_socket_channel/io.dart";
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

// 定义Conversation类
class Conversation {
  final String name;
  final String headImage;
  final String lastMessage;
  final String timestamp;

  Conversation({
    required this.name,
    required this.headImage,
    required this.lastMessage,
    required this.timestamp,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      name: json['name'],
      headImage: json['headImage'],
      lastMessage: json['lastMessage'],
      timestamp: json['timestamp'],
    );
  }
}

// 应用程序入口
void main() => runApp(const XzllImClient());

class XzllImClient extends StatelessWidget {
  const XzllImClient({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '蝎聊',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
    );
  }
}

// 主页屏幕，包含底部导航栏
class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  static  List<Widget> _widgetOptions = <Widget>[
    RecentConversationsScreen(),
    Text('通讯录', style: TextStyle(fontSize: 24)),
    Text('发现', style: TextStyle(fontSize: 24)),
    Text('我', style: TextStyle(fontSize: 24)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: '聊天',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            label: '通讯录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: '发现',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我',
          ),
        ],
        currentIndex: _selectedIndex,
        // selectedItemColor: Colors.green[700],
        selectedItemColor: Colors.purple, // 设置选中的颜色为紫色

        // selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,  // 确保未选中项的颜色不透明
        type: BottomNavigationBarType.fixed, // 设置为固定类型，未选中时也显示标签
        onTap: _onItemTapped,
      ),
    );
  }
}

// 最近会话列表界面
class RecentConversationsScreen extends StatelessWidget {
  Future<List<Conversation>> fetchConversations() async {
    // 模拟接口调用的延迟
    await Future.delayed(Duration(seconds: 2));

    // 假数据
    List<Map<String, dynamic>> fakeData = [
      {
        'name': 'Alice',
        'headImage': 'https://example.com/headImage/alice.png',
        'lastMessage': 'Hello, how are you?',
        'timestamp': '2024-08-15 10:00',
      },
      {
        'name': 'Bob',
        'headImage': 'https://example.com/headImage/bob.png',
        'lastMessage': 'Are we still meeting today?',
        'timestamp': '2024-08-15 09:45',
      },
      {
        'name': 'Charlie',
        'headImage': 'https://example.com/headImage/charlie.png',
        'lastMessage': 'Please review the document I sent.',
        'timestamp': '2024-08-15 09:30',
      },
    ];

    return fakeData.map((item) => Conversation.fromJson(item)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Conversation>>(
        future: fetchConversations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('加载会话失败'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('没有会话记录'));
          } else {
            List<Conversation> conversations = snapshot.data!;
            return ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(conversations[index].headImage),
                  ),
                  title: Text(conversations[index].name),
                  subtitle: Text(conversations[index].lastMessage),
                  trailing: Text(conversations[index].timestamp),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          conversation: conversations[index],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

// 聊天窗口
class ChatScreen extends StatefulWidget {
  final Conversation conversation;

  ChatScreen({required this.conversation});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  WebSocketChannel? channel;

  final TextEditingController _controller = TextEditingController(); // 控制输入框的文本
  List<Map<String, dynamic>> messages = []; // 保存所有消息的列表，包括文本和图片
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  FlutterSoundRecorder? _recorder; // 声音录制器
  bool _isRecording = false; // 录制状态

  @override
  void initState() {
    super.initState();
    connectToWebSocket(); // 连接到WebSocket服务器
    _recorder = FlutterSoundRecorder();
    openRecorder(); // 打开录音机
  }

  Future<void> openRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await _recorder!.openRecorder();
  }

  void connectToWebSocket() {
    final headers = {
      'Connection': 'Upgrade',
      'Upgrade': 'websocket',
      'token': 't_value',
      'uid': '111',
    };

    channel = IOWebSocketChannel.connect(
      'ws://192.168.1.101:10001/websocket',
      headers: headers, // 传递自定义的请求头
    );

    try {
      channel!.stream.listen((message) {
        var response = jsonDecode(message);
        setState(() {
          messages.add({
            'message': response,
            'sender': 'other',
            'isImage': false,
            'isVoice': false
          });
        });
      }, onError: (error) {
        print("WebSocket连接错误: $error");
      }, onDone: () {
        print("WebSocket连接关闭");
      });
    } catch (e) {
      print("WebSocket连接失败: $e");
    }
  }

  Future<String> getMsgId() async {
    // 获取 msgId 的逻辑
    return 'mock_msg_id';
  }

  void sendMessage(String message) async {
    if (channel != null && message.isNotEmpty) {
      String msgId = await getMsgId();
      var imBaseRequest = {
        'url': 'xzll/im/c2c/send',
        'body': {
          'msgId': msgId,
          'msgContent': message,
          'toUserId': '222',
          'fromUserId': '111',
          'msgCreateTime': DateTime.now().millisecondsSinceEpoch,
        },
      };

      setState(() {
        messages.add({
          'message': imBaseRequest,
          'sender': 'me',
          'isImage': false,
          'isVoice': false
        });
      });

      String jsonMessage = jsonEncode(imBaseRequest);
      channel?.sink.add(jsonMessage);
      _controller.clear();
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['sender'] == 'me';
    return Row(
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: AssetImage('assets/other_headImage.png'),
            radius: 20,
          ),
        SizedBox(width: 10),
        Container(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMe ? Colors.green[300] : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4.0,
                spreadRadius: 2.0,
              )
            ],
          ),
          child: message['isImage']
              ? Image.memory(
                  base64Decode(message['message']),
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                )
              : message['isVoice']
                  ? Row(
                      children: [
                        Icon(Icons.play_arrow),
                        SizedBox(width: 5),
                        Text("语音消息",
                            style: TextStyle(
                                color: isMe ? Colors.white : Colors.black)),
                      ],
                    )
                  : Text(
                      jsonEncode(message['message']),
                      style:
                          TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
        ),
        SizedBox(width: 10),
        if (isMe)
          CircleAvatar(
            backgroundImage: AssetImage('assets/my_headImage.png'),
            radius: 20,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.conversation.name),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildMessage(messages[index]),
                );
              },
            ),
          ),
          Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add_circle_outline),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration.collapsed(
                      hintText: '输入消息...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    sendMessage(_controller.text);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
