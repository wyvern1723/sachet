import 'package:sachet/utils/json_safe_parse.dart';

class CurriculumResponseZF {
  String? sqztmc;
  String? kkztmc;
  String? rykcbj;
  String? zcbj;

  /// 考试形式: "统一", "随堂"
  String? ksxsdm;

  /// 课程号
  String? kch;

  String? jcbjmc;
  String? zyhId;
  String? kcxzdm;

  /// 开课部门: "数学与计算科学学院", "机械工程与力学学院", "外国语学院", "化学学院"
  String? kkbmmc;

  /// 周学时: "理论学时(2.0)", "理论学时(2.0)-实验学时(2.0)", "实验学时(2.0)", "实践学时(4.0周)", 理论学时(2.0)-实践学时(2.0)-线上学时(2.0)
  String? xsxxxx;

  /// 所属专业
  String? zymc;
  int? sfls;

  /// 所属大类
  String? dlmc;

  /// 课程性质
  String? kcxzmc;
  String? lszt;
  String? fxzxs;
  String? sfqptkc;
  int? haskcdgfj;
  int? sfyszdxqks;
  String? sflsmc;

  /// 主修标记: "是"
  String? zxbj;
  String? xdlxm;
  String? xdlx;
  String? shjgmc;

  /// 建议修读学年: "2023-2024", "2024-2025", "2025-2026"
  String? jyxdxnm;

  /// 是否实践课: "是", "否"
  String? sfsjk;
  String? sfmbyy;
  String? kkbmId;
  String? jxzxjhxxId;
  String? xsdmZh01;
  String? sfgssxbk;
  int? totalresult;

  /// 是否学位课程
  String? zyzgkcbj;

  /// 二专业标记: "否"
  String? ezybj;

  /// 考试方式: "笔试", "面试", "大作业", "机考"
  String? ksfsdm;
  String? jxzxjhkcxxId;
  String? sfmbjc;

  /// 考核方式: "考试", "考查"
  String? khfsdm;

  /// 校区: 校本部
  String? xqmc;
  String? shzt;
  int? rowId;

  /// 实践学时总学时
  int? xsdm02;

  /// 理论学时总学时
  int? xsdm01;

  /// 起始结束周: "2-18周", "2-17周"
  String? qsjsz;
  int? sfyx;
  String? sfkcszsfk;
  String? lsztmc;
  String? kchId;
  int? tcxs;

  /// 建议修读学期: "1", "2"
  String? jyxdxqm;

  /// 辅修标记: "否"
  String? fxbj;

  /// 二学位标记: "否"
  String? exwbj;

  /// 专业方向: "无方向"
  String? zyfxmc;
  String? zrbj;

  /// 线上学时总学时
  String? xsdm05;

  /// 上机学时总学时
  String? xsdm06;

  /// 听力学时总学时
  String? xsdm07;

  /// 实验学时总学时
  String? xsdm08;

  /// 允许修读学年学期: "2023-2024/1", "2023-2024/2", "2024-2025/1"
  String? yyxdxnxqmc;
  String? sfybzy;

  /// 专业核心课程标记: "否"
  String? zyhxkcbj;

  /// 课程英文名称: "Advanced Mathematics Ⅰ1", "College Foreign Languages 1", "Military training", "Probability theory and mathematical statistics I", "Linear Algebra II"
  String? kcywmc;
  String? zyfxId;

  /// 课程类别: "理论课（不含实践）", "理论课（含实践）", "集中性实践环节", "实验课",
  String? kclbmc;

  /// 课程名称
  String? kcmc;

  /// 教学大纲
  String? zwjxdg;

  /// 学分: "6", "4", "1", "0", "2.5"
  String? xf;

  /// 总学时
  int? zxs;
  String? ggjckcbj;

  /// 修读要求节点: "公共基础课B类", "学科基础课", "公共基础课", "集中实践环节", "专业主干课", "专业选修课"
  String? xfyqjdmc;
  String? jyk;

  /// 专业开放课程标记
  String? zykfkcbj;

  /// 备注
  String? bz;

