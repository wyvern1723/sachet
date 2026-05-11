import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/zhengfang_jwxt/response/reserve_textbook_response_zf.dart';
import 'package:sachet/providers/zhengfang_user_provider.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_reserve_textbook_semesters.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_reverve_book_info.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/homepage_widgets/utils_widgets/change_semester_dialog.dart';
import 'package:sachet/widgets/utils_widgets/login_expired_zf.dart';
import 'package:url_launcher/url_launcher.dart';

class ReserveTextbookPageZf extends StatefulWidget {
  /// 教材预订的书籍信息查询页面（正方教务）
  const ReserveTextbookPageZf({super.key});

  @override
  State<ReserveTextbookPageZf> createState() => _ReserveTextbookPageZfState();
}

class _ReserveTextbookPageZfState extends State<ReserveTextbookPageZf> {
  late Future _future;

  Map semestersYears = {};
  final Map semesterIndexes = {"全部": "", "1": "3", "2": "12"};

  /// 当前查询的学年
  String _selectedSemesterYear = '';

  /// 当前查询的学期
  String _selectedSemesterIndex = '';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("教材预订"), actions: [
        if (_bookData != null && _bookData!.isNotEmpty) ...[
          IconButton(
            onPressed: () async {
              await _changeSemester(context);
            },
            icon: Icon(Icons.history_outlined),
            visualDensity: VisualDensity.comfortable,
            tooltip: '切换查询学期',
          ),
        ]
      ]),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasError) {
            if (snapshot.error ==
                "获取可查询学期数据失败: Http status code = 302, 可能需要重新登录") {
              return Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: LoginExpiredZF(onGoBack: (value) => onGoBack(value)),
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '${snapshot.error}',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 8.0, 8.0),
                  child: Text(
                    '查询学期: $_displaySemesterYear-$_displaySemesterIndex',
                    style: Theme.of(context).textTheme.bodySmall,
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
          );
        },
      ),
    );
  }
}

/// 教材信息 View
class _BookInfoViewZF extends StatelessWidget {
  const _BookInfoViewZF({
    super.key,
    required this.bookData,
    required this.queryingSemesterYear,
    required this.queryingSemesterIndex,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final String queryingSemesterYear;
  final String queryingSemesterIndex;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 8.0),
              child: _DataTable(bookData: bookData),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: _SearchFriendlyFormat(bookData: bookData),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
              child: _ReferencesFormat(bookData: bookData),
            ),
            // Footer
            _footer(textTheme, context),
          ],
        ),
      ),
    );
  }

  Widget _footer(
    TextTheme textTheme,
    BuildContext context,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 显示当前查询的学期
          Text(
            '查询学期: $queryingSemesterYear-$queryingSemesterIndex',
            style: textTheme.bodySmall,
          ),
          Text('本软件只提供查询，不实现提交信息的功能', style: textTheme.bodySmall),
          Wrap(children: [
            Text('如需预订教材，请在', style: textTheme.bodySmall),
            GestureDetector(
              onTap: () => openLink(newJwxtBaseUrl),
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: newJwxtBaseUrl));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("链接已复制到剪贴板")),
                );
              },
              child: Text(
                '教务系统官网',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.light
                      ? Color(0xFF0645AD)
                      : Colors.blue,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      Theme.of(context).brightness == Brightness.light
                          ? const Color(0xFF0645AD)
                          : Colors.blue,
                  fontSize: 12.0,
                ),
              ),
            ),
            Text('预订', style: textTheme.bodySmall),
          ]),
        ],
      ),
    );
  }
}

class _DataTable extends StatefulWidget {
  const _DataTable({super.key, required this.bookData});
  final List<ReserveTextbookResponseZF> bookData;

  @override
  State<_DataTable> createState() => _DataTableState();
}

