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
    xhId = json['xh_id'];
    bhId = json['bh_id'];
    njmc = json['njmc'];
    jgmc = json['jgmc'];
    bj = json['bj'];
    zymc = json['zymc'];
    pjxfjd = json['pjxfjd'];
    jdbjpm = json['jdbjpm'];
    xh = json['xh'];
    xm = json['xm'];
    pjcj = json['pjcj'];
    njdmId = json['njdm_id'];
    jgId = json['jg_id'];
    zyhId = json['zyh_id'];
    rowId = json['row_id'];
    jdnjzypm = json['jdnjzypm'];
    totalresult = json['totalresult'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xh_id'] = this.xhId;
    data['bh_id'] = this.bhId;
    data['njmc'] = this.njmc;
    data['jgmc'] = this.jgmc;
    data['bj'] = this.bj;
    data['zymc'] = this.zymc;
    data['pjxfjd'] = this.pjxfjd;
    data['jdbjpm'] = this.jdbjpm;
    data['xh'] = this.xh;
    data['xm'] = this.xm;
    data['pjcj'] = this.pjcj;
    data['njdm_id'] = this.njdmId;
    data['jg_id'] = this.jgId;
    data['zyh_id'] = this.zyhId;
    data['row_id'] = this.rowId;
    data['jdnjzypm'] = this.jdnjzypm;
    data['totalresult'] = this.totalresult;
    return data;
  }
}
