import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 顶部导航配置 - 可以在这里添加或删除
  final List<String> _tabs = [
    '首页',
    '热门',
    // 可以继续添加更多
    // '体育',
    // '游戏',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部导航栏
            _buildTopTabBar(),
            // 内容区域
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建顶部 TabBar
  Widget _buildTopTabBar() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.grey,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Colors.purple.shade200, // 直接使用淡紫色
            width: 7,
          ),
          insets: const EdgeInsets.only(bottom: 15), // 调整这个值
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  /// 构建 Tab 内容
  Widget _buildTabContent(String tabName) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), // 上边距改为8
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.image,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text(
              '$tabName 内容 ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: const Text(
              '这是一段描述文字，展示列表项的详细信息...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('点击了 $tabName 内容 ${index + 1}')),
              );
            },
          ),
        );
      },
    );
  }
}