  CurriculumResponseZF({
    this.sqztmc,
    this.kkztmc,
    this.rykcbj,
    this.zcbj,
    this.ksxsdm,
    this.kch,
    this.jcbjmc,
    this.zyhId,
    this.kcxzdm,
    this.kkbmmc,
    this.xsxxxx,
    this.zymc,
    this.sfls,
    this.dlmc,
    this.kcxzmc,
    this.lszt,
    this.fxzxs,
    this.sfqptkc,
    this.haskcdgfj,
    this.sfyszdxqks,
    this.sflsmc,
    this.zxbj,
    this.xdlxm,
    this.xdlx,
    this.shjgmc,
    this.jyxdxnm,
    this.sfsjk,
    this.sfmbyy,
    this.kkbmId,
    this.jxzxjhxxId,
    this.xsdmZh01,
    this.sfgssxbk,
    this.totalresult,
    this.zyzgkcbj,
    this.ezybj,
    this.ksfsdm,
    this.jxzxjhkcxxId,
    this.sfmbjc,
    this.khfsdm,
    this.xqmc,
    this.shzt,
    this.rowId,
    this.xsdm02,
    this.xsdm01,
    this.qsjsz,
    this.sfyx,
    this.sfkcszsfk,
    this.lsztmc,
    this.kchId,
    this.tcxs,
    this.jyxdxqm,
    this.fxbj,
    this.exwbj,
    this.zyfxmc,
    this.zrbj,
    this.xsdm05,
    this.xsdm06,
    this.xsdm07,
    this.xsdm08,
    this.yyxdxnxqmc,
    this.sfybzy,
    this.zyhxkcbj,
    this.kcywmc,
    this.zyfxId,
    this.kclbmc,
    this.kcmc,
    this.zwjxdg,
    this.xf,
    this.zxs,
    this.ggjckcbj,
    this.xfyqjdmc,
    this.jyk,
    this.zykfkcbj,
    this.bz,
  });

