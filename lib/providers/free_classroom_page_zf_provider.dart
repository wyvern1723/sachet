import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/models/free_classroom_filter_options.dart';
import 'package:sachet/models/free_classroom_request_data.dart';
import 'package:sachet/models/free_classroom_data_zf.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/time_manager.dart';
import 'package:sachet/services/zhengfang_jwxt/get_data/get_free_classroom.dart';

List<int> weekCountOptions = List.generate(20, (i) => (i + 1));

List<int> weekdayOptions = List.generate(7, (i) => (i + 1));

List<int> sessionOptions = List.generate(11, (i) => (i + 1));

Map<String, String> campusTypeMap = {"校本部": "02", "兴湘学院": "03"};

class FreeClassroomPageZFProvider extends ChangeNotifier {
  // ================================================
  // ========== filterOptions(可筛选的数据) ===========
  // ================================================
  FreeClassroomFilterOptionsZF? _filterOptions;
  FreeClassroomFilterOptionsZF? get filterOptions => _filterOptions;

  void setFilterOptions(FreeClassroomFilterOptionsZF options) {
    _filterOptions = options;
    setSemester(options.selectedSemester);
  }

  // =====================================
  // ========== Semester(学期) ===========
  // =====================================
  String _semesterYear = '';
  String _semesterIndex = '';

  String get semesterYear => _semesterYear;
  String get semesterIndex => _semesterIndex;

  /// 设置当前学期
  void setSemester(String? selectedSemester) {
    if (selectedSemester == null) {
      // TODO: 处理 selectedSemester 为 null 的情况
    } else {
      _semesterYear = selectedSemester.split('-')[0];
      _semesterIndex = selectedSemester.split('-')[1];
    }
  }

  // =====================================
  // ========== WeekCounts(周次) ==========
  // =====================================

  Set<int> _selectedWeekCounts = {
    weekCountOfToday(DateTime.tryParse(SettingsProvider.semesterStartDate) ??
            constSemesterStartDate)
        .clamp(1, 20) // 限制最小为 1, 最大为 20 周
  };

  /// 选择的周次（可能有多个）
  Set<int> get selectedWeekCounts => _selectedWeekCounts;

  List<bool> get weekCountsSelection =>
      weekCountOptions.map((e) => _selectedWeekCounts.contains(e)).toList();

  void setSelectedWeekCount(int week, bool isSingleChoice) {
    _toggleSelection(
      selection: _selectedWeekCounts,
      value: week,
      isSingleChoice: isSingleChoice,
    );
    notifyListeners();
  }

  void setSelectedWeekCountsAddAll() {
    _selectedWeekCounts.addAll(weekCountOptions);
    notifyListeners();
  }

  void setSelectedWeekCountsRemoveAll() {
    _selectedWeekCounts.clear();
    notifyListeners();
  }

  /// 重置 _selectedWeekCounts 为 [今天的 weekCount]
  ///
  /// 例如: 如果今天的周次是第二周，则重置为 [2]
  void resetSelectedWeekCounts() {
    _selectedWeekCounts = {
      weekCountOfToday(DateTime.tryParse(SettingsProvider.semesterStartDate) ??
              constSemesterStartDate)
          .clamp(1, 20) // 限制最小为 1, 最大为 20 周
    };
  }

  // =====================================
  // ========== Weekdays(星期几) ==========
  // =====================================

  Set<int> _selectedWeekdays = {DateTime.now().weekday};

  /// 选择的星期几（可能有多个）
  Set<int> get selectedWeekdays => _selectedWeekdays;

  List<bool> get weekdaysSelection =>
      weekdayOptions.map((e) => _selectedWeekdays.contains(e)).toList();

  void setSelectedWeekday(int weekday, bool isSingleChoice) {
    _toggleSelection(
      selection: _selectedWeekdays,
      value: weekday,
      isSingleChoice: isSingleChoice,
    );
    notifyListeners();
  }

  void setSelectedWeekdaysAddAll() {
    _selectedWeekdays.addAll(weekdayOptions);
    notifyListeners();
  }

  void setSelectedWeekdaysRemoveAll() {
    _selectedWeekdays.clear();
    notifyListeners();
  }

  /// 重置 _selectedWeekdays 为 [今天的 weekday]
  ///
  /// 例如: 如果今天是星期三，则重置为 [3]
  void resetSelectedWeekdays() {
    _selectedWeekdays = {DateTime.now().weekday};
  }

  // ===================================
  // ========== Sessions(节次) ==========
  // ===================================

  Set<int> _selectedSessions = {};

  /// 选择的节次（可能有多个）
  Set<int> get selectedSessions => _selectedSessions;

  List<bool> get sessionsSelection =>
      sessionOptions.map((e) => _selectedSessions.contains(e)).toList();

  void setSelectedSession(int week) {
    _toggleSelection(
      selection: _selectedSessions,
      value: week,
      isSingleChoice: false,
    );
    notifyListeners();
  }

  void setSelectedSessionsAddAll() {
    _selectedSessions.addAll(sessionOptions);
    notifyListeners();
  }

  void setSelectedSessionsRemoveAll() {
    _selectedSessions.clear();
    notifyListeners();
  }

  // ===============================
  // ========== Date(日期) ==========
  // ===============================

  /// 选择的日期(仅在选择单日生效)
  DateTime get selectedDate => getDateFromWeekCountAndWeekday(
        semesterStartDate:
            DateTime.tryParse(SettingsProvider.semesterStartDate) ??
                constSemesterStartDate,
        weekCount: selectedWeekCounts.elementAt(0),
        weekday: selectedWeekdays.elementAt(0),
      );

