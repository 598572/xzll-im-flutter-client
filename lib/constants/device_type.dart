import 'dart:io';

/// 设备类型枚举
enum DeviceType {
  android(1, "android"),
  ios(2, "ios"),
  miniProgram(3, "小程序"),
  web(4, "web"),
  unknown(-1, "未知设备类型");

  const DeviceType(this.code, this.description);

  /// 设备类型代码
  final int code;
  
  /// 设备类型描述
  final String description;

  /// 获取当前设备类型
  static DeviceType get currentDeviceType {
    if (Platform.isAndroid) {
      return DeviceType.android;
    } else if (Platform.isIOS) {
      return DeviceType.ios;
    } else if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      return DeviceType.web; // 桌面平台当作web处理
    } else {
      return DeviceType.unknown;
    }
  }

  /// 根据代码获取设备类型
  static DeviceType fromCode(int code) {
    for (DeviceType type in DeviceType.values) {
      if (type.code == code) {
        return type;
      }
    }
    return DeviceType.unknown;
  }

  @override
  String toString() => description;
}
