// 设备类型枚举
import 'dart:io';

enum DeviceType {
  android(1, "Android"),
  ios(2, "iOS"),
  web(3, "Web"),
  desktop(4, "Desktop");

  const DeviceType(this.code, this.name);

  final int code;
  final String name;

  static DeviceType get currentDeviceType {
    if (Platform.isAndroid) {
      return DeviceType.android;
    } else if (Platform.isIOS) {
      return DeviceType.ios;
    } else {
      return DeviceType.desktop;
    }
  }
}
