import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SearchScrollPage extends StatefulWidget {
  const SearchScrollPage({super.key});

  @override
  State<SearchScrollPage> createState() => _SearchScrollPageState();
}

class _SearchScrollPageState extends State<SearchScrollPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _showSearchBar = ValueNotifier(true);
  late ScrollController _scrollController;

  final List<String> _tabs = ['推荐', '热门', '关注', '最新'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _scrollController = ScrollController();

    // 状态栏白色，图标黑色
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    // 监听滚动位置
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double searchBarHeight = 56; // 搜索栏完整高度（包括margin）
    final double threshold = searchBarHeight; // 当滚动超过搜索栏高度时隐藏

    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;

      // 向下滚动超过阈值，隐藏搜索栏
      if (offset > threshold && _showSearchBar.value) {
        _showSearchBar.value = false;
      }
      // 向上滚动回到顶部区域，显示搜索栏
      else if (offset <= threshold && !_showSearchBar.value) {
        _showSearchBar.value = true;
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
    _showSearchBar.dispose();
    super.dispose();
  }

  Widget _buildSearchBar(double topPadding) {
    return ValueListenableBuilder<bool>(
      valueListenable: _showSearchBar,
      builder: (context, show, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: show ? 40 : 0,
          curve: Curves.easeInOut,
          margin: EdgeInsets.fromLTRB(16, 8 + topPadding, 16, 8),
          decoration: BoxDecoration(
            color: Colors.grey[100], // 浅灰色背景区分白色
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: show
              ? TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              hintText: '搜索内容',
              hintStyle: const TextStyle(color: Colors.black38),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 0,
              ),
            ),
          )
              : null,
        );
      },
    );
  }

  Widget _buildListView(String label) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: 30,
      itemBuilder: (_, i) => Container(
        color: Colors.white,
        child: ListTile(title: Text('$label Item $i')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double searchBarHeight = 40;

    final double expandedHeight = statusBarHeight + searchBarHeight + 16;

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.red,
            expandedHeight: expandedHeight,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                return SizedBox(
                  height: constraints.maxHeight,
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSearchBar(statusBarHeight),
                        Container(
                          color: Colors.white,
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
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: _tabs.map((e) => _buildListView(e)).toList(),
        ),
      ),
    );
  }
}