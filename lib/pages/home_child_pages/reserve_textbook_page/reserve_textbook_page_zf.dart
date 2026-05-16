import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/models/purchase_channel.dart';
import 'package:sachet/models/zhengfang_jwxt/response/reserve_textbook_response_zf.dart';
import 'package:sachet/pages/home_child_pages/reserve_textbook_page/view/_reserve_textbook_card_list_view.dart';
import 'package:sachet/pages/home_child_pages/reserve_textbook_page/view/_reserve_textbook_references_view.dart';
import 'package:sachet/pages/home_child_pages/reserve_textbook_page/view/_reserve_textbook_search_friendly_view.dart';
import 'package:sachet/pages/home_child_pages/reserve_textbook_page/view/_reserve_textbook_simple_listtile_view.dart';
import 'package:sachet/pages/home_child_pages/reserve_textbook_page/view/_reserve_textbook_table_view.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_reserve_textbook_semesters.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_reverve_book_info.dart';
import 'package:sachet/widgets/homepage_widgets/reserve_textbook_page_widgets/capsule_tabbar.dart';
import 'package:sachet/widgets/homepage_widgets/utils_widgets/change_semester_dialog.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';
import 'package:sachet/widgets/homepage_widgets/reserve_textbook_page_widgets/reserve_textbook_footer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReserveTextbookPageZF extends StatefulWidget {
  /// 教材预订的书籍信息查询页面（正方教务）
  const ReserveTextbookPageZF({super.key});

  @override
  State<ReserveTextbookPageZF> createState() => _ReserveTextbookPageZFState();
}

class _ReserveTextbookPageZFState extends State<ReserveTextbookPageZF> {
  late Future _future;

  Map semestersYears = {};
  final Map semesterIndexes = {"全部": "", "1": "3", "2": "12"};

  /// 当前查询的学年
  String _selectedSemesterYear = '';

  /// 当前查询的学期
  String _selectedSemesterIndex = '';

  // ignore: unused_field
  List<ReserveTextbookResponseZF>? _bookData;

  /// 从登录页面回来，如果 value 为 true 说明登录成功，需要刷新
  void onGoBack(dynamic value) {
    if (value == true) {
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() => _future = _getBookData(zhengFangUserProvider));
    }
  }

  Future _getSemestersData(ZhengFangUserProvider? zhengFangUserProvider) async {
    final result = await getReserveTextbookSemestersZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
    );

    _selectedSemesterYear = result.currentSemesterYear ?? '';
    _selectedSemesterIndex = result.currentSemesterIndex ?? '';

    semestersYears = result.semestersYears;
  }

  Future _getBookData(ZhengFangUserProvider? zhengFangUserProvider) async {
    await _getSemestersData(zhengFangUserProvider);

    final result = await getReserveTextbookInfoZF(
      cookie: ZhengFangUserProvider.cookie,
      zhengFangUserProvider: zhengFangUserProvider,
      semesterYear: _selectedSemesterYear,
      semesterIndex: _selectedSemesterIndex,
    );

    if (mounted) {
      setState(() => _bookData = result);
    }

    return result;
  }

  Future _changeSemester(BuildContext context) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ChangeSemesterDialogZF(
        semestersYears: semestersYears,
        selectedSemesterYear: _selectedSemesterYear,
        selectedSemesterIndex: _selectedSemesterIndex,
      ),
    );

    if (!context.mounted) {
      return;
    }

    if (result != null && result is List) {
      _selectedSemesterYear = result[0];
      _selectedSemesterIndex = result[1];
      final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
      setState(() {
        _bookData = null;

        _future = getReserveTextbookInfoZF(
          cookie: ZhengFangUserProvider.cookie,
          zhengFangUserProvider: zhengFangUserProvider,
          semesterYear: _selectedSemesterYear,
          semesterIndex: _selectedSemesterIndex,
        ).then((data) {
          if (mounted) {
            setState(() => _bookData = data);
          }
          return data;
        }).catchError((error) {
          if (mounted) {
            setState(() => _bookData = null);
          }
          throw error;
        });
      });
    }
  }

  String get _displaySemesterYear => semestersYears.keys.firstWhere(
      (key) => semestersYears[key] == _selectedSemesterYear,
      orElse: () => _selectedSemesterYear);

  String get _displaySemesterIndex => semesterIndexes.keys.firstWhere(
      (key) => semesterIndexes[key] == _selectedSemesterIndex,
      orElse: () => _selectedSemesterIndex);

  @override
  void initState() {
    super.initState();
    final zhengFangUserProvider = context.read<ZhengFangUserProvider>();
    _future = _getBookData(zhengFangUserProvider);
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      title: const Text('教材预订'),
      actions: [
        IconButton(
          onPressed: () async {
            await _changeSemester(context);
          },
          icon: const Icon(Icons.history_outlined),
          splashRadius: 24,
          tooltip: '切换查询学期',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                const SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ],
            );
          }

          if (snapshot.hasError) {
            return CustomScrollView(
              slivers: [
                _buildAppBar(context),
                if (snapshot.error ==
                    "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录")
                  SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: LoginExpiredZF(
                          onGoBack: (value) => onGoBack(value),
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: colorScheme.error),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 8.0),
                          child: Text(
                            '当前查询学期: $_displaySemesterYear-$_displaySemesterIndex',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }

          final bookData = snapshot.data;

          return _BookInfoViewZF(
            bookData: bookData,
            queryingSemesterYear: _displaySemesterYear,
            queryingSemesterIndex: _displaySemesterIndex,
            appBar: _buildAppBar(context),
          );
        },
      ),
    );
  }
}

