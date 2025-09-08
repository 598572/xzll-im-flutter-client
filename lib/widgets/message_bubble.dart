import 'package:flutter/material.dart';
import '../models/message.dart';
import '../utils/time_utils.dart';

// 消息气泡组件
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              backgroundImage: AssetImage('assets/other_headImage.png'),
              radius: 20,
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.purple[300] : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        TimeUtils.formatTime(message.timestamp),
                        style: TextStyle(
                          color: isMe ? Colors.white70 : Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      if (isMe) ...[
                        SizedBox(width: 4),
                        _buildMessageStatus(message.status),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              backgroundImage: AssetImage('assets/my_headImage.png'),
              radius: 20,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageStatus(MessageStatus status) {
    Widget statusWidget;
    
    switch (status) {
      case MessageStatus.fail:
        // 发送失败：感叹号，红色
        statusWidget = Icon(
          Icons.error_outline,
          size: 12,
          color: Colors.red[500],
        );
        break;
      case MessageStatus.serverReceived:
        // 消息已送达服务器：小圆点加载动画，灰色（发送中状态）
        statusWidget = Container(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        );
        break;
      case MessageStatus.offLine:
        // 离线：单勾，灰色
        statusWidget = Icon(
          Icons.check,
          size: 12,
          color: Colors.grey[500],
        );
        break;
      case MessageStatus.unRead:
        // 未读：双勾，灰色
        statusWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 10,
              color: Colors.grey[500],
            ),
            Icon(
              Icons.check,
              size: 10,
              color: Colors.grey[500],
            ),
          ],
        );
        break;
      case MessageStatus.readed:
        // 已读：双勾，蓝色
        statusWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 10,
              color: Colors.blue[600],
            ),
            Icon(
              Icons.check,
              size: 10,
              color: Colors.blue[600],
            ),
          ],
        );
        break;
    }
    
    return Container(
      margin: EdgeInsets.only(left: 4),
      child: statusWidget,
    );
  }
}
