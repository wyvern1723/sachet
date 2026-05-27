import 'package:flutter/material.dart';
import 'package:sachet/services/zhengfang_jwxt/reserve_textbook/models/reserve_textbook_response_zf.dart';

class ReserveTextbookReferencesView extends StatelessWidget {
  /// 参考文献格式
  const ReserveTextbookReferencesView({
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
              const SizedBox(height: 4),
              ...List.generate(bookData.length, (index) {
                final e = bookData[index];
                return Text(
                  '[${index + 1}] ${e.jczz}. ${e.jcmc}[M]. ${e.bbh}. ${e.cbs}, ${e.cbrq}',
                );
              }),
              const SizedBox(height: 12),
              if (footer != null) footer!,
            ]),
      ),
    );
  }
}
