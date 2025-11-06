import 'package:flutter/foundation.dart';

enum Day { today, tomorrow }

/// 节次选择模式 与/或。
///
///  如果是 与 模式，选择了 12 和 34 节，那么筛选 12 和 34 节都空闲的。
///
///  如果是 或 模式，选择了 12 和 34 节，那么筛选 12 和 34 节中至少有一个是空闲的。
enum SessionFilterMode { and, or }

Map<String, SessionFilterMode> sessionFilterModeMap = {
  "与": SessionFilterMode.and,
  "或": SessionFilterMode.or
};

Map<String, int> sessionFilter = {
  '12': 1,
  '34': 2,
  '56': 3,
  '78': 4,
  '9 10 11': 5,
};

Map<String, String> classRoomFilter = {
  '逸夫楼': '逸夫楼',
  '一教楼': '一教楼',
  '兴教楼': '兴教楼',
  '外语楼': '外语楼',
  '第三教学楼': '第三教学楼',
  '兴湘学院三教': '兴湘学院三教',
  '尚美楼': '尚美楼',
  '经管楼': '经管楼',
  '行远楼': '行远楼',
  '南山': '南山',
  '北山': '北山',
  '其他': '其他'
};

class FreeClassPageProvider extends ChangeNotifier {
  /// 完整的(未经筛选的)今日空闲教室数据
  late List<List<String>> _allDataToday;

  /// 经过筛选的今日空闲教室数据
  List<List<String>> _filteredDataToday = [];
  List<List<String>> get filteredDataToday => _filteredDataToday;

  /// 完整的(未经筛选的)明日空闲教室数据
  List<List<String>>? _allDataTomorrow;

  /// 经过筛选的明日空闲教室数据
  List<List<String>> _filteredDataTomorrow = [];
  List<List<String>> get filteredDataTomorrow => _filteredDataTomorrow;

  /// 完整的(未经筛选的)的其他日期空闲教室数据
  List<List<List<String>>> _allDataOtherDays = [];

  /// 经过筛选的其他日期空闲教室数据
  List<List<List<String>>> _filteredDataOtherDays = [];
  List<List<List<String>>> get filteredDataOtherDays => _filteredDataOtherDays;

  bool _hasData = false;
  bool get hasData => _hasData;

  List<String> _selectedRoomFilters = [];
  List<String> get selectedRoomFilters => _selectedRoomFilters;

  /// 节次筛选
  List<int> _selectedSessionFilters = [];
  List<int> get selectedSessionFilters => _selectedSessionFilters;

  SessionFilterMode _sessionFilterMode = SessionFilterMode.or;
  SessionFilterMode get sessionFilterMode => _sessionFilterMode;

  /// 教室是否全选
  bool get isClassroomFiltersAllSelected =>
      listEquals(_selectedRoomFilters, classRoomFilter.values.toList());

  /// 设置 _hasData (是否有空闲教室数据) 为 true
  void setHasData() {
    _hasData = true;
    notifyListeners();
  }

  /// 设置今日/明日全部空闲教室数据
  void setAllClassroomsDataForTodayOrTomorrow(
      List<List<String>> data, Day day) {
    switch (day) {
      case Day.today:
        _allDataToday = data;
      case Day.tomorrow:
        _allDataTomorrow = data;
    }
    notifyListeners();
  }

  /// 设置某一天的全部空闲教室数据
  void setAllClassroomsDataForOtherDay(List<List<String>> data) {
    _allDataOtherDays.add(data);
    notifyListeners();
  }

  /// 为今日/明日设置空闲教室数据
  void setClassroomsDataForTodayOrTomorrow(List<List<String>> data, Day day) {
    switch (day) {
      case Day.today:
        _filteredDataToday = data;
        break;
      case Day.tomorrow:
        // 如果筛选过（可能是在「今日」页面筛选过，这时还没有加载「明日」的数据，所以「明日」数据没被筛选，需要在此时传入数据时筛选）
        if (_selectedRoomFilters.isNotEmpty ||
            _selectedSessionFilters.isNotEmpty) {
          _filteredDataTomorrow = getFilteredClassrooms(
            data,
            roomFilterList: _selectedRoomFilters,
            sessionFilterList: _selectedSessionFilters,
          );
        } else {
          // 如果没筛选过，赋原始值
          _filteredDataTomorrow = data;
        }
        break;
    }
    notifyListeners();
  }

