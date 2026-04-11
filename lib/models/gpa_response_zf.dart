import 'package:sachet/utils/json_safe_parse.dart';

/// 从正方教务系统获取的平均学分绩点排名信息
class GpaResponseZF {
  /// 学号
  String? xhId;

  String? bhId;

  /// 年级名称(入学年级，xx级)
  String? njmc;

  /// 学院名称
  String? jgmc;

  /// 班级
  String? bj;

  /// 专业名称
  String? zymc;

  /// 平均学分绩点
  String? pjxfjd;

  /// 绩点班级排名
  int? jdbjpm;

  /// 学号
  String? xh;

  /// 姓名
  String? xm;

  /// 平均成绩
  String? pjcj;

  String? njdmId;
  String? jgId;
  String? zyhId;
  int? rowId;

  /// 绩点年级专业排名
  int? jdnjzypm;

  int? totalresult;

  GpaResponseZF({
    this.xhId,
    this.bhId,
    this.njmc,
    this.jgmc,
    this.bj,
    this.zymc,
    this.pjxfjd,
    this.jdbjpm,
    this.xh,
    this.xm,
    this.pjcj,
    this.njdmId,
    this.jgId,
    this.zyhId,
    this.rowId,
    this.jdnjzypm,
    this.totalresult,
  });

  GpaResponseZF.fromJson(Map<String, dynamic> json) {
    xhId = json.safeString('xh_id');
    bhId = json.safeString('bh_id');
    njmc = json.safeString('njmc');
    jgmc = json.safeString('jgmc');
    bj = json.safeString('bj');
    zymc = json.safeString('zymc');
    pjxfjd = json.safeString('pjxfjd');
    jdbjpm = json.safeInt('jdbjpm');
    xh = json.safeString('xh');
    xm = json.safeString('xm');
    pjcj = json.safeString('pjcj');
    njdmId = json.safeString('njdm_id');
    jgId = json.safeString('jg_id');
    zyhId = json.safeString('zyh_id');
    rowId = json.safeInt('row_id');
    jdnjzypm = json.safeInt('jdnjzypm');
    totalresult = json.safeInt('totalresult');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'xh_id': xhId,
      'bh_id': bhId,
      'njmc': njmc,
      'jgmc': jgmc,
      'bj': bj,
      'zymc': zymc,
      'pjxfjd': pjxfjd,
      'jdbjpm': jdbjpm,
      'xh': xh,
      'xm': xm,
      'pjcj': pjcj,
      'njdm_id': njdmId,
      'jg_id': jgId,
      'zyh_id': zyhId,
      'row_id': rowId,
      'jdnjzypm': jdnjzypm,
      'totalresult': totalresult,
    };
  }
}
