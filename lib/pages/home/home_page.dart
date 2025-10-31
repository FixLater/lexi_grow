import 'package:flutter/material.dart';
import '../../api/cloud_api.dart';
import 'package:dio/dio.dart';

import '../../model/tab_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ValueNotifier<bool> _showSearchBar = ValueNotifier(true);
  double _lastOffset = 0.0;

  final List<TabModel> _tabs = [
    TabModel("电视剧", "tv"),
    TabModel('电影', "movie"),
    TabModel('动漫', "anime"),
    TabModel('综艺', "variety"),
    TabModel('漫画', "comic"),
    TabModel('短剧', "short"),
    TabModel("电视剧", "tv"),
    TabModel('电影', "movie"),
    TabModel('动漫', "anime"),
    TabModel('综艺', "variety"),
    TabModel('漫画', "comic"),
    TabModel('短剧', "short"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _showSearchBar.dispose();
    super.dispose();
  }

  void _onScroll(double offset) {
    final delta = offset - _lastOffset;
    if (delta.abs() < 5) return;
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
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  showSearchBar: _showSearchBar,
                  tabBar: _buildTopTabBar(),
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: _tabs
                  .map((tab) => TabContent(tab, onScroll: _onScroll))
                  .toList(),
            ),
          ),
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
      tabs: _tabs.map((tab) => Tab(text: tab.displayName)).toList(),
    );
  }
}

/// 搜索栏+TabBar吸顶委托
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final ValueNotifier<bool> showSearchBar;
  final TabBar tabBar;

  _SliverAppBarDelegate({required this.showSearchBar, required this.tabBar});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height + 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final screenWidth = MediaQuery.of(context).size.width;

    return ValueListenableBuilder<bool>(
      valueListenable: showSearchBar,
      builder: (context, showSearch, _) {
        return Container(
          color: Colors.white,
          child: Stack(
            children: [
              // 左侧可滑动 TabBar
              Positioned(
                left: 0,
                right: 50, // 给右侧固定按钮留宽度
                bottom: 0,
                height: tabBar.preferredSize.height,
                child: tabBar,
              ),
              // 右侧固定按钮
              Positioned(
                right: 0,
                bottom: 0,
                width: 50,
                height: tabBar.preferredSize.height,
                child: IconButton(
                  icon: const Icon(Icons.add, color: Colors.purple),
                  onPressed: () {
                    print("点击右侧固定按钮");
                  },
                ),
              ),
              // 搜索栏动画
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: showSearch ? 16 : screenWidth - 48 - 8,
                right: showSearch ? 16 : 8,
                top: showSearch ? 6 : 48 + (tabBar.preferredSize.height - 36) / 2,
                height: 36,
                child: GestureDetector(
                  onTap: () {
                    if (!showSearch) {
                      showSearchBar.value = true;
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: showSearch ? Colors.grey.shade200 : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: showSearch ? 12 : 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            Icons.search,
                            color: showSearch ? Colors.grey : Colors.purple,
                            size: showSearch ? 20 : 24,
                          ),
                        ),
                        if (showSearch) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: showSearch ? 1 : 0,
                              child: const Text(
                                '搜索内容...',
                                style: TextStyle(color: Colors.grey, fontSize: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => true;
}

/// 高性能 Tab 内容（带接口调用）
class TabContent extends StatefulWidget {
  final TabModel tabInfo;
  final ValueChanged<double>? onScroll;

  const TabContent(this.tabInfo, {this.onScroll, super.key});

  @override
  State<TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<TabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // 数据列表
  List<Map<String, dynamic>> _dataList = [];

  // 加载状态
  bool _isLoading = false;

  // 错误信息
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载数据
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 调用获取列表接口
      final response = await CloudApi.findResource({
        "page": 1,
        "category": widget.tabInfo.value,
      });
      // 处理响应
      if (response.data['success']) {
        setState(() {
          _dataList = List<Map<String, dynamic>>.from(
            response.data['data'] ?? [],
          );
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.data['message'] ?? '加载失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '网络请求失败: $e';
        _isLoading = false;
      });
    }
  }

  /// 更新数据
  Future<void> _updateCampus(String id, String name) async {
    try {
      final response = await CloudApi.updateCampus({'id': id, 'name': name});

      if (response.data['code'] == 200) {
        // 更新成功，刷新列表
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('更新成功')));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? '更新失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
    }
  }

  /// 删除数据
  Future<void> _deleteCampus(String id) async {
    try {
      final response = await CloudApi.deleteCampus(id);

      if (response.data['code'] == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('删除成功')));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.data['message'] ?? '删除失败')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // 加载中状态
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 错误状态
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('重试')),
          ],
        ),
      );
    }

    // 空数据状态
    if (_dataList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '暂无数据',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ],
        ),
      );
    }

    // 渲染数据列表
    return Scaffold(
      body: SafeArea(
        child: SizedBox(),
      ),
    );

    //   return NotificationListener<ScrollNotification>(
    //   onNotification: (notification) {
    //     if (notification is ScrollUpdateNotification &&
    //         notification.metrics.axis == Axis.vertical) {
    //       widget.onScroll?.call(notification.metrics.pixels);
    //     }
    //     return false;
    //   },
    //   child: RefreshIndicator(
    //     onRefresh: _loadData,
    //     child: ListView.builder(
    //       padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    //       itemCount: _dataList.length,
    //       itemBuilder: (context, index) {
    //         final item = _dataList[index];
    //         return _buildListItem(item, index);
    //       },
    //     ),
    //   ),
    // );
  }

  /// 构建列表项
  Widget _buildListItem(Map<String, dynamic> item, int index) {
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
          child: Image.network(item['image'], fit: BoxFit.cover),
        ),
        title: Text(
          item['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              item['desc'] ?? '暂无说明',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditDialog(item);
            } else if (value == 'delete') {
              _showDeleteDialog(item['id']);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('编辑'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示编辑对话框
  void _showEditDialog(Map<String, dynamic> item) {
    final nameController = TextEditingController(text: item['name']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑校园信息'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: '校园名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateCampus(item['id'], nameController.text);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  /// 显示删除确认对话框
  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这个校园吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCampus(id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}