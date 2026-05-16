import 'package:sachet/utils/json_safe_parse.dart';

class ReserveTextbookResponseZF {
  String? xhId;
  String? sfmgcjcmc;

  /// 学年名名称，例如 "2025-2026"
  String? xnmmc;

  String? sfmgckc;
  String? discountPrice;

  /// ISBN
  String? isbn;

  /// 教材作者
  String? jczz;

  String? jxbId;
  String? kchId;
  String? kch;
  String? jcytbj;
  String? xqm;

  /// 单价
  String? price;

  String? xssfxyyd;
  int? yyds;
  String? kc;

  /// 上课时间
  String? sksj;

  /// 课程名称
  String? kcmc;

  String? sfxkbj;

  /// 任课教师信息
  String? rkjsxx;

  int? totalresult;
  String? sfmgckcmc;
  String? sfmgcjc;
  String? jxbmc;

  /// 版本号
  String? bbh;

  /// 教材预订状态名称
  String? jcydztmc;

  /// 学号
  String? xh;

  /// 出版日期
  String? cbrq;

  /// 折扣？
  int? zk;

  /// 选课时间
  String? xksj;

  /// 课程性质名称
  String? kcxzmc;

  String? jcydzt;
  String? jfztmc;

  /// 出版社
  String? cbs;

  /// （学生）姓名
  String? xm;

  String? xnm;

  /// 教师信息
  String? jsxx;

  /// 学期名名称，例如 "1", "2"
  String? xqmmc;

  int? rowId;

  /// 教材名称
  String? jcmc;

  /// 教学地点（上课的教室）
  String? jxdd;

  ReserveTextbookResponseZF({
    this.xhId,
    this.sfmgcjcmc,
    this.xnmmc,
    this.sfmgckc,
    this.discountPrice,
    this.isbn,
    this.jczz,
    this.jxbId,
    this.kchId,
    this.kch,
    this.jcytbj,
    this.xqm,
    this.price,
    this.xssfxyyd,
    this.yyds,
    this.kc,
    this.sksj,
    this.kcmc,
    this.sfxkbj,
    this.rkjsxx,
    this.totalresult,
    this.sfmgckcmc,
    this.sfmgcjc,
    this.jxbmc,
    this.bbh,
    this.jcydztmc,
    this.xh,
    this.cbrq,
    this.zk,
    this.xksj,
    this.kcxzmc,
    this.jcydzt,
    this.jfztmc,
    this.cbs,
    this.xm,
    this.xnm,
    this.jsxx,
    this.xqmmc,
    this.rowId,
    this.jcmc,
    this.jxdd,
  });

  ReserveTextbookResponseZF.fromJson(Map<String, dynamic> json) {
    xhId = json.safeString('xh_id');
    sfmgcjcmc = json.safeString('sfmgcjcmc');
    xnmmc = json.safeString('xnmmc');
    sfmgckc = json.safeString('sfmgckc');
    discountPrice = json.safeString('discount_price');
    isbn = json.safeString('isbn');
    jczz = json.safeString('jczz');
    jxbId = json.safeString('jxb_id');
    kchId = json.safeString('kch_id');
    kch = json.safeString('kch');
    jcytbj = json.safeString('jcytbj');
    xqm = json.safeString('xqm');
    price = json.safeString('price');
    xssfxyyd = json.safeString('xssfxyyd');
    yyds = json.safeInt('yyds');
    kc = json.safeString('kc');
    sksj = json.safeString('sksj');
    kcmc = json.safeString('kcmc');
    sfxkbj = json.safeString('sfxkbj');
    rkjsxx = json.safeString('rkjsxx');
    totalresult = json.safeInt('totalresult');
    sfmgckcmc = json.safeString('sfmgckcmc');
    sfmgcjc = json.safeString('sfmgcjc');
    jxbmc = json.safeString('jxbmc');
    bbh = json.safeString('bbh');
    jcydztmc = json.safeString('jcydztmc');
    xh = json.safeString('xh');
    cbrq = json.safeString('cbrq');
    zk = json.safeInt('zk');
    xksj = json.safeString('xksj');
    kcxzmc = json.safeString('kcxzmc');
    jcydzt = json.safeString('jcydzt');
    jfztmc = json.safeString('jfztmc');
    cbs = json.safeString('cbs');
    xm = json.safeString('xm');
    xnm = json.safeString('xnm');
    jsxx = json.safeString('jsxx');
    xqmmc = json.safeString('xqmmc');
    rowId = json.safeInt('row_id');
    jcmc = json.safeString('jcmc');
    jxdd = json.safeString('jxdd');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xh_id'] = xhId;
    data['sfmgcjcmc'] = sfmgcjcmc;
    data['xnmmc'] = xnmmc;
    data['sfmgckc'] = sfmgckc;
    data['discount_price'] = discountPrice;
    data['isbn'] = isbn;
    data['jczz'] = jczz;
    data['jxb_id'] = jxbId;
    data['kch_id'] = kchId;
    data['kch'] = kch;
    data['jcytbj'] = jcytbj;
    data['xqm'] = xqm;
    data['price'] = price;
    data['xssfxyyd'] = xssfxyyd;
    data['yyds'] = yyds;
    data['kc'] = kc;
    data['sksj'] = sksj;
    data['kcmc'] = kcmc;
    data['sfxkbj'] = sfxkbj;
    data['rkjsxx'] = rkjsxx;
    data['totalresult'] = totalresult;
    data['sfmgckcmc'] = sfmgckcmc;
    data['sfmgcjc'] = sfmgcjc;
    data['jxbmc'] = jxbmc;
    data['bbh'] = bbh;
    data['jcydztmc'] = jcydztmc;
    data['xh'] = xh;
    data['cbrq'] = cbrq;
    data['zk'] = zk;
    data['xksj'] = xksj;
    data['kcxzmc'] = kcxzmc;
    data['jcydzt'] = jcydzt;
    data['jfztmc'] = jfztmc;
    data['cbs'] = cbs;
    data['xm'] = xm;
    data['xnm'] = xnm;
    data['jsxx'] = jsxx;
    data['xqmmc'] = xqmmc;
    data['row_id'] = rowId;
    data['jcmc'] = jcmc;
    data['jxdd'] = jxdd;
    return data;
  }

  item(String item) {
    switch (item) {
      case '课程名称':
        return kcmc;
      case '教材名称':
        return jcmc;
      case '教材作者':
        return jczz;
      case '出版社':
        return cbs;
      case '版本号':
        return bbh;
      case '出版日期':
        return cbrq;
      case 'ISBN':
        return isbn;
      case '单价':
        return price;
      case '任课教师':
        return rkjsxx;
      case '课程性质':
        return kcxzmc;
      case '学年':
        return xnmmc;
      case '学期':
        return xqmmc;
      default:
        return '-';
    }
  }
}
