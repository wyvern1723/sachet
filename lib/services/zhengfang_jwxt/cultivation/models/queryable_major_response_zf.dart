import 'package:sachet/utils/json_safe_parse.dart';

/// 从正方教务培养方案页面查询到的可查询培养方案（课程信息）的专业
class QueryableMajorResponseZF {
  String? bjgs;
  String? date;
  String? dateDigit;
  String? dateDigitSeparator;
  String? day;
  String? dlbs;
  String? jgId;
  String? jgpxzd;
  String? jhrs;
  String? jxzxjhxxId;
  String? kcs;
  String? listnav;
  String? localeKey;
  String? month;
  String? njdm;
  String? njmc;
  int? pageTotal;
  bool? pageable;
  QueryModel? queryModel;
  bool? rangeable;
  String? rowId;
  String? rwbj;
  String? sfgazy;
  String? totalResult;
  UserModel? userModel;
  String? xqhId;
  String? xqmc;
  String? xz;
  String? year;
  String? zdxf;
  String? zyfxgs;
  String? zyh;
  String? zyhId;
  String? zymc;

  QueryableMajorResponseZF({
    this.bjgs,
    this.date,
    this.dateDigit,
    this.dateDigitSeparator,
    this.day,
    this.dlbs,
    this.jgId,
    this.jgpxzd,
    this.jhrs,
    this.jxzxjhxxId,
    this.kcs,
    this.listnav,
    this.localeKey,
    this.month,
    this.njdm,
    this.njmc,
    this.pageTotal,
    this.pageable,
    this.queryModel,
    this.rangeable,
    this.rowId,
    this.rwbj,
    this.sfgazy,
    this.totalResult,
    this.userModel,
    this.xqhId,
    this.xqmc,
    this.xz,
    this.year,
    this.zdxf,
    this.zyfxgs,
    this.zyh,
    this.zyhId,
    this.zymc,
  });

  factory QueryableMajorResponseZF.fromJson(Map<String, dynamic> json) {
    return QueryableMajorResponseZF(
      bjgs: json.safeString('bjgs'),
      date: json.safeString('date'),
      dateDigit: json.safeString('dateDigit'),
      dateDigitSeparator: json.safeString('dateDigitSeparator'),
      day: json.safeString('day'),
      dlbs: json.safeString('dlbs'),
      jgId: json.safeString('jg_id'),
      jgpxzd: json.safeString('jgpxzd'),
      jhrs: json.safeString('jhrs'),
      jxzxjhxxId: json.safeString('jxzxjhxx_id'),
      kcs: json.safeString('kcs'),
      listnav: json.safeString('listnav'),
      localeKey: json.safeString('localeKey'),
      month: json.safeString('month'),
      njdm: json.safeString('njdm'),
      njmc: json.safeString('njmc'),
      pageTotal: json.safeInt('pageTotal'),
      pageable: json.safeBool('pageable'),
      queryModel: json['queryModel'] != null
          ? QueryModel.fromJson(json['queryModel'])
          : null,
      rangeable: json.safeBool('rangeable'),
      rowId: json.safeString('row_id'),
      rwbj: json.safeString('rwbj'),
      sfgazy: json.safeString('sfgazy'),
      totalResult: json.safeString('totalResult'),
      userModel: json['userModel'] != null
          ? UserModel.fromJson(json['userModel'])
          : null,
      xqhId: json.safeString('xqh_id'),
      xqmc: json.safeString('xqmc'),
      xz: json.safeString('xz'),
      year: json.safeString('year'),
      zdxf: json.safeString('zdxf'),
      zyfxgs: json.safeString('zyfxgs'),
      zyh: json.safeString('zyh'),
      zyhId: json.safeString('zyh_id'),
      zymc: json.safeString('zymc'),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bjgs'] = bjgs;
    data['date'] = date;
    data['dateDigit'] = dateDigit;
    data['dateDigitSeparator'] = dateDigitSeparator;
    data['day'] = day;
    data['dlbs'] = dlbs;
    data['jg_id'] = jgId;
    data['jgpxzd'] = jgpxzd;
    data['jhrs'] = jhrs;
    data['jxzxjhxx_id'] = jxzxjhxxId;
    data['kcs'] = kcs;
    data['listnav'] = listnav;
    data['localeKey'] = localeKey;
    data['month'] = month;
    data['njdm'] = njdm;
    data['njmc'] = njmc;
    data['pageTotal'] = pageTotal;
    data['pageable'] = pageable;
    if (queryModel != null) {
      data['queryModel'] = queryModel!.toJson();
    }
    data['rangeable'] = rangeable;
    data['row_id'] = rowId;
    data['rwbj'] = rwbj;
    data['sfgazy'] = sfgazy;
    data['totalResult'] = totalResult;
    if (userModel != null) {
      data['userModel'] = userModel!.toJson();
    }
    data['xqh_id'] = xqhId;
    data['xqmc'] = xqmc;
    data['xz'] = xz;
    data['year'] = year;
    data['zdxf'] = zdxf;
    data['zyfxgs'] = zyfxgs;
    data['zyh'] = zyh;
    data['zyh_id'] = zyhId;
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
      sorts: json['sorts'] != null ? List<dynamic>.from(json['sorts']) : null,
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
    if (sorts != null) {
      data['sorts'] = sorts;
    }
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
