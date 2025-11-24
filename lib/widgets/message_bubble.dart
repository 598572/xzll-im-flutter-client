import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/models/domain/chat_message.dart';
import 'package:xzll_im_flutter_client/models/enum/message_enum.dart';

/// 消息气泡组件
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final VoidCallback? onRetry;
  final String? myAvatarUrl;      // 我的头像URL
  final String? otherAvatarUrl;   // 对方头像URL
  final String? otherDisplayName; // 对方显示名称

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.onRetry,
    this.myAvatarUrl,
    this.otherAvatarUrl,
    this.otherDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 4,
        bottom: 4,
        left: isMe ? 80 : 16,
        right: isMe ? 16 : 80,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                _buildMessageBubble(context),
                const SizedBox(height: 2),
                _buildMessageInfo(),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final avatarUrl = isMe ? myAvatarUrl : otherAvatarUrl;
    final displayName = isMe ? '我' : (otherDisplayName ?? '对');
    
    return CircleAvatar(
      radius: 18,
      backgroundColor: isMe ? Colors.blue[100] : Colors.grey[300],
      backgroundImage: avatarUrl?.isNotEmpty == true
          ? NetworkImage(avatarUrl!)
          : null,
      child: avatarUrl?.isEmpty != false
          ? Text(
              displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.blue[700] : Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildMessageBubble(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (message.status == MessageStatus.fail && onRetry != null) {
          onRetry!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[500] : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message.content,
                style: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
            if (isMe && message.status == MessageStatus.fail) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.error_outline,
                color: Colors.red.shade300,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.timestamp),
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _buildMessageStatus(),
        ],
      ],
    );
  }

  Widget _buildMessageStatus() {
    switch (message.status) {
      case MessageStatus.sending:
        // 发送中状态 - 显示转圈
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        );
      case MessageStatus.serverReceived:
      case MessageStatus.offLine:
      case MessageStatus.unRead:
        // 服务器已接收、离线、未读状态 - 显示中文"未读"
        return Text(
          "未读",
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        );
      case MessageStatus.readed:
        // 已读状态 - 显示中文"已读"
        return Text(
          "已读",
          style: TextStyle(
            fontSize: 10,
            color: Colors.blue[600],
          ),
        );
      case MessageStatus.fail:
        // 发送失败状态 - 显示红色叹号（类似微信）
        return GestureDetector(
          onTap: onRetry,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.priority_high,
              size: 10,
              color: Colors.white,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // 今天，只显示时间
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // 昨天
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // 其他日期
      return '${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}