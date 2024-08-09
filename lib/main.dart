import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:web_socket_channel/io.dart";
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

/*
xzll-im的客户端，使用flutter编写，目前都搞到一个类 后期 在拆分
 */
void main() => runApp(XzllImClient());

class XzllImClient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebSocketConnect(),
    );
  }
}

class WebSocketConnect extends StatefulWidget {
  @override
  _WebSocketConnectState createState() => _WebSocketConnectState();
}

class _WebSocketConnectState extends State<WebSocketConnect> {
  WebSocketChannel? channel;
  String ip = '172.30.129.244'; // WebSocket服务器的IP地址
  int port = 10001; // WebSocket服务器的端口号
  TextEditingController _controller = TextEditingController(); // 控制输入框的文本
  List<Map<String, dynamic>> messages = []; // 保存所有消息的列表，包括文本和图片
  final ImagePicker _picker = ImagePicker(); // 图片选择器实例
  final String myAvatar = 'assets/my_avatar.png'; // 本地用户头像
  final String otherAvatar = 'assets/other_avatar.png'; // 远程用户头像
  FlutterSoundRecorder? _recorder; // 声音录制器
  bool _isRecording = false; // 录制状态

  @override
  void initState() {
    super.initState();
    connectToWebSocket(); // 连接到WebSocket服务器
    _recorder = FlutterSoundRecorder();
    openRecorder(); // 打开录音机
  }

  // 打开录音机并请求权限
  Future<void> openRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }
    await _recorder!.openRecorder();
  }

  // 连接到WebSocket服务器
  void connectToWebSocket() {
    final headers = {
      'Connection': 'Upgrade',
      'Upgrade': 'websocket',
      // 'Sec-WebSocket-Extensions': 'permessage-deflate',
      'token': 't_value',
      'uid': '111',
    };

    channel = IOWebSocketChannel.connect(
      'ws://$ip:$port/websocket',
      headers: headers, // 传递自定义的请求头
    );
    channel!.stream.listen((message) {
      setState(() {
        messages.add({
          'message': message,
          'sender': 'other',
          'isImage': false,
          'isVoice': false
        }); // 收到消息后更新UI
      });
    });
  }

  // 发送文本消息
  void sendMessage(String message) {
    if (channel != null && message.isNotEmpty) {
      var imBaseRequest = {
        'msgType': {
          'firstLevelMsgType': 3,
          'secondLevelMsgType': 301,
        },
        'body': {
          'msgId': '111111',
          'msgContent': message,
          'chatId': '999',
          'toUserId': '222', // Replace with the actual user ID
          'fromUserId': '111', // Replace with the actual user ID
          'msgCreateTime': DateTime.now().millisecondsSinceEpoch,
        },
      };


      setState(() {
        messages.add({
          'message': imBaseRequest,
          'sender': 'me',
          'isImage': false,
          'isVoice': false
        }); // 添加到消息列表
      });
      // channel!.sink.add(jsonEncode({'message': imBaseRequest})); // 通过WebSocket发送消息
      String jsonMessage = jsonEncode(imBaseRequest);

      // 使用 WebSocket 发送消息
      channel?.sink.add(jsonMessage);  // 这相当于在 Java 中发送 TextWebSocketFrame
      print("Message sent: $jsonMessage");

      _controller.clear(); // 发送后清空输入框
    }
  }

  // 发送图片消息
  Future<void> sendImage() async {
    final pickedFile = await _picker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final encodedImage = base64Encode(bytes); // 将图片编码为Base64
      setState(() {
        messages.add({
          'message': encodedImage,
          'sender': 'me',
          'isImage': true,
          'isVoice': false
        }); // 添加到消息列表，标识为图片
      });
      channel!.sink.add(jsonEncode({'image': encodedImage})); // 发送图片
    }
  }

  // 录制并发送语音消息
  Future<void> recordVoice() async {
    if (_isRecording) {
      // 停止录音并发送
      final path = await _recorder!.stopRecorder();
      setState(() {
        _isRecording = false;
      });
      final bytes = await File(path!).readAsBytes();
      final encodedVoice = base64Encode(bytes); // 将音频编码为Base64
      setState(() {
        messages.add({
          'message': encodedVoice,
          'sender': 'me',
          'isImage': false,
          'isVoice': true
        }); // 添加到消息列表，标识为语音
      });
      channel!.sink.add(jsonEncode({'voice': encodedVoice})); // 发送语音
    } else {
      // 开始录音
      await _recorder!.startRecorder(
        codec: Codec.aacMP4,
      );
      setState(() {
        _isRecording = true;
      });
    }
  }

  // 显示选择框，包含发送图片和语音选项
  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 150,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('发送图片'),
                onTap: () {
                  Navigator.pop(context);
                  sendImage(); // 调用发送图片方法
                },
              ),
              ListTile(
                leading: Icon(Icons.mic),
                title: Text(_isRecording ? '停止录音' : '录制语音'),
                onTap: () {
                  Navigator.pop(context);
                  recordVoice(); // 调用录制语音方法
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    channel?.sink.close();
    _controller.dispose();
    _recorder?.closeRecorder();
    super.dispose();
  }

  // 聊天气泡Widget
  Widget _buildMessage(Map<String, dynamic> message) {
    bool isMe = message['sender'] == 'me';
    return Row(
      mainAxisAlignment: isMe
          ? MainAxisAlignment.end
          : MainAxisAlignment.start, // 根据发送者确定消息对齐方向
      children: [
        if (!isMe)
          CircleAvatar(
            backgroundImage: AssetImage(otherAvatar), // 显示远程用户头像
            radius: 20,
          ),
        SizedBox(width: 10),
        Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.6),
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
            base64Decode(message['message']), // 如果是图片，解码并显示图片
            width: 200, // 设置图片宽度
            height: 150, // 设置图片高度
            fit: BoxFit.cover, // 图片适应框的方式
          )
              : message['isVoice']
              ? Row(
            children: [
              Icon(Icons.play_arrow), // 语音播放按钮
              SizedBox(width: 5),
              Text("语音消息", style: TextStyle(color: isMe ? Colors.white : Colors.black)),
            ],
          )
              : Text(
            message['message'],
            style: TextStyle(
                color: isMe ? Colors.white : Colors.black),
          ),
        ),
        SizedBox(width: 10),
        if (isMe)
          CircleAvatar(
            backgroundImage: AssetImage(myAvatar), // 显示本地用户头像
            radius: 20,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('聊天'),
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
                  onPressed: _showMoreOptions,
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