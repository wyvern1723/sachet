import 'package:sachet/models/zhengfang_jwxt/response/reserve_textbook_response_zf.dart';

/// 解析教材预订的书籍信息
///
/// 返回： List<ReserveTextbookResponseZF>
List<ReserveTextbookResponseZF> parseReserveTextBookInfoZF(Map jsonData) {
  List items = jsonData['items'];
  if (items.isEmpty) {
    throw '没有符合条件记录!';
  }

  List<ReserveTextbookResponseZF> bookList = [];

  for (final item in items) {
    ReserveTextbookResponseZF book = ReserveTextbookResponseZF.fromJson(item);
    bookList.add(book);
  }

  return bookList;
}
