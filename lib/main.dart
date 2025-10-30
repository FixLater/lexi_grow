import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

void main() {
  // 在 runApp 之前设置
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.white, // 状态栏背景色
    statusBarIconBrightness: Brightness.dark, // 状态栏图标颜色（暗色）
    systemNavigationBarColor: Colors.white, // 导航栏背景色
    systemNavigationBarIconBrightness: Brightness.dark, // 导航栏图标颜色
  ));

  runApp(const MyApp());
}