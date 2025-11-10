import 'dart:convert';

import 'package:sachet/models/app_folder.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/generate_exam_time_data.dart';
import 'package:sachet/services/qiangzhi_jwxt/get_data/process_data/get_exam_time_semesters.dart';
import 'package:sachet/utils/storage/path_provider_utils.dart';
import 'package:sachet/utils/transform.dart';
import 'package:intl/intl.dart';

/// 获取考试时间数据（强智教务系统）
Future<List> getExamTimeDataQZ() async {
  // 不加延迟的话，太快了，没有动画过渡。
  await Future.delayed(Duration(milliseconds: 300));

  // 先从应用文件夹中获取 exam_time.json 这个文件
  var file = await CachedDataStorage()
      .getFile(AppFolder.cachedData.name, 'exam_time.json');
  String checkData = await CachedDataStorage().readDataViaFile(file);

  if (checkData != '') {
    // checkData != ''， 有缓存数据，把 String 解码成 json
    var returnData = await jsonDecode(checkData);
    // 该文件的上次修改时间
    var lastModifiedTime =
        DateFormat('yyyy-MM-dd HH:mm:ss').format(file.lastModifiedSync());
    return [
      returnData,
      {"isUseCacheData": true, "lastModifiedTime": lastModifiedTime}
    ];
  } else {
    // check == ''， 没有缓存数据，从网站获取数据。
    return getExamTimeDataFromWebQZ(isStoreData: true);
  }
}

/// 在线获取考试时间数据（强智教务系统）
Future<List> getExamTimeDataFromWebQZ(
    {String? semester, required bool isStoreData}) async {
  Map jsonData;
  if (semester == null) {
    List semestersData = await getExamTimeSemestersDataQZ();
    String semester = semestersData[0];
    jsonData = await generateExamTimeDataQZ(semester);
  } else {
    jsonData = await generateExamTimeDataQZ(semester);
  }

  String prettyJonData = formatJsonEncode(jsonData);

  // 把考试时间作为缓存数据写入 AppSupportDir
  if (isStoreData) {
    await CachedDataStorage().writeFileToAppSupportDir(
      fileName: 'exam_time.json',
      folder: AppFolder.cachedData.name,
      value: prettyJonData,
    );
  }
  var lastModifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss')
      .format(DateTime.now()); // 偷了懒，再读 io 消耗大，直接套用现在的时间了
  return [
    jsonData,
    {"isUseCacheData": false, "lastModifiedTime": lastModifiedTime}
  ];
}
