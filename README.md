# 蝎子莱莱爱打怪开源的 im项目 (客户端)

由于找不到合适的app端同学，所以我决定自己写这款 即时通讯app的相关代码😄

[flutter中文官方文档戳这里](https://doc.flutterchina.club/get-started/] )

此客户端使用flutter语言开发，利用其跨平台的特性（只需掌握一种编程语言（Dart），就可以为多个平台开发应用），从而降低开发成本。

由于刚接触flutter和dart ，有些高级特性根本不会，不过没关系，一点点来吧。

## 开发版本

flutter：3.35.4
gradle：8.12

## 启动

同步依赖，需要魔法

```sh
flutter clean
flutter pub get
```

### ios

```sh
cd ios
pod install --verbose
```

### android

1. 打开/android目录
2. 右上角点击`小象`同步依赖