class _DataTableState extends State<_DataTable> {
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _horizontalController,
      thumbVisibility: true,
      trackVisibility: true,
      scrollbarOrientation: ScrollbarOrientation.bottom,
      child: SingleChildScrollView(
        controller: _horizontalController,
        scrollDirection: Axis.horizontal,
        child: SelectionArea(
          child: DataTable(
            sortColumnIndex: 1,
            columns: [
              ...[
                '课程名称',
                '教材名称',
                'ISBN',
                '教材作者',
                '出版社',
                '版本号',
                '出版日期',
                '单价',
                '课程性质',
                '任课教师',
              ].map(
                (e) => DataColumn(label: Expanded(child: Text(e))),
              )
            ],
            rows: <DataRow>[
              ...widget.bookData.map(
                (e) => DataRow(
                  cells: <DataCell>[
                    copyableDataCell(e.kcmc.toString(), context),
                    copyableDataCell(e.jcmc.toString(), context),
                    copyableDataCell(e.isbn.toString(), context),
                    copyableDataCell(e.jczz.toString(), context),
                    copyableDataCell(e.cbs.toString(), context),
                    copyableDataCell(e.bbh.toString(), context),
                    DataCell(Text(e.cbrq.toString())),
                    DataCell(Text(e.price.toString())),
                    DataCell(Text(e.kcxzmc.toString())),
                    DataCell(Text(e.rkjsxx.toString())),
                  ],
                ),
              )
            ],
            horizontalMargin: 4,
            columnSpacing: 8,
          ),
        ),
      ),
    );
  }

  DataCell copyableDataCell(String text, BuildContext context,
      {bool tapToCopy = false}) {
    return DataCell(
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制到剪贴板')),
              );
            },
            icon: Icon(Icons.content_copy),
            iconSize: 14,
            padding: EdgeInsets.all(0),
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
          ),
        ],
      ),
      onTap: tapToCopy
          ? () {
              Clipboard.setData(ClipboardData(text: text));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制到剪贴板')),
              );
            }
          : null,
    );
  }
}

enum DisplayFormat { text, isbn }

class _SearchFriendlyFormat extends StatefulWidget {
  /// 便于搜索的格式
  const _SearchFriendlyFormat({super.key, required this.bookData});
  final List<ReserveTextbookResponseZF> bookData;

  @override
  State<_SearchFriendlyFormat> createState() => _SearchFriendlyFormatState();
}

