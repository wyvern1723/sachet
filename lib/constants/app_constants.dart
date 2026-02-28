import 'package:flutter/material.dart';

final DateTime constSemesterStartDate = DateTime(2026, 3, 2);

/// 应用预设主题色（MaterialColor）
const List defaultThemeColors = <MaterialColor>[
  Colors.indigo,
  Colors.blue,
  Colors.lightBlue,
  Colors.cyan,
  Colors.teal,
  Colors.green,
  Colors.lightGreen,
  Colors.lime,
  Colors.red,
  Colors.pink,
  Colors.purple,
  Colors.deepPurple,
];

/// 应用主题色（品牌色）
const appBrandColor = Color(0xFF64C564);

final List<Color> materialColorsShade400 = [
  Colors.amber.shade400,
  Colors.blue.shade400,
  Colors.blueAccent.shade400,
  // Colors.brown.shade400,
  // Colors.cyanAccent.shade400,
  Colors.deepOrange.shade400,
  Colors.deepPurple.shade400,
  Colors.deepPurpleAccent.shade400,
  // Colors.greenAccent.shade400,
  // Colors.grey.shade400,
  Colors.lightGreen.shade400,
  Colors.indigoAccent.shade400,
  // Colors.limeAccent.shade400,
  Colors.orangeAccent.shade400,
  // Colors.blueGrey.shade400,
  Colors.cyan.shade400,
  Colors.green.shade400,
  Colors.indigo.shade400,
  // Colors.lime.shade400,
  Colors.orange.shade400,
  // Colors.purple.shade400,
  Colors.teal.shade400,
  // Colors.pink.shade400,
];

const String disclaimer = """
1. 本软件由第三方独立开发，仅调用教务系统服务器的数据，**与官方机构无关**。
2. 本软件**不主动收集任何个人信息**，通过加密协议直接与教务系统通信。账号信息在本地加密存储，**不上传至任何第三方服务器**。
3. 本软件**提供的信息仅供参考，不保证实时性或准确性**，请以官方平台的数据为准。
4. 本软件仅用于信息查询，所有操作均不涉及数据修改或上传。
5. 本软件为免费&开源软件，遵循 [MIT 协议](https://opensource.org/license/mit) [发布](https://github.com/wyvern1723/sachet)，**对应用的运行情况不作任何形式的担保**。

PS: 本软件只整合了教务系统的部分常用功能，完整功能请使用教务系统。

Tip: 课程表、考试时间等信息优先使用缓存数据，如需最新数据请手动刷新（右上角）。
""";

/// 夏令时每节课的开始时间
const List classSessionSummerRoutineStartTime = [
  "08:00",
  "08:55",
  "10:10",
  "11:05",
  "14:30",
  "15:25",
  "16:40",
  "17:35",
  "19:30",
  "20:25",
  "21:20",
];

/// 夏令时每节课的结束时间
const List classSessionSummerRoutineEndTime = [
  "08:45",
  "09:40",
  "10:55",
  "11:50",
  "15:15",
  "16:10",
  "17:25",
  "18:20",
  "20:15",
  "21:10",
  "22:05",
];

/// 冬令时每节课的开始时间
const List classSessionWinterRoutineStartTime = [
  "08:00",
  "08:55",
  "10:10",
  "11:05",
  "14:00",
  "14:55",
  "16:10",
  "17:05",
  "19:00",
  "19:55",
  "20:50",
];

/// 冬令时每节课的结束时间
const List classSessionWinterRoutineEndTime = [
  "08:45",
  "09:40",
  "10:55",
  "11:50",
  "14:45",
  "15:40",
  "16:55",
  "17:50",
  "19:45",
  "20:40",
  "21:35",
];
