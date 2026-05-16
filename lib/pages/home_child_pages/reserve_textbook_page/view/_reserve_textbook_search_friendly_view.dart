import 'package:flutter/material.dart';
import 'package:sachet/models/purchase_channel.dart';
import 'package:sachet/models/zhengfang_jwxt/response/reserve_textbook_response_zf.dart';
import 'package:sachet/utils/utils_funtions.dart';

enum DisplayFormat { text, isbn }

class ReserveTextbookSearchFriendlyView extends StatefulWidget {
  /// 便于搜索的格式
  const ReserveTextbookSearchFriendlyView({
    super.key,
    required this.bookData,
    required this.channelList,
    this.footer,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final List<PurchaseChannel> channelList;
  final Widget? footer;

  @override
  State<ReserveTextbookSearchFriendlyView> createState() =>
      _ReserveTextbookSearchFriendlyViewState();
}

class _ReserveTextbookSearchFriendlyViewState
    extends State<ReserveTextbookSearchFriendlyView> {
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('教材信息：', style: textTheme.titleMedium),
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
                      for (final (index, e) in widget.bookData.indexed) {
                        String text = '《${e.jcmc}》 ${e.jczz} ${e.cbs} ${e.bbh}';
                        String isbn = 'ISBN: ${e.isbn}';
                        buffer.write(text);
                        buffer.write('\n');
                        buffer.write(isbn);
                        buffer.write('\n');
                        if (index != widget.bookData.length - 1) {
                          buffer.write('\n');
                        }
                      }
                      final text = buffer.toString();
                      copyToClipboard(context, text);
                    },
                    icon: Icon(Icons.copy),
                    iconSize: 18,
                    splashRadius: 24,
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    tooltip:
                        (_isShowOpenShopApp == true) ? '隐藏第三方软件' : '显示第三方软件',
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
                    splashRadius: 24,
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
                    textStyle: (selection.contains(DisplayFormat.text))
                        ? textTheme.bodySmall
                            ?.copyWith(color: colorScheme.outline)
                        : null,
                  ),
                Divider(),
              ],
              const SizedBox(height: 8.0),
              if (widget.footer != null) widget.footer!,
            ]),
      ),
    );
  }

  Widget _bookList(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    TextStyle? textStyle,

    /// 用于打开第三方软件进行搜索的字符串
    String? queryText,
  }) {
    final searchText = queryText ?? text;
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                    child: Text(
                  text,
                  style: textStyle,
                )),
                IconButton(
                  onPressed: () => copyToClipboard(context, text),
                  color: colorScheme.secondary,
                  icon: Icon(Icons.content_copy),
                  iconSize: 14,
                  splashRadius: 16,
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
        ...widget.channelList.map((e) => _openShopApp(
              channel: e,
              product: text,
              textTheme: textTheme,
              colorScheme: colorScheme,
            ))
      ],
    );
  }

  Widget _openShopApp({
    required PurchaseChannel channel,
    required String product,
    required TextTheme textTheme,
    required ColorScheme colorScheme,
  }) {
    if (Theme.of(context).useMaterial3) {
      return IconButton(
        color: colorScheme.primary,
        onPressed: () => channel.onPressed(product),
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              channel.appTitle,
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
        onPressed: () => channel.onPressed(product),
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
              channel.appTitle,
              style: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
            ),
            Icon(Icons.launch),
          ],
        ),
      );
    }
  }
}
