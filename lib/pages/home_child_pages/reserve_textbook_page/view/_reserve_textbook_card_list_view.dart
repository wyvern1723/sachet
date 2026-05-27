import 'package:flutter/material.dart';
import 'package:sachet/models/purchase_channel.dart';
import 'package:sachet/services/zhengfang_jwxt/reserve_textbook/models/reserve_textbook_response_zf.dart';
import 'package:sachet/utils/utils_functions.dart';

class ReserveTextbookCardListView extends StatefulWidget {
  /// 卡片格式
  const ReserveTextbookCardListView({
    super.key,
    required this.bookData,
    required this.channelList,
    this.footer,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final List<PurchaseChannel> channelList;
  final Widget? footer;

  @override
  State<ReserveTextbookCardListView> createState() =>
      _ReserveTextbookCardListViewState();
}

class _ReserveTextbookCardListViewState
    extends State<ReserveTextbookCardListView> {
  bool _isShowOpenShopApp = true;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
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
                Spacer(),
                IconButton(
                  tooltip: '复制所有教材信息',
                  onPressed: () {
                    final buffer = StringBuffer();
                    for (final (index, e) in widget.bookData.indexed) {
                      String bookTitle = '《${e.jcmc}》';
                      String text =
                          '${e.jczz} | ${e.cbs} | ${e.bbh} | ${e.cbrq}';
                      String isbn = 'ISBN: ${e.isbn}';
                      buffer.write(bookTitle);
                      buffer.write('\n');
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
                  splashRadius: 24,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            SizedBox(height: 4.0),
            for (final e in widget.bookData) ...[
              _bookCard(
                '${e.jcmc}',
                '${e.jczz}',
                '${e.cbs}',
                '${e.bbh}',
                '${e.cbrq}',
                '${e.isbn}',
                colorScheme,
                textTheme,
                queryText: '${e.jcmc} ${e.jczz} ${e.cbs} ${e.bbh}',
              ),
            ],
            const SizedBox(height: 8),
            if (widget.footer != null) widget.footer!,
          ]),
    );
  }

  Widget _bookCard(
    String bookTitle,
    String author,
    String publisher,
    String edition,
    String publishDate,
    String isbn,
    ColorScheme colorScheme,
    TextTheme textTheme, {
    /// 用于打开第三方软件进行搜索的字符串
    required String queryText,
  }) {
    return Card(
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () {},
        onLongPress: () => copyToClipboard(context, queryText),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14.0, 12.0, 12.0, 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '《$bookTitle》',
                        style: textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => copyToClipboard(context, queryText),
                      icon: Icon(Icons.copy, color: colorScheme.primary),
                      iconSize: 18,
                      splashRadius: 24,
                      visualDensity: VisualDensity.compact,
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$author | $publisher | $edition | $publishDate',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'ISBN: $isbn',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.content_copy,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      onPressed: () => copyToClipboard(context, isbn),
                      visualDensity: VisualDensity(
                        vertical: VisualDensity.compact.vertical,
                        horizontal: VisualDensity.minimumDensity,
                      ),
                      splashRadius: 18,
                    ),
                  ],
                ),
                // const SizedBox(height: 4),
                if (_isShowOpenShopApp == true)
                  _openShopAppRow(queryText, colorScheme, textTheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _openShopAppRow(
    String text,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
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
    final isDouBan = channel.appTitle == '豆瓣';

    if (Theme.of(context).useMaterial3) {
      return FilledButton(
        onPressed: () => channel.onPressed(product),
        style: FilledButton.styleFrom(
          backgroundColor:
              isDouBan ? colorScheme.secondaryContainer : colorScheme.primary,
          foregroundColor: isDouBan
              ? colorScheme.onSecondaryContainer
              : colorScheme.onPrimary,
          textStyle:
              Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          // tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.comfortable,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDouBan ? Icons.book : Icons.shopping_cart_outlined,
              size: 16,
            ),
            SizedBox(width: 4),
            Flexible(child: Text(channel.appTitle))
          ],
        ),
      );
    } else {
      return isDouBan
          ? OutlinedButton(
              onPressed: () => channel.onPressed(product),
              style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: WidgetStatePropertyAll(14),
                  padding:
                      WidgetStatePropertyAll(EdgeInsets.fromLTRB(8, 0, 8, 0)),
                  alignment: Alignment.center),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.book, size: 16),
                  SizedBox(width: 4),
                  Flexible(child: Text(channel.appTitle))
                ],
              ),
            )
          : ElevatedButton(
              onPressed: () => channel.onPressed(product),
              style: ButtonStyle(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  iconSize: WidgetStatePropertyAll(14),
                  padding:
                      WidgetStatePropertyAll(EdgeInsets.fromLTRB(8, 0, 8, 0)),
                  alignment: Alignment.center),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 16),
                  SizedBox(width: 4),
                  Flexible(child: Text(channel.appTitle))
                ],
              ),
            );
    }
  }
}
