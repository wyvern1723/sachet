import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/reserve_textbook/models/reserve_textbook_response_zf.dart';

class ReserveTextbookSimpleListTileView extends StatelessWidget {
  /// 简单的 ListTile 格式
  const ReserveTextbookSimpleListTileView({
    super.key,
    required this.bookData,
    this.footer,
  });
  final List<ReserveTextbookResponseZF> bookData;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 20.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text('教材信息：', style: Theme.of(context).textTheme.titleMedium),
              ...List.generate(bookData.length, (index) {
                final e = bookData[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onPrimaryContainer,
                    child: Text('${index + 1}'),
                  ),
                  title: Text('《${e.jcmc}》'),
                  subtitle: Text(
                    '${e.jczz} | ${e.cbs} | ${e.bbh} | ${e.cbrq}'
                    '\n'
                    'ISBN: ${e.isbn}',
                  ),
                  dense: true,
                );
              }),
              const SizedBox(height: 12),
              if (footer != null) footer!,
            ]),
      ),
    );
  }
}