class _SearchFriendlyFormatState extends State<_SearchFriendlyFormat> {
  Set<DisplayFormat> selection = <DisplayFormat>{
    DisplayFormat.text,
    DisplayFormat.isbn
  };
  bool _isShowOpenShopApp = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SelectionArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔎 快捷搜索：', style: textTheme.titleMedium),
                SegmentedButton<DisplayFormat>(
                  segments: const <ButtonSegment<DisplayFormat>>[
                    ButtonSegment<DisplayFormat>(
                      value: DisplayFormat.text,
                      label: Text('名称', style: TextStyle(fontSize: 10)),
                    ),
                    ButtonSegment<DisplayFormat>(
                      value: DisplayFormat.isbn,
                      label: Text('ISBN', style: TextStyle(fontSize: 10)),
                    ),
                  ],
                  selected: selection,
                  onSelectionChanged: (Set<DisplayFormat> newSelection) {
                    setState(() => selection = newSelection);
                  },
                  multiSelectionEnabled: true,
                  showSelectedIcon: false,
                  style: ButtonStyle(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity(
                      horizontal: VisualDensity.minimumDensity + 0.2,
                      vertical: VisualDensity.minimumDensity,
                    ),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
                Spacer(),
                IconButton(
                  tooltip: '复制所有教材信息',
                  onPressed: () {
                    final buffer = StringBuffer();
                    for (final e in widget.bookData) {
                      String text = '《${e.jcmc}》 ${e.jczz} ${e.cbs} ${e.bbh}';
                      String isbn = 'ISBN: ${e.isbn}';
                      buffer.write(text);
                      buffer.write('\n');
                      buffer.write(isbn);
                      buffer.write('\n');
                    }
                    final text = buffer.toString();
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('已复制到剪贴板')),
                    );
                  },
                  icon: Icon(Icons.copy),
                  iconSize: 18,
                  visualDensity: VisualDensity.compact,
                ),
                IconButton(
                  tooltip: (_isShowOpenShopApp == true) ? '隐藏第三方软件' : '显示第三方软件',
                  onPressed: () {
                    setState(() => _isShowOpenShopApp = !_isShowOpenShopApp);
                  },
                  icon: Icon(
                    (_isShowOpenShopApp == true)
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  color: (_isShowOpenShopApp == true)
                      ? colorScheme.primary
                      : colorScheme.outline,
                  iconSize: 20,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: 4.0),
            for (final (index, e) in widget.bookData.indexed) ...[
              if (index == 0) Divider(),
              if (selection.contains(DisplayFormat.text))
                _bookList(
                  '《${e.jcmc}》 ${e.jczz} ${e.cbs} ${e.bbh}',
                  colorScheme,
                  textTheme,
                  queryText: '${e.jcmc} ${e.jczz} ${e.cbs} ${e.bbh}',
                ),
              if (selection.contains(DisplayFormat.isbn))
                _bookList(
                  'ISBN: ${e.isbn}',
                  colorScheme,
                  textTheme,
                  queryText: '${e.isbn}',
                ),
              Divider(),
            ]
          ]),
    );
  }

  Widget _bookList(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    /// 用于打开第三方软件进行搜索的字符串
    String? queryText,
  }) {
    final searchText = queryText ?? text;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 4.0),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(child: Text(text)),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('已复制到剪贴板')),
                      );
                    },
                    color: colorScheme.secondary,
                    icon: Icon(Icons.content_copy),
                    iconSize: 14,
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    visualDensity: VisualDensity(
                      horizontal: VisualDensity.minimumDensity,
                      vertical: VisualDensity.minimumDensity,
                    ),
                  ),
                ],
              ),
            ),
            if (_isShowOpenShopApp == true)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VerticalDivider(
                    indent: 6.0,
                    endIndent: 6.0,
                    width: 1.0,
                  ),
                  SizedBox(width: 4.0),
                  _openShopAppRow(searchText, colorScheme, textTheme),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Row _openShopAppRow(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _openShopApp(
          appTitle: '拼多多',
          product: text,
          onPressed: () async {
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
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        _openShopApp(
          appTitle: '淘宝',
          product: text,
          onPressed: () async {
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
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        _openShopApp(
          appTitle: '京东',
          product: text,
          onPressed: () async {
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
                Uri.parse(
                    'https://search.jd.com/Search?keyword=$text&enc=utf-8'),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
        _openShopApp(
          appTitle: '豆瓣',
          product: text,
          onPressed: () async {
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
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _openShopApp({
    required String appTitle,
    required String product,
    required void Function()? onPressed,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    if (Theme.of(context).useMaterial3) {
      return IconButton(
        color: colorScheme.primary,
        onPressed: onPressed,
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              appTitle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            ),
            Icon(Icons.launch)
          ],
        ),
        iconSize: 14,
        padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
        visualDensity: VisualDensity(
          horizontal: VisualDensity.minimumDensity,
          vertical: VisualDensity.minimumDensity,
        ),
      );
    } else {
      return TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            iconSize: WidgetStatePropertyAll(14),
            padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(1, 0, 1, 0)),
            visualDensity: VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
            alignment: Alignment.center),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              appTitle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            ),
            Icon(Icons.launch),
          ],
        ),
      );
    }
  }
}

class _ReferencesFormat extends StatelessWidget {
  /// 参考文献格式
  const _ReferencesFormat({super.key, required this.bookData});
  final List<ReserveTextbookResponseZF> bookData;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📚 参考文献格式：', style: Theme.of(context).textTheme.titleMedium),
            ...bookData.map(
              (e) => Text(
                  '[${e.rowId}] ${e.jczz}. ${e.jcmc}[M]. ${e.bbh}. ${e.cbs}, ${e.cbrq}'),
            ),
          ]),
    );
  }
}
