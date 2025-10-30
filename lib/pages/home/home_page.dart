import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _showSearchBar = ValueNotifier(true);
  double _lastOffset = 0.0;
  DateTime _lastScrollTime = DateTime.now();

  final List<String> _tabs = ['首页', '热门'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _onScroll(double offset) {
    final now = DateTime.now();
    if (now.difference(_lastScrollTime).inMilliseconds < 100) return; // 节流100ms
    _lastScrollTime = now;

    if (offset - _lastOffset > 5 && _showSearchBar.value) {
      _showSearchBar.value = false;
    } else if (_lastOffset - offset > 5 && !_showSearchBar.value) {
      _showSearchBar.value = true;
    }
    _lastOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) {
            return [
              SliverToBoxAdapter(child: _buildAnimatedSearchBar()),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  tabBar: _buildTopTabBar(),
                ),
              ),
            ];
          },
          body: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  notification.metrics.axis == Axis.vertical) {
                _onScroll(notification.metrics.pixels);
              }
              return false;
            },
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ 搜索栏动画（使用 AnimatedSwitcher）
  Widget _buildAnimatedSearchBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSearchBar,
      builder: (context, show, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) =>
              SizeTransition(sizeFactor: animation, child: child),
          child: show
              ? _buildSearchBar()
              : const SizedBox.shrink(key: ValueKey('hidden')),
        );
      },
    );
  }

  /// ✅ 顶部搜索框
  Widget _buildSearchBar() {
    return Container(
      key: const ValueKey('searchBar'),
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text('搜索内容...', style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// ✅ 顶部 TabBar
  TabBar _buildTopTabBar() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey,
      dividerColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      indicatorColor: Colors.purple,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(
          color: Colors.purple.shade200,
          width: 7,
        ),
        insets: const EdgeInsets.only(bottom: 15),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
    );
  }

  /// ✅ Tab 内容
  Widget _buildTabContent(String tabName) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: 30,
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
              child: Icon(Icons.image, color: Theme.of(context).primaryColor),
            ),
            title: Text(
              '$tabName 内容 ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: const Text(
              '这是一段描述文字，展示列表项的详细信息...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
          ),
        );
      },
    );
  }
}

/// ✅ 自定义 SliverPersistentHeaderDelegate，使 TabBar 可吸顶
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate({required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}
