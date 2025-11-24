import 'package:flutter/material.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';

/// 网络状态横幅组件 - 类似微信的网络连接提示
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WebSocketStatus>(
      stream: AppEvent.webSocketStatus.stream,
      initialData: AppEvent.webSocketStatus.value,
      builder: (context, snapshot) {
        final status = snapshot.data ?? WebSocketStatus.disconnected;
        
        // 只在非连接状态时显示横幅
        if (status == WebSocketStatus.connected) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 1),
                blurRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getStatusMessage(status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 获取状态颜色
  Color _getStatusColor(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.disconnected:
        return Colors.red.shade600;
      case WebSocketStatus.connecting:
        return Colors.orange.shade600;
      case WebSocketStatus.reconnecting:
        return Colors.orange.shade600;
      case WebSocketStatus.connected:
        return Colors.green.shade600;
    }
  }

  /// 获取状态图标
  IconData _getStatusIcon(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.disconnected:
        return Icons.error_outline;
      case WebSocketStatus.connecting:
        return Icons.wifi_off_outlined;
      case WebSocketStatus.reconnecting:
        return Icons.refresh;
      case WebSocketStatus.connected:
        return Icons.wifi;
    }
  }

  /// 获取状态消息
  String _getStatusMessage(WebSocketStatus status) {
    switch (status) {
      case WebSocketStatus.disconnected:
        return '当前无法连接网络，请检查网络是否正常';
      case WebSocketStatus.connecting:
        return '正在连接...';
      case WebSocketStatus.reconnecting:
        return '网络连接中断，正在重连...';
      case WebSocketStatus.connected:
        return '网络连接正常';
    }
  }
}
