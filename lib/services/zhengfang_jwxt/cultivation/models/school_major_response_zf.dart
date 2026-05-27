import 'package:sachet/utils/json_safe_parse.dart';

/// 学院下专业信息
class SchoolMajorResponseZF {
  /// 学院 ID: "002"
  String? jgId;

  /// 学院名称: "哲学与历史文化学院（碧泉书院）"
  String? jgmc;

  String? jgpxzd;
  bool? listnav;
  String? localeKey;
  bool? pageable;
  QueryModel? queryModel;
  bool? rangeable;
  String? totalResult;
  UserModel? userModel;

  /// 专业号: "00102"
  String? zyh;

  /// 专业号ID: "00102"
  String? zyhId;

  /// 专业简称: "哲学"
  String? zyjc;

  /// 专业名称: "哲学(00102)"
  String? zymc;

  SchoolMajorResponseZF({
    this.jgId,
    this.jgmc,
    this.jgpxzd,
    this.listnav,
    this.localeKey,
    this.pageable,
    this.queryModel,
    this.rangeable,
    this.totalResult,
    this.userModel,
    this.zyh,
    this.zyhId,
    this.zyjc,
    this.zymc,
  });

  factory SchoolMajorResponseZF.fromJson(Map<String, dynamic> json) {
    return SchoolMajorResponseZF(
      jgId: json.safeString('jg_id'),
      jgmc: json.safeString('jgmc'),
      jgpxzd: json.safeString('jgpxzd'),
      listnav: json.safeBool('listnav'),
      localeKey: json.safeString('localeKey'),
      pageable: json.safeBool('pageable'),
      queryModel: json['queryModel'] != null
          ? QueryModel.fromJson(json['queryModel'] as Map<String, dynamic>)
          : null,
      rangeable: json.safeBool('rangeable'),
      totalResult: json.safeString('totalResult'),
      userModel: json['userModel'] != null
          ? UserModel.fromJson(json['userModel'] as Map<String, dynamic>)
          : null,
      zyh: json.safeString('zyh'),
      zyhId: json.safeString('zyh_id'),
      zyjc: json.safeString('zyjc'),
      zymc: json.safeString('zymc'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['jg_id'] = jgId;
    data['jgmc'] = jgmc;
    data['jgpxzd'] = jgpxzd;
    data['listnav'] = listnav;
    data['localeKey'] = localeKey;
    data['pageable'] = pageable;
    if (queryModel != null) {
      data['queryModel'] = queryModel!.toJson();
    }
    data['rangeable'] = rangeable;
    data['totalResult'] = totalResult;
    if (userModel != null) {
      data['userModel'] = userModel!.toJson();
    }
    data['zyh'] = zyh;
    data['zyh_id'] = zyhId;
    data['zyjc'] = zyjc;
    data['zymc'] = zymc;

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

  factory QueryModel.fromJson(Map<String, dynamic> json) {
    return QueryModel(
      currentPage: json.safeInt('currentPage'),
      currentResult: json.safeInt('currentResult'),
      entityOrField: json.safeBool('entityOrField'),
      limit: json.safeInt('limit'),
      offset: json.safeInt('offset'),
      pageNo: json.safeInt('pageNo'),
      pageSize: json.safeInt('pageSize'),
      showCount: json.safeInt('showCount'),
      sorts: json['sorts'] as List<dynamic>?,
      totalCount: json.safeInt('totalCount'),
      totalPage: json.safeInt('totalPage'),
      totalResult: json.safeInt('totalResult'),
    );
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

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      monitor: json.safeBool('monitor'),
      roleCount: json.safeInt('roleCount'),
      roleKeys: json.safeString('roleKeys'),
      roleValues: json.safeString('roleValues'),
      status: json.safeInt('status'),
      usable: json.safeBool('usable'),
    );
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