  /// 为某一自选日期设置（添加）空闲教室数据
  void setClassroomsDataForOtherDay(List<List<String>> data) {
    // 如果筛选过（可能是在「今日」页面筛选过，这时还没有加载「自选日期」的数据，所以「自选日期」数据没被筛选，需要在此时传入数据时筛选）
    if (_selectedRoomFilters.isNotEmpty || _selectedSessionFilters.isNotEmpty) {
      final filteredData = getFilteredClassrooms(
        data,
        roomFilterList: _selectedRoomFilters,
        sessionFilterList: _selectedSessionFilters,
      );
      _filteredDataOtherDays.add(filteredData);
    } else {
      // 如果没筛选过，赋原始值
      _filteredDataOtherDays.add(data);
    }
    notifyListeners();
  }

  /// 输入 原始列表、教室筛选列表、节次筛选列表，输出 筛选后列表
  List<List<String>> getFilteredClassrooms(
    List<List<String>> originList, {
    List<String>? roomFilterList,
    List<int>? sessionFilterList,
  }) {
    late List<List<String>> filteredClassrooms;

    if (roomFilterList != null && roomFilterList.isNotEmpty) {
      if (sessionFilterList != null && sessionFilterList.isNotEmpty) {
        switch (_sessionFilterMode) {
          case SessionFilterMode.or:
            filteredClassrooms = originList
                .where((i) =>
                    roomFilterList
                        .any((roomFilter) => i[0].contains(roomFilter)) &&
                    sessionFilterList
                        .any((sessionFilter) => i[sessionFilter] == '空'))
                .toList();
            break;
          case SessionFilterMode.and:
            filteredClassrooms = originList
                .where((i) =>
                    roomFilterList
                        .any((roomFilter) => i[0].contains(roomFilter)) &&
                    sessionFilterList
                        .every((sessionFilter) => i[sessionFilter] == '空'))
                .toList();
            break;
        }
      } else {
        filteredClassrooms = originList
            .where((i) =>
                roomFilterList.any((roomFilter) => i[0].contains(roomFilter)))
            .toList();
      }
    } else if (sessionFilterList != null && sessionFilterList.isNotEmpty) {
      switch (_sessionFilterMode) {
        case SessionFilterMode.or:
          filteredClassrooms = originList
              .where((i) => sessionFilterList
                  .any((sessionFilter) => i[sessionFilter] == '空'))
              .toList();
          break;
        case SessionFilterMode.and:
          filteredClassrooms = originList
              .where((i) => sessionFilterList
                  .every((sessionFilter) => i[sessionFilter] == '空'))
              .toList();
          break;
      }
    } else {
      // roomFilterList 和 sessionFilterList 都是 null 或 empty，不筛选，返回原始 List
      filteredClassrooms = originList;
    }
    return filteredClassrooms;
  }

  /// 反向筛选。输入 原始列表，筛选列表，输出 反向筛选后（不含筛选列表中关键词）的列表
  List<List<String>> getReverseFilteredClassrooms(
      List<List<String>> originList, List roomFilterList) {
    // 没有用 getFilteredClassrooms 这个函数，因为如果 roomFilterList.isEmpty，getFilteredClassrooms 是不按 room 进行筛选的，
    // 但在这种获取反向筛选结果的情况下，即使 roomFilterList.isEmpty, 也需要筛选，就是返回一个空 List
    List filteredClassrooms = originList
        .where((i) =>
            roomFilterList.any((roomFilter) => i[0].contains(roomFilter)))
        .toList();
    List<List<String>> reversefilteredClassrooms = List.of(originList);
    filteredClassrooms.forEach(reversefilteredClassrooms.remove);
    return reversefilteredClassrooms;
  }

