import 'package:flutter/material.dart';
import 'package:rxdart_flutter/rxdart_flutter.dart';
import 'package:xzll_im_flutter_client/constant/app_event.dart';
import 'package:xzll_im_flutter_client/models/enum/web_socket_status.dart';

class WebSocketStatusWidget extends StatelessWidget {
  const WebSocketStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: ValueStreamBuilder(
        stream: AppEvent.webSocketStatus,
        builder: (BuildContext context, WebSocketStatus value, Widget? child) {
          IconData iconData;
          Color iconColor;
          String tooltip = "";
          switch (value) {
            case WebSocketStatus.connected:
              iconData = Icons.cloud_done;
              iconColor = Colors.green;
              tooltip = "已连接";
              break;
            case WebSocketStatus.connecting:
              iconData = Icons.cloud_upload;
              iconColor = Colors.orange;
              tooltip = "连接中";
              break;
            case WebSocketStatus.disconnected:
              iconData = Icons.cloud_off;
              iconColor = Colors.red;
              tooltip = "未连接";
              break;
            case WebSocketStatus.reconnecting:
              iconData = Icons.cloud_circle;
              iconColor = Colors.blue;
              tooltip = "重连中";
              break;
          }
          return Tooltip(
            message: tooltip,
            child: Icon(iconData, color: iconColor, size: 20),
          );
        },
        child: SizedBox(),
      ),
    );
  }
}
