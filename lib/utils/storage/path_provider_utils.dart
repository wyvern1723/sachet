import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:sachet/constants/app_info_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sachet/models/enums/app_folder.dart';
import 'package:path/path.dart' as path;

/// 本地缓存数据存储工具类
class CachedDataStorage {
  CachedDataStorage._();

  static Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  static Future<String> getPath() async {
    return await _localPath;
  }

  /// 返回 getApplicationSupportDirectory 目录下的所有文件路径的 List
  static Future<List<String>> lsFilePath() async {
    final dirPath = await _localPath;
    final Directory dir = Directory(dirPath);

    if (!await dir.exists()) return [];

    final filesList = await dir.list().toList();
    filesList
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    return filesList.map((e) => e.path).toList();
  }

  /// 返回 ApplicationSupportDirectory/[folder]/[subFolders] 下的所有 .[extension] 文件
  static Future<List<FileSystemEntity>> ls(
    String folder, {
    List<String>? subFolders,
    String extension = '.json',
  }) async {
    final basePath = await _localPath;
    final String dirPath = path.joinAll([basePath, folder, ...?subFolders]);
    final Directory dir = Directory(dirPath);

    if (!await dir.exists()) return [];

    return await dir.list().where((e) => e.path.endsWith(extension)).toList();
  }

  /// (Android 系统) DATA/data/{application package}/shared_prefs/ 路径下的文件
  static Future<List<FileSystemEntity>> lsPrefDirectory() async {
    if (kIsWeb || !Platform.isAndroid) return [];

    final dir = Directory('/data/data/$appPackageName/shared_prefs/');
    if (!await dir.exists()) return [];

    return await dir.list().toList();
  }

  /// 按上次修改时间（从新到旧）返回 {ApplicationSupportDirectory}/[folder]/[subFolders] 下的所有 .[extension] 文件
  static Future<List<FileSystemEntity>> lsByModifiedTime(
    String folder, {
    List<String>? subFolders,
    String extension = '.json',
  }) async {
    final basePath = await _localPath;
    final dirPath = path.joinAll([basePath, folder, ...?subFolders]);
    final dir = Directory(dirPath);

    if (!await dir.exists()) return [];

    final filesList =
        await dir.list().where((e) => e.path.endsWith(extension)).toList();

    // 按修改时间排序(倒序，从新到旧)
    filesList
        .sort((a, b) => b.statSync().modified.compareTo(a.statSync().modified));

    return filesList;
  }

  static Future<File> _localFile(String filename) async {
    return File(path.join(await _localPath, filename));
  }

  static Future<File> getFile(String folder, String filename) async {
    return File(path.join(await _localPath, folder, filename));
  }

  static Future<String> _safeReadFile(File file) async {
    try {
      if (await file.exists()) {
        return await file.readAsString();
      }
      return '';
    } catch (e) {
      debugPrint('读取文件(${file.path})出错: $e');
      return '';
    }
  }

  static Future<String> readDataViaFile(File file) async {
    return _safeReadFile(file);
  }

  static Future<String> readDataViaFilePath(String filePath) async {
    return _safeReadFile(File(filePath));
  }

  static String readDataViaFilePathSync(String filePath) {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        return file.readAsStringSync();
      }
      return '';
    } catch (e) {
      debugPrint('读取文件($filePath)失败: $e');
      return '';
    }
  }

  /// 重新写入（覆盖原有内容）
  static Future<File> reWriteData(String value, String fileName) async {
    final file = await _localFile(fileName);
    return file.writeAsString(value, encoding: utf8, mode: FileMode.write);
  }

  /// 重新写入（覆盖原有内容）(绝对路径)
  static Future<File> reWriteDataByFilePath(
      String value, String filePath) async {
    final file = File(filePath);
    return file.writeAsString(value, encoding: utf8, mode: FileMode.write);
  }

  /// 写入文件到 ApplicationSupportDirectory (AppSupportDir 的相对路径)
  static Future<File> writeFileToAppSupportDir({
    required String fileName,
    required String folder,
    List<String>? subFolder,
    required String value,
  }) async {
    final basePath = await _localPath;
    final file =
        File(path.joinAll([basePath, folder, ...?subFolder, fileName]));

    await file.create(recursive: true);

    return file.writeAsString(value, encoding: utf8, mode: FileMode.write);
  }

  /// 获取对文件 jsonDecode 的数据，如果不能 decode, 返回 {};
  static Future<Map<String, dynamic>> getDecodedMap(String filePath) async {
    final data = await _decodeData(filePath);
    return data is Map<String, dynamic> ? data : {};
  }

  /// 获取对文件 jsonDecode 的数据，如果不能 decode, 返回 [];
  static Future<List<dynamic>> getDecodedList(String filePath) async {
    final data = await _decodeData(filePath);
    return data is List ? data : [];
  }

  /// 对文件进行 jsonDecode
  static Future<dynamic> _decodeData(String filePath) async {
    if (filePath.isEmpty) return null;

    final dataStr = await readDataViaFilePath(filePath);
    if (dataStr.isEmpty) return null;

    try {
      return jsonDecode(dataStr);
    } catch (e) {
      debugPrint('对文件($filePath) 进行 JSON 解码失败: $e');
      return null;
    }
  }

  /// 删除 {ApplicationSupportDirectory}/$folder/$fileName 单个文件
  static Future<void> deleteCachedData(String folder, String fileName) async {
    final file = await getFile(folder, fileName);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 删除所有的正方教务系统的考试时间的缓存数据
  static Future<void> deleteCachedExamTimeZF() async {
    final fileList = await ls(
      AppFolder.cachedDataZF.name,
      subFolders: [CachedDataZFSubFolder.examTimeCache.name],
    );
    await Future.wait(fileList.map((file) => file.delete()));
  }
}