  /// 筛选
  void filter() {
    // 注意！筛选时 选择全部节次 和 不筛选节次 是不同的
    // 「不筛选节次」完全不管节次信息，会显示一天都是满的教室，
    // 而「筛选全部节次」，也会对节次信息进行筛选，即使选择「或」模式，也要至少有一节是空闲的才符合条件，不会显示一天都是满的教室
    if (_selectedRoomFilters.contains('其他')) {
      List<String> newRoomFilterList = classRoomFilter.values.toList();
      _selectedRoomFilters.forEach(newRoomFilterList
          .remove); // newRoomFilterList 删除 _classRoomFilters 中的每个元素，得到反选的教室筛选列表
      List<List<String>> reversefilteredClassroomsToday =
          getReverseFilteredClassrooms(
        _allDataToday,
        newRoomFilterList,
      );
      _filteredDataToday = getFilteredClassrooms(
        reversefilteredClassroomsToday,
        sessionFilterList: _selectedSessionFilters,
      );
      if (_allDataTomorrow != null) {
        List<List<String>> reversefilteredClassroomsTomorrow =
            getReverseFilteredClassrooms(
          _allDataTomorrow!,
          newRoomFilterList,
        );
        _filteredDataTomorrow = getFilteredClassrooms(
          reversefilteredClassroomsTomorrow,
          sessionFilterList: _selectedSessionFilters,
        );
      }
      if (_allDataOtherDays.isNotEmpty) {
        for (var i = 0; i < _allDataOtherDays.length; i++) {
          List<List<String>> reversefilteredDataOtherDay =
              getReverseFilteredClassrooms(
            _allDataOtherDays[i],
            newRoomFilterList,
          );
          final filteredOtherDay = getFilteredClassrooms(
            reversefilteredDataOtherDay,
            sessionFilterList: _selectedSessionFilters,
          );
          _filteredDataOtherDays[i] = filteredOtherDay;
        }
      }
      notifyListeners();
    } else {
      _filteredDataToday = getFilteredClassrooms(
        _allDataToday,
        roomFilterList: _selectedRoomFilters,
        sessionFilterList: _selectedSessionFilters,
      );
      if (_allDataTomorrow != null) {
        _filteredDataTomorrow = getFilteredClassrooms(
          _allDataTomorrow!,
          roomFilterList: _selectedRoomFilters,
          sessionFilterList: _selectedSessionFilters,
        );
      }
      if (_allDataOtherDays.isNotEmpty) {
        for (var i = 0; i < _allDataOtherDays.length; i++) {
          final filteredOtherDay = getFilteredClassrooms(
            _allDataOtherDays[i],
            roomFilterList: _selectedRoomFilters,
            sessionFilterList: _selectedSessionFilters,
          );
          _filteredDataOtherDays[i] = filteredOtherDay;
        }
      }
      notifyListeners();
    }
  }

  /// 在教室筛选列表添加一项
  void addClassRoomFilter(String value) {
    List<String> newList = List.of(_selectedRoomFilters);
    newList.add(value);
    _selectedRoomFilters = newList;
    notifyListeners();
  }

  /// 在教室筛选列表移除一项
  void removeClassRoomFilter(String value) {
    List<String> newList = List.of(_selectedRoomFilters);
    newList.remove(value);
    _selectedRoomFilters = newList;
    notifyListeners();
  }

  /// 把全部教室可筛选数据都加入教室筛选列表
  void addAllToClassRoomFilters() {
    List<String> newList = classRoomFilter.values.toList();
    _selectedRoomFilters = newList;
    notifyListeners();
  }

  /// 清除教室筛选列表
  void clearClassRoomFilters() {
    List<String> newList = [];
    _selectedRoomFilters = newList;
    notifyListeners();
  }

  /// 在节次筛选列表添加一项
  void addSessionFilter(int value) {
    List<int> newList = List.of(_selectedSessionFilters);
    newList.add(value);
    _selectedSessionFilters = newList;
    notifyListeners();
  }

  /// 在节次筛选列表移除一项
  void removeSessionFilter(int value) {
    List<int> newList = List.of(_selectedSessionFilters);
    newList.remove(value);
    _selectedSessionFilters = newList;
    notifyListeners();
  }

  /// 把全部节次可筛选数据都加入节次筛选列表
  void addAllToSessionFliters() {
    List<int> newList = sessionFilter.values.toList();
    _selectedSessionFilters = newList;
    notifyListeners();
  }

  /// 取消筛选
  void clearFilters() {
    // 清除筛选列表
    _selectedRoomFilters = List.empty();
    _selectedSessionFilters = List.empty();

    /// 把空闲教室数据设为全部数据
    _filteredDataToday = _allDataToday;
    _filteredDataTomorrow = _allDataToday;
    _filteredDataOtherDays = _allDataOtherDays;
    notifyListeners();
  }

  /// 设置节次筛选模式（与/或）
  void setSessionFilterMode(SessionFilterMode mode) {
    _sessionFilterMode = mode;
    notifyListeners();
  }
}