  CurriculumResponseZF.fromJson(Map<String, dynamic> json) {
    sqztmc = json.safeString('sqztmc');
    kkztmc = json.safeString('kkztmc');
    rykcbj = json.safeString('rykcbj');
    zcbj = json.safeString('zcbj');
    ksxsdm = json.safeString('ksxsdm');
    kch = json.safeString('kch');
    jcbjmc = json.safeString('jcbjmc');
    zyhId = json.safeString('zyh_id');
    kcxzdm = json.safeString('kcxzdm');
    kkbmmc = json.safeString('kkbmmc');
    xsxxxx = json.safeString('xsxxxx');
    zymc = json.safeString('zymc');
    sfls = json.safeInt('sfls');
    dlmc = json.safeString('dlmc');
    kcxzmc = json.safeString('kcxzmc');
    lszt = json.safeString('lszt');
    fxzxs = json.safeString('fxzxs');
    sfqptkc = json.safeString('sfqptkc');
    haskcdgfj = json.safeInt('haskcdgfj');
    sfyszdxqks = json.safeInt('sfyszdxqks');
    sflsmc = json.safeString('sflsmc');
    zxbj = json.safeString('zxbj');
    xdlxm = json.safeString('xdlxm');
    xdlx = json.safeString('xdlx');
    shjgmc = json.safeString('shjgmc');
    jyxdxnm = json.safeString('jyxdxnm');
    sfsjk = json.safeString('sfsjk');
    sfmbyy = json.safeString('sfmbyy');
    kkbmId = json.safeString('kkbm_id');
    jxzxjhxxId = json.safeString('jxzxjhxx_id');
    xsdmZh01 = json.safeString('xsdm_zh_01');
    sfgssxbk = json.safeString('sfgssxbk');
    totalresult = json.safeInt('totalresult');
    zyzgkcbj = json.safeString('zyzgkcbj');
    ezybj = json.safeString('ezybj');
    ksfsdm = json.safeString('ksfsdm');
    jxzxjhkcxxId = json.safeString('jxzxjhkcxx_id');
    sfmbjc = json.safeString('sfmbjc');
    khfsdm = json.safeString('khfsdm');
    xqmc = json.safeString('xqmc');
    shzt = json.safeString('shzt');
    rowId = json.safeInt('row_id');
    xsdm02 = json.safeInt('xsdm_02');
    xsdm01 = json.safeInt('xsdm_01');
    qsjsz = json.safeString('qsjsz');
    sfyx = json.safeInt('sfyx');
    sfkcszsfk = json.safeString('sfkcszsfk');
    lsztmc = json.safeString('lsztmc');
    kchId = json.safeString('kch_id');
    tcxs = json.safeInt('tcxs');
    jyxdxqm = json.safeString('jyxdxqm');
    fxbj = json.safeString('fxbj');
    exwbj = json.safeString('exwbj');
    zyfxmc = json.safeString('zyfxmc');
    zrbj = json.safeString('zrbj');
    xsdm05 = json.safeString('xsdm_05');
    xsdm06 = json.safeString('xsdm_06');
    xsdm07 = json.safeString('xsdm_07');
    xsdm08 = json.safeString('xsdm_08');
    yyxdxnxqmc = json.safeString('yyxdxnxqmc');
    sfybzy = json.safeString('sfybzy');
    zyhxkcbj = json.safeString('zyhxkcbj');
    kcywmc = json.safeString('kcywmc');
    zyfxId = json.safeString('zyfx_id');
    kclbmc = json.safeString('kclbmc');
    kcmc = json.safeString('kcmc');
    zwjxdg = json.safeString('zwjxdg');
    xf = json.safeString('xf');
    zxs = json.safeInt('zxs');
    ggjckcbj = json.safeString('ggjckcbj');
    xfyqjdmc = json.safeString('xfyqjdmc');
    jyk = json.safeString('jyk');
    zykfkcbj = json.safeString('zykfkcbj');
    bz = json.safeString('bz');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sqztmc'] = sqztmc;
    data['kkztmc'] = kkztmc;
    data['rykcbj'] = rykcbj;
    data['zcbj'] = zcbj;
    data['ksxsdm'] = ksxsdm;
    data['kch'] = kch;
    data['jcbjmc'] = jcbjmc;
    data['zyh_id'] = zyhId;
    data['kcxzdm'] = kcxzdm;
    data['kkbmmc'] = kkbmmc;
    data['xsxxxx'] = xsxxxx;
    data['zymc'] = zymc;
    data['sfls'] = sfls;
    data['dlmc'] = dlmc;
    data['kcxzmc'] = kcxzmc;
    data['lszt'] = lszt;
    data['fxzxs'] = fxzxs;
    data['sfqptkc'] = sfqptkc;
    data['haskcdgfj'] = haskcdgfj;
    data['sfyszdxqks'] = sfyszdxqks;
    data['sflsmc'] = sflsmc;
    data['zxbj'] = zxbj;
    data['xdlxm'] = xdlxm;
    data['xdlx'] = xdlx;
    data['shjgmc'] = shjgmc;
    data['jyxdxnm'] = jyxdxnm;
    data['sfsjk'] = sfsjk;
    data['sfmbyy'] = sfmbyy;
    data['kkbm_id'] = kkbmId;
    data['jxzxjhxx_id'] = jxzxjhxxId;
    data['xsdm_zh_01'] = xsdmZh01;
    data['sfgssxbk'] = sfgssxbk;
    data['totalresult'] = totalresult;
    data['zyzgkcbj'] = zyzgkcbj;
    data['ezybj'] = ezybj;
    data['ksfsdm'] = ksfsdm;
    data['jxzxjhkcxx_id'] = jxzxjhkcxxId;
    data['sfmbjc'] = sfmbjc;
    data['khfsdm'] = khfsdm;
    data['xqmc'] = xqmc;
    data['shzt'] = shzt;
    data['row_id'] = rowId;
    data['xsdm_02'] = xsdm02;
    data['xsdm_01'] = xsdm01;
    data['qsjsz'] = qsjsz;
    data['sfyx'] = sfyx;
    data['sfkcszsfk'] = sfkcszsfk;
    data['lsztmc'] = lsztmc;
    data['kch_id'] = kchId;
    data['tcxs'] = tcxs;
    data['jyxdxqm'] = jyxdxqm;
    data['fxbj'] = fxbj;
    data['exwbj'] = exwbj;
    data['zyfxmc'] = zyfxmc;
    data['zrbj'] = zrbj;
    data['xsdm_05'] = xsdm05;
    data['xsdm_06'] = xsdm06;
    data['xsdm_07'] = xsdm07;
    data['xsdm_08'] = xsdm08;
    data['yyxdxnxqmc'] = yyxdxnxqmc;
    data['sfybzy'] = sfybzy;
    data['zyhxkcbj'] = zyhxkcbj;
    data['kcywmc'] = kcywmc;
    data['zyfx_id'] = zyfxId;
    data['kclbmc'] = kclbmc;
    data['kcmc'] = kcmc;
    data['zwjxdg'] = zwjxdg;
    data['xf'] = xf;
    data['zxs'] = zxs;
    data['ggjckcbj'] = ggjckcbj;
    data['xfyqjdmc'] = xfyqjdmc;
    data['jyk'] = jyk;
    data['zykfkcbj'] = zykfkcbj;
    data['bz'] = bz;
    return data;
  }

  item(String item) {
    return switch (item) {
      '学年' => jyxdxnm,
      '学期' => jyxdxqm,
      '学年学期' => yyxdxnxqmc,
      '课程名称' => kcmc,
      '课程英文名称' => kcywmc,
      '学分' => xf,
      '总学时' => zxs,
      '课程性质' => kcxzmc,
      '课程类别' => kclbmc,
      '考核方式' => khfsdm,
      '修读要求节点' => xfyqjdmc,
      '开课部门' => kkbmmc,
      _ => '',
    };
  }
}
