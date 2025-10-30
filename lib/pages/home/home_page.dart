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

  final List<String> _tabs = ['首页', '热门'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  void _onScroll(double offset) {
    final delta = offset - _lastOffset;
    if (delta.abs() < 5) return; // 微小滚动不触发
    if (delta > 5 && _showSearchBar.value) _showSearchBar.value = false;
    if (delta < -5 && !_showSearchBar.value) _showSearchBar.value = true;
    _lastOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: DefaultTabController(
          length: _tabs.length,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              // 搜索栏
              SliverToBoxAdapter(child: _buildAnimatedSearchBar()),
              // TabBar 吸顶
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(tabBar: _buildTopTabBar()),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) => TabContent(tab, onScroll: _onScroll)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  /// 弹性阻尼搜索栏动画
  Widget _buildAnimatedSearchBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSearchBar,
      builder: (context, show, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offsetAnimation = Tween<Offset>(
              begin: const Offset(0, -0.05),
              end: Offset.zero,
            ).animate(animation);
            return SlideTransition(
              position: offsetAnimation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: show
              ? _buildSearchBar()
              : const SizedBox.shrink(key: ValueKey('hidden')),
        );
      },
    );
  }

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
}

/// 高性能 Tab 内容
class TabContent extends StatefulWidget {
  final String tabName;
  final ValueChanged<double>? onScroll;
  const TabContent(this.tabName, {this.onScroll, super.key});

  @override
  State<TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification && notification.metrics.axis == Axis.vertical) {
          widget.onScroll?.call(notification.metrics.pixels);
        }
        return false;
      },
      child: ListView.builder(
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
                '${widget.tabName} 内容 ${index + 1}',
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
      ),
    );
  }
}

/// TabBar吸顶委托
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
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) => false;
}
