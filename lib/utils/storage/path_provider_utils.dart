import 'dart:convert';
import 'dart:io';

import 'package:sachet/constants/app_info_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sachet/models/app_folder.dart';

class CachedDataStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<String> getPath() async {
    final dirPath = await _localPath;
    return dirPath;
  }

  /// 返回 getApplicationSupportDirectory 目录下的所有文件路径的 List
  Future<List<String>> lsFilePath() async {
    final dirPath = await _localPath;

    Directory dir = Directory(dirPath);
    var filesList = dir.listSync().toList()
      ..sort((a, b) =>
          a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    var filesPathList = filesList.map((e) => e.path).toList();
    return filesPathList;
  }

  /// 返回 ApplicationSupportDirectory/pathInAppDir 下的所有 .json 文件
  Future<List<FileSystemEntity>> ls(String pathInAppDir) async {
    final dirPath = await _localPath;
    bool isExist = Directory('$dirPath${Platform.pathSeparator}$pathInAppDir')
        .existsSync();
    if (!isExist) {
      return [];
    }
    Directory dir = Directory('$dirPath${Platform.pathSeparator}$pathInAppDir');
    // var filesList = dir.listSync().toList()
    //   ..sort((a, b) =>
    //       a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    // return filesList;
    List<FileSystemEntity> filesList = [];
    await dir.list().forEach((element) {
      RegExp regExp = new RegExp(".json", caseSensitive: false);
      if (regExp.hasMatch('$element')) filesList.add(element);
    });

    return filesList;
  }

  // (Android 系统) DATA/data/{application package}/shared_prefs/ 路径下的文件
  Future<List<FileSystemEntity>> lsPrefDirectory() async {
    bool isExist =
        Directory('/data/data/$appPackageName/shared_prefs/').existsSync();
    if (!isExist) {
      return [];
    }
    Directory dir = Directory('/data/data/$appPackageName/shared_prefs/');
    // var filesList = dir.listSync().toList()
    //   ..sort((a, b) =>
    //       a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));
    // return filesList;
    List<FileSystemEntity> filesList = [];
    await dir.list().forEach((element) {
      filesList.add(element);
    });

    return filesList;
  }

  /// 按上次修改时间（从新到旧）返回 ApplicationSupportDirectory/folder 下的所有 .json 文件
  Future<List<FileSystemEntity>> lsByModifiedTime(String folder) async {
    final dirPath = await _localPath;
    bool isExist =
        Directory('$dirPath${Platform.pathSeparator}$folder').existsSync();
    if (!isExist) {
      return [];
    }
    Directory dir = Directory('$dirPath${Platform.pathSeparator}$folder');

    // 按修改时间排序(正序，从旧到新)
    List<FileSystemEntity> filesList = dir
        .listSync()
        .where((e) => e.path.endsWith('.json'))
        .toList()
      ..sort((l, r) => l.statSync().modified.compareTo(r.statSync().modified));

    // 倒序，从新到旧
    List<FileSystemEntity> reversedList = filesList.reversed.toList();
    return reversedList;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path${Platform.pathSeparator}$filename');
  }

  Future<File> getFile(String folder, String filename) async {
    final path = await _localPath;
    return File(
        '$path${Platform.pathSeparator}$folder${Platform.pathSeparator}$filename');
  }

  Future<String> readDataViaFileName(String fileName) async {
    try {
      final file = await _localFile(fileName);
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ''
      return '';
    }
  }

  Future<String> readDataViaFile(File file) async {
    try {
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ''
      return '';
    }
  }

  Future<String> readDataViaFilePath(String filePath) async {
    try {
      final file = File(filePath);
      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return ''
      return '';
    }
  }

  String readDataViaFilePathSync(String filePath) {
    try {
      final file = File(filePath);
      // Read the file
      final contents = file.readAsStringSync();
      return contents;
    } catch (e) {
      // If encountering an error, return ''
      return '';
    }
  }

  /// 重新写入（覆盖原有内容）
  Future<File> reWriteData(String value, String fileName) async {
    final file = await _localFile(fileName);

    // Write the file
    return file.writeAsString(
      value,
      encoding: utf8,
      mode: FileMode.write,
    );
  }

  /// 重新写入（覆盖原有内容）(绝对路径)
  Future<File> reWriteDataByFilePath(String value, String filePath) async {
    final file = File(filePath);

    // Write the file
    return file.writeAsString(
      value,
      encoding: utf8,
      mode: FileMode.write,
    );
  }

  /// 写入文件到 ApplicationSupportDirectory (AppSupportDir 的相对路径)
  Future<File> writeFileToAppSupportDir({
    required String fileName,
    required String folder,
    required String value,
  }) async {
    final path = await _localPath;
    final file = await File(
            '$path${Platform.pathSeparator}$folder${Platform.pathSeparator}$fileName')
        .create(recursive: true);
    // Write the file
    return file.writeAsString(
      value,
      encoding: utf8,
      mode: FileMode.write,
    );
  }

  /// 获取解码后(jsonDecode)的数据，如果不能 decode,根据请求的 type 返回 []/{};
  Future getDecodedData({required String path, required Type type}) async {
    if (path == '') {
      return type == List
          ? []
          : type == Map
              ? {}
              : null;
    }
    var data = await CachedDataStorage().readDataViaFilePath(path);
    try {
      var returnData = jsonDecode(data);
      return returnData;
    } catch (e) {
      var returnData = type == List
          ? []
          : type == Map
              ? {}
              : null;
      return returnData;
    }
  }

  /// 获取解码后(jsonDecode)的数据，如果不能 decode,根据请求的 type 返回 []/{};
  dynamic getDecodedDataSync({required String path, required Type type}) {
    if (path == '') {
      return type == List
          ? []
          : type == Map
              ? {}
              : null;
    }
    var data = CachedDataStorage().readDataViaFilePathSync(path);
    try {
      var returnData = jsonDecode(data);
      return returnData;
    } catch (e) {
      var returnData = type == List
          ? []
          : type == Map
              ? {}
              : null;
      return returnData;
    }
  }

  Future deleteAllCachedData() async {
    var fileList = await ls(AppFolder.cachedData.name);
    for (var file in fileList) {
      file.delete();
    }
  }
}
