import 'dart:convert';

import 'package:sachet/models/app_folder.dart';
import 'package:sachet/services/get_jwxt_data/process_data/generate_cultivate_plan_data.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:intl/intl.dart';

// String dataCookie = UserModel().user.cookie ?? '';

/// 获取培养方案数据
Future<List?> getCultivatePlanData() async {
  // 不加延迟的话，太快了，没有动画过渡。
  await Future.delayed(Duration(milliseconds: 300));

  // 先从应用文件夹中获取 cultivate_plan.json 这个文件
  var file = await CachedDataStorage()
      .getFile(AppFolder.cachedData.name, 'cultivate_plan.json');
  String checkData = await CachedDataStorage().readDataViaFile(file);

  if (checkData != '') {
    // checkData != ''， 有缓存数据，把 String 解码成 json
    var returnData = await jsonDecode(checkData);
    // 该文件的上次修改时间
    var lastModifiedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(file.lastModifiedSync());
    return [
      returnData,
      [true, lastModifiedTime]
    ];
  } else {
    // check == ''， 没有缓存数据，从网站获取数据。
    return getCultivatePlanDataFromWeb();
  }
}

/// 从网站获取培养方案数据
Future<List?> getCultivatePlanDataFromWeb() async {
  var listData = await generateCultivatePlanData();

  // var jsonData = jsonEncode(dataList);
  var jsonData = formatJsonEncode(listData);

  // 把培养数据方案作为缓存数据写入 AppSupportDir
  await CachedDataStorage().writeFileToAppSupportDir(
    fileName: 'cultivate_plan.json',
    folder: AppFolder.cachedData.name,
    value: jsonData,
  );

  return [
    listData,
    [
      false,
      DateFormat('yyyy-MM-dd HH:mm:ss')
          .format(DateTime.now()) // 偷了懒，再读 io 消耗大，直接套用现在的时间了
    ]
  ];
}