  // ==================================
  // ========== Campus(校区) ===========
  // ==================================

  String _selectedCampus = '02';

  /// 选择的校区, 默认为 "校本部"("02"), 网页查询可选 "兴湘学院"("03"),但无数据
  String get selectedCampus => _selectedCampus;

  void setSelectedCampus(String value) {
    _selectedCampus = value;
    notifyListeners();
  }

  // =============================================
  // ========== TeachingBuilding(教学楼) ==========
  // =============================================

  String _selectedTeachingBuilding = '';

  /// 选择的教学楼, 默认为 "全部" ("")
  String get selectedTeachingBuilding => _selectedTeachingBuilding;

  void setSelectedTeachingBuilding(String value) {
    _selectedTeachingBuilding = value;
    notifyListeners();
  }
  // =========================================
  // ========== PlaceType(场地类别 ) ==========
  // =========================================

  String _selectedPlaceType = '01';

  /// 选择的场地类别, 默认为 "教室" ("01")
  String get selectedPlaceType => _selectedPlaceType;

  void setSelectedPlaceType(String value) {
    _selectedPlaceType = value;
    notifyListeners();
  }

  // =======================================
  // ========== SeatAmount(座位数) ==========
  // =======================================

  static const double seatAmountMin = 1.0; // 座位数最小值，也是滑块最小值
  static const double seatAmountMax =
      201.0; // 座位数最大值，也是滑块最大值(当滑块达到最大值即变成"∞"(不限制最大值))

  /// 是否筛选座位数（默认不筛选，即不限制座位数量）
  bool _isFilterSeatAmount = false;
  bool get isFilterSeatAmount => _isFilterSeatAmount;

  double _currentMinSeatAmount = 1.0;
  double? _currentMaxSeatAmount;

  /// 当前筛选的座位最小值
  double get currentMinSeatAmount => _currentMinSeatAmount;

  /// 当前筛选的座位最大值
  double? get currentMaxSeatAmount => _currentMaxSeatAmount;

  /// 切换是否筛选座位数
  void toggleIsFilterSeatAmount() {
    _isFilterSeatAmount = !_isFilterSeatAmount;
    notifyListeners();
  }

  /// 更新范围值（来自滑块）
  void updateSeatAmountRangeValues(RangeValues values) {
    _currentMinSeatAmount = values.start;
    if (values.end == seatAmountMax) {
      _currentMaxSeatAmount = null;
    } else {
      _currentMaxSeatAmount = values.end;
    }
    notifyListeners();
  }

  /// 更新最小座位数（来自输入框）
  void updateMinSeatAmount(String value) {
    if (value.isEmpty) return;
    final double num = double.tryParse(value) ?? 0.0;
    double newMin = 0.0;
    if (_currentMaxSeatAmount == null) {
      newMin = max(0.0, num);
    } else {
      newMin = num.clamp(0.0, _currentMaxSeatAmount!);
    }
    _currentMinSeatAmount = newMin;
    notifyListeners();
  }

  /// 更新最大座位数（来自输入框）
  void updateMaxSeatAmount(String value) {
    if (value.isEmpty) {
      _currentMaxSeatAmount = null;
    } else {
      final double num = double.tryParse(value) ?? 0.0;
      _currentMaxSeatAmount = num;
    }
    notifyListeners();
  }

  // ================================
  // ========== 通用私有方法 ==========
  // ================================

  /// 切换选中状态，
  ///
  /// 如果 [isSingleChoice] = [true], 清除所有选中项，添加当前的点击项
  /// 如果 [isSingleChoice] = [false], 反选当前的点击项
  void _toggleSelection({
    required Set<int> selection,
    required int value,
    required bool isSingleChoice,
  }) {
    if (isSingleChoice) {
      selection.clear();
      selection.add(value);
    } else {
      if (selection.contains(value)) {
        selection.remove(value);
      } else {
        selection.add(value);
      }
    }
  }

  void validateSelectedData() {
    if (_selectedWeekCounts.isEmpty) {
      throw '周次';
    }
    if (_selectedWeekdays.isEmpty) {
      throw '星期';
    }
    if (_selectedSessions.isEmpty) {
      throw '节次';
    }
  }

  Future<List<FreeClassroomDataZF>> getData({
    required String cookie,
  }) async {
    final String zcd =
        calculateZcdOrJcd(_selectedWeekCounts.toList()).toString();
    final String jcd = calculateZcdOrJcd(_selectedSessions.toList()).toString();
    final String xqj = (_selectedWeekdays.toList()..sort()).join(',');
    final String nd = DateTime.now().millisecondsSinceEpoch.toString();
    String minSeatAmount =
        !_isFilterSeatAmount ? "" : _currentMinSeatAmount.round().toString();
    String maxSeatAmount =
        (!_isFilterSeatAmount || _currentMaxSeatAmount == null)
            ? ""
            : _currentMaxSeatAmount!.round().toString();
    final Map data = FreeClassroomRequestDataZF(
      xqhId: _selectedCampus,
      xnm: _semesterYear,
      xqm: _semesterIndex,
      cdlbId: _selectedPlaceType,
      qszws: minSeatAmount,
      jszws: maxSeatAmount,
      zcd: zcd,
      xqj: xqj,
      jcd: jcd,
      lh: _selectedTeachingBuilding,
      nd: nd,
    ).toJson();

    final List<FreeClassroomDataZF> result = await getFreeClassroomZF(
      cookie: cookie,
      data: data,
    );
    return result;
  }
}
