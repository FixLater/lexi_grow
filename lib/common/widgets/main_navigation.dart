import 'package:flutter/material.dart';
import '../../pages/home/home_page.dart';
import '../../pages/mine/mine_page.dart';

/// 导航项配置类
class NavigationItem {
  final Widget page;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavigationItem({
    required this.page,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// 主导航组件
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // 导航项配置列表 - 在这里添加或删除导航项
  final List<NavigationItem> _navigationItems = const [
    NavigationItem(
      page: HomePage(),
      label: '首页',
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
    ),
    NavigationItem(
      page: MinePage(),
      label: '我的',
      icon: Icons.person_outline,
      activeIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.page).toList(),
      ),
      bottomNavigationBar: _buildCustomBottomNavigationBar(),
    );
  }

  /// 自定义底部导航栏 - 限制点击区域
  Widget _buildCustomBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60, // 增加高度以容纳边距
          child: Row(
            children: List.generate(_navigationItems.length, (index) {
              return Expanded(
                child: _buildNavigationItem(index),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// 构建单个导航项 - 添加水波纹效果并限制边界
  Widget _buildNavigationItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _currentIndex == index;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        // 配置水波纹效果
        highlightColor: Theme.of(context).primaryColor.withOpacity(0.2),
        splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        // 关键：限制水波纹效果不超出边界
        child: Container(
          margin: const EdgeInsets.all(4), // 统一的边距
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? item.activeIcon : item.icon,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 2), // 减少间距
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 11, // 稍微减小字体大小
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}