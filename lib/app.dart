import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'common/widgets/main_navigation.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // 设置全局 AppBar 样式
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // 状态栏透明
            statusBarIconBrightness: Brightness.dark, // 状态栏图标深色
            statusBarBrightness: Brightness.light,
          ),
        ),
        // 设置全局脚手架背景色
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const MainNavigation(),
    );
  }
}