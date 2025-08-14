import 'package:sachet/providers/free_class_page_provider.dart';
import 'package:sachet/services/get_jwxt_data/fetch_data_http/fetch_free_classroom.dart';
import 'package:html/parser.dart';

/// 获取空闲教室数据
Future<List<List<String>>> getFreeClassroomData(Day day) async {
  var result = await fetchFreeClassroomData(day == Day.tomorrow ? 1 : 0);

  var document = parse(encoding: '', result);
  var pathElement = document.getElementById('dataList')?.children[0];
  var listLength = pathElement?.children.length ?? 100;

  List<List<String>> roomsData = [];

  for (int i = 2; i < listLength; i++) {
    List<String> roomData = [];

    // 添加教室名称
    var roomName =
        pathElement?.children[i].children[0].innerHtml.trim().split('<')[0] ??
            '" null room<"';
    roomData.add(roomName);

    // 添加 空/满 数据
    for (int j = 1; j < 6; j++) {
      String occupiedOrEmptyText =
          pathElement?.children[i].children[j].children[0].innerHtml ?? '错误';
      roomData.add(occupiedOrEmptyText);
    }

    // roomData e.g. [逸夫楼-507, 空, 空, 空, 空, 满]
    roomsData.add(roomData);
  }

  return roomsData;
}
