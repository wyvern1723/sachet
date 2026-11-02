import 'package:sachet/utils/json_safe_parse.dart';

class ExperimentCourse {
  String? date;
  String? dateDigit;
  String? dateDigitSeparator;
  String? day;

  /// 实验房间对应场地校区
  String? dycdxq;
  String? jgpxzd;

  /// 实验人员（指导教师）
  String? jsxm;
  String? kch;

  /// 课程名称
  String? kcmc;
  String? listnav;
  String? localeKey;
  String? month;
  int? pageTotal;
  bool? pageable;
  QueryModel? queryModel;
  bool? rangeable;
  String? rowId;
  int? rsdzjs;

  /// 上课时间地点
  String? sksjdd;

  /// 实验分组名称
  String? syfzmc;
  String? totalResult;
  UserModel? userModel;
  String? xh;
  String? xm;

  /// 实验项目名称
  String? xmmc;
  String? xmzId;
  String? xnm;
  String? xqm;
  String? year;

  ExperimentCourse({
    this.date,
    this.dateDigit,
    this.dateDigitSeparator,
    this.day,
    this.dycdxq,
    this.jgpxzd,
    this.jsxm,
    this.kch,
    this.kcmc,
    this.listnav,
    this.localeKey,
    this.month,
    this.pageTotal,
    this.pageable,
    this.queryModel,
    this.rangeable,
    this.rowId,
    this.rsdzjs,
    this.sksjdd,
    this.syfzmc,
    this.totalResult,
    this.userModel,
    this.xh,
    this.xm,
    this.xmmc,
    this.xmzId,
    this.xnm,
    this.xqm,
    this.year,
  });

  ExperimentCourse.fromJson(Map<String, dynamic> json) {
    date = json.safeString('date');
    dateDigit = json.safeString('dateDigit');
    dateDigitSeparator = json.safeString('dateDigitSeparator');
    day = json.safeString('day');
    dycdxq = json.safeString('dycdxq');
    jgpxzd = json.safeString('jgpxzd');
    jsxm = json.safeString('jsxm');
    kch = json.safeString('kch');
    kcmc = json.safeString('kcmc');
    listnav = json.safeString('listnav');
    localeKey = json.safeString('localeKey');
    month = json.safeString('month');
    pageTotal = json.safeInt('pageTotal');
    pageable = json.safeBool('pageable');
    final queryModelJson = json['queryModel'];
    queryModel = queryModelJson is Map<String, dynamic>
        ? QueryModel.fromJson(queryModelJson)
        : null;
    rangeable = json.safeBool('rangeable');
    rowId = json.safeString('row_id');
    rsdzjs = json.safeInt('rsdzjs');
    sksjdd = json.safeString('sksjdd');
    syfzmc = json.safeString('syfzmc');
    totalResult = json.safeString('totalResult');
    final userModelJson = json['userModel'];
    userModel = userModelJson is Map<String, dynamic>
        ? UserModel.fromJson(userModelJson)
        : null;
    xh = json.safeString('xh');
    xm = json.safeString('xm');
    xmmc = json.safeString('xmmc');
    xmzId = json.safeString('xmz_id');
    xnm = json.safeString('xnm');
    xqm = json.safeString('xqm');
    year = json.safeString('year');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['dateDigit'] = dateDigit;
    data['dateDigitSeparator'] = dateDigitSeparator;
    data['day'] = day;
    data['dycdxq'] = dycdxq;
    data['jgpxzd'] = jgpxzd;
    data['jsxm'] = jsxm;
    data['kch'] = kch;
    data['kcmc'] = kcmc;
    data['listnav'] = listnav;
    data['localeKey'] = localeKey;
    data['month'] = month;
    data['pageTotal'] = pageTotal;
    data['pageable'] = pageable;
    if (queryModel != null) {
      data['queryModel'] = queryModel!.toJson();
    }
    data['rangeable'] = rangeable;
    data['row_id'] = rowId;
    data['rsdzjs'] = rsdzjs;
    data['sksjdd'] = sksjdd;
    data['syfzmc'] = syfzmc;
    data['totalResult'] = totalResult;
    if (userModel != null) {
      data['userModel'] = userModel!.toJson();
    }
    data['xh'] = xh;
    data['xm'] = xm;
    data['xmmc'] = xmmc;
    data['xmz_id'] = xmzId;
    data['xnm'] = xnm;
    data['xqm'] = xqm;
    data['year'] = year;
    return data;
  }
}

class QueryModel {
  int? currentPage;
  int? currentResult;
  bool? entityOrField;
  int? limit;
  int? offset;
  int? pageNo;
  int? pageSize;
  int? showCount;
  List<dynamic>? sorts;
  int? totalCount;
  int? totalPage;
  int? totalResult;

  QueryModel({
    this.currentPage,
    this.currentResult,
    this.entityOrField,
    this.limit,
    this.offset,
    this.pageNo,
    this.pageSize,
    this.showCount,
    this.sorts,
    this.totalCount,
    this.totalPage,
    this.totalResult,
  });

  QueryModel.fromJson(Map<String, dynamic> json) {
    currentPage = json.safeInt('currentPage');
    currentResult = json.safeInt('currentResult');
    entityOrField = json.safeBool('entityOrField');
    limit = json.safeInt('limit');
    offset = json.safeInt('offset');
    pageNo = json.safeInt('pageNo');
    pageSize = json.safeInt('pageSize');
    showCount = json.safeInt('showCount');
    final sortsJson = json['sorts'];
    sorts = sortsJson is List ? List<dynamic>.from(sortsJson) : null;
    totalCount = json.safeInt('totalCount');
    totalPage = json.safeInt('totalPage');
    totalResult = json.safeInt('totalResult');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currentPage'] = currentPage;
    data['currentResult'] = currentResult;
    data['entityOrField'] = entityOrField;
    data['limit'] = limit;
    data['offset'] = offset;
    data['pageNo'] = pageNo;
    data['pageSize'] = pageSize;
    data['showCount'] = showCount;
    data['sorts'] = sorts;
    data['totalCount'] = totalCount;
    data['totalPage'] = totalPage;
    data['totalResult'] = totalResult;
    return data;
  }
}

class UserModel {
  bool? monitor;
  int? roleCount;
  String? roleKeys;
  String? roleValues;
  int? status;
  bool? usable;

  UserModel({
    this.monitor,
    this.roleCount,
    this.roleKeys,
    this.roleValues,
    this.status,
    this.usable,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    monitor = json.safeBool('monitor');
    roleCount = json.safeInt('roleCount');
    roleKeys = json.safeString('roleKeys');
    roleValues = json.safeString('roleValues');
    status = json.safeInt('status');
    usable = json.safeBool('usable');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['monitor'] = monitor;
    data['roleCount'] = roleCount;
    data['roleKeys'] = roleKeys;
    data['roleValues'] = roleValues;
    data['status'] = status;
    data['usable'] = usable;
    return data;
  }
}