class _BookInfoViewZF extends StatefulWidget {
  /// 教材信息 View
  const _BookInfoViewZF({
    super.key,
    required this.bookData,
    required this.queryingSemesterYear,
    required this.queryingSemesterIndex,
    required this.appBar,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final String queryingSemesterYear;
  final String queryingSemesterIndex;
  final Widget appBar;

  @override
  State<_BookInfoViewZF> createState() => _BookInfoViewZFState();
}

class _BookInfoViewZFState extends State<_BookInfoViewZF>
    with TickerProviderStateMixin {
  int _pageIndex = 0;
  late TabController _tabController;

  final List<CapsuleTabItem> _myTabs = [
    const CapsuleTabItem(icon: Text('📑'), label: '表格'),
    const CapsuleTabItem(icon: Text('🔎'), label: '搜索'),
    const CapsuleTabItem(icon: Text('🗂️'), label: '卡片'),
    const CapsuleTabItem(icon: Text('📃'), label: '列表'),
    const CapsuleTabItem(icon: Text('📚'), label: '学术'),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _myTabs.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index != _pageIndex &&
          !_tabController.indexIsChanging) {
        setState(() {
          _pageIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final footer = ReserveTextbookFooter(
      queryingSemesterYear: widget.queryingSemesterYear,
      queryingSemesterIndex: widget.queryingSemesterIndex,
    );

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        widget.appBar,
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 12.0, 8.0),
            child: CapsuleTabBar(
              tabs: _myTabs,
              selectedIndex: _pageIndex,
              onTabSelected: (index) {
                _tabController.animateTo(index);
              },
            ),
          ),
        ),
      ],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
        child: TabBarView(
          controller: _tabController,
          children: [
            ReserveTextbookTableView(
              bookData: widget.bookData,
              footer: footer,
            ),
            ReserveTextbookSearchFriendlyView(
              bookData: widget.bookData,
              channelList: channelList,
              footer: footer,
            ),
            ReserveTextbookCardListView(
              bookData: widget.bookData,
              channelList: channelList,
              footer: footer,
            ),
            ReserveTextbookSimpleListTileView(
              bookData: widget.bookData,
              footer: footer,
            ),
            ReserveTextbookReferencesView(
              bookData: widget.bookData,
              footer: footer,
            ),
          ],
        ),
      ),
    );
  }
}

List<PurchaseChannel> channelList = [
  PurchaseChannel(
    appTitle: '拼多多',
    onPressed: (text) async {
      try {
        await launchUrl(
          Uri.parse(
              'pinduoduo://com.xunmeng.pinduoduo/search_result.html?search_key=$text'),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (kDebugMode) {
          print('拼多多 App 启动失败: $e');
        }
        await launchUrl(
          Uri.parse(
              'https://mobile.yangkeduo.com/search_result.html?search_key=$text&search_type=goods'),
          mode: LaunchMode.externalApplication,
        );
      }
      launchUrl(
        Uri.parse(
            'pinduoduo://com.xunmeng.pinduoduo/search_result.html?search_key=$text'),
        mode: LaunchMode.externalApplication,
      );
    },
  ),
  PurchaseChannel(
    appTitle: '淘宝',
    onPressed: (text) async {
      try {
        await launchUrl(
          Uri.parse(
            // 于 2026年5月10日 提取自 淘宝 APK v10.60.20(839) 的 AndroidManifest.xml
            // 以下都可：
            // taobao://s.taobao.com/search?q=$text
            // taobao://s.m.taobao.com/search.htm?q=$text
            // taobao://s.m.taobao.com/h5?q=$text
            // taobao://main.m.taobao.com/search/index.html?q=$text
            // taobao://market.m.taobao.com/app/main-search/h5search-webapp/home.html?q=$text
            'taobao://s.taobao.com/search?q=$text',
          ),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (kDebugMode) {
          print('淘宝 App 启动失败: $e');
        }
        await launchUrl(
          Uri.parse('https://s.taobao.com/search?q=$text'),
          mode: LaunchMode.externalApplication,
        );
      }
    },
  ),
  PurchaseChannel(
    appTitle: '京东',
    onPressed: (text) async {
      try {
        await launchUrl(
          Uri.parse(
            // 或： 'openapp.jdmobile://virtual?params={"des":"productList","keyWord":"$text","from":"search","category":"jump"}',
            'openjd://virtual?params={"des":"productList","keyWord":"$text","from":"search","category":"jump"}',
          ),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (kDebugMode) {
          print('京东 App 启动失败: $e');
        }
        await launchUrl(
          Uri.parse('https://search.jd.com/Search?keyword=$text&enc=utf-8'),
          mode: LaunchMode.externalApplication,
        );
      }
    },
  ),
  PurchaseChannel(
    appTitle: '豆瓣',
    onPressed: (text) async {
      try {
        await launchUrl(
          Uri.parse('douban://douban.com/search?q=$text'),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        if (kDebugMode) {
          print('豆瓣 App 启动失败: $e');
        }
        if (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS) {
          // 移动端
          await launchUrl(
            Uri.parse('https://m.douban.com/search/?query=$text'),
            mode: LaunchMode.externalApplication,
          );
        } else {
          await launchUrl(
            // 桌面端
            Uri.parse('https://douban.com/search?cat=1001?q=$text'),
            mode: LaunchMode.externalApplication,
          );
        }
      }
    },
  ),
];
