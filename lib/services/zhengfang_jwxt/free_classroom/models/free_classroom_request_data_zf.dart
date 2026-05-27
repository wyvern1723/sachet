class FreeClassroomRequestDataZF {
  /// 校区号
  /// ```html
  ///  <option value="02" selected="selected">校本部</option>
  ///  <option value="03">兴湘学院</option>
  ///  ```
  String xqhId;

  /// 学年名，如 "2025" => 指 2025-2026
  String xnm;

  /// 学期名，"3"=> 第1学期，"12"=>第二学期，"16"=>第三学期
  String xqm;

  /// 场地类别
  /// ```html
  ///  <option value="">全部</option>
  ///  <option value="242AD80DD82F326AE06364FD18AC1791">画室</option>
  ///  <option value="242AD80DD830326AE06364FD18AC1791">工作室</option>
  ///  <option value="242AD80DD831326AE06364FD18AC1791">雕塑室</option>
  ///  <option value="242AD80DD839326AE06364FD18AC1791">体育馆</option>
  ///  <option value="242AD80DD84A326AE06364FD18AC1791">实验室（工2）</option>
  ///  <option value="242A39144A5E320DE06364FD18AC0E46">实验室（工1）</option>
  ///  <option value="39B2DE0501CF86B3E063C94418AC0F6A">琴房</option>
  ///  <option value="242A39144A5D320DE06364FD18AC0E46">机房</option>
  ///  <option value="242BB3E52A3032E3E06364FD18AC182D">报告厅</option>
  ///  <option value="D3AE0862A9DC4958934863C3672200FC">实验室（文）</option>
  ///  <option value="01" selected="selected">教室</option>
  ///  <option value="09">实验室（理）</option>
  ///  <option value="263675C3C9F74057E06364FD18ACDEE3">运动场</option>
  ///  ```
  String cdlbId;

  /// 场地二级类别
  String cdejlbId;

  /// 最小座位数
  String qszws;

  /// 最大座位数
  String jszws;

  /// 场地名称
  ///
  /// 可按场地名称和编号搜索
  String cdmc;

  /// 楼号
  ///
  ///  ```html
  ///  <option value="">全部</option>
  ///  <option value="209">北山画室</option>
  ///  <option value="206">北山阶梯</option>
  ///  <option value="907">材料大楼</option>
  ///  <option value="902">测试中心</option>
  ///  <option value="109">第二教学楼</option>
  ///  <option value="101">第一教学楼</option>
  ///  <option value="909">东润楼</option>
  ///  <option value="901">锻压楼</option>
  ///  <option value="002">二教学楼</option>
  ///  <option value="204">法律楼</option>
  ///  <option value="601">法学楼</option>
  ///  <option value="903">高分子楼</option>
  ///  <option value="303">工程训练中心</option>
  ///  <option value="105">工科楼</option>
  ///  <option value="208">公为楼</option>
  ///  <option value="114">焊接楼</option>
  ///  <option value="920">化工原理楼</option>
  ///  <option value="904">化机楼</option>
  ///  <option value="113">化学化工实验楼</option>
  ///  <option value="905">环保楼</option>
  ///  <option value="906">机械楼</option>
  ///  <option value="108">计算中心</option>
  ///  <option value="112">建工楼</option>
  ///  <option value="908">经管楼</option>
  ///  <option value="401">联建教学楼</option>
  ///  <option value="103">南山阶梯</option>
  ///  <option value="919">琴湖</option>
  ///  <option value="203">尚美楼</option>
  ///  <option value="111">数学楼</option>
  ///  <option value="004">体育场</option>
  ///  <option value="102">体育馆</option>
  ///  <option value="104">图书馆</option>
  ///  <option value="115">土木楼</option>
  ///  <option value="207">外语楼</option>
  ///  <option value="201">文科楼</option>
  ///  <option value="117">校医院</option>
  ///  <option value="116">新计算中心</option>
  ///  <option value="110">信息楼</option>
  ///  <option value="304">兴教楼A栋</option>
  ///  <option value="302">兴教楼B栋</option>
  ///  <option value="305">兴教楼C栋</option>
  ///  <option value="301">兴湘旧教学楼</option>
  ///  <option value="205">行远楼</option>
  ///  <option value="107">学生活动中心</option>
  ///  <option value="910">研究生院</option>
  ///  <option value="001">一教学楼</option>
  ///  <option value="202">逸夫楼</option>
  ///  <option value="306">原子弟小学</option>
  ///  <option value="wlh">无楼号</option>
  ///  ```
  String lh;

  /// 借用时间方式(在查询页面是隐藏的)
  /// ```html
  /// <input type="radio" name="jyfs" id="arqjy_lx" value="1" checked="checked"/>arqjy_lx<!-- 连续 -->
  /// <input type="radio" name="jyfs" id="arqjy_jd" value="3"/>arqjy_jd<!-- 间断-->
  /// <input type="radio" name="jyfs" id="arqjy_jc" value="2"/>arqjy_jc<!--节次-->
  /// ```
  String jyfs;

  /// 场地借用类型，不知道做什么的
  String cdjylx;

  String sfbhkc;

  /// 周次
  String zcd;

  /// 星期几
  String xqj;

  /// 节次
  String jcd;
  String sSearch;
  String nd;

  /// 每页最大显示数量
  String queryModelShowCount;

  /// 当前页
  String queryModelCurrentPage;

  /// 排序依据:
  ///
  /// "cdbh+"=>场地编号
  ///
  /// "cdmc+"=>场地名称
  ///
  /// "xqmc+"=>校区
  ///
  /// "cdlb_id+"=>场地类别
  ///
  /// "zws+"=>座位数
  ///
  /// "kszws1+"=>考试座位数
  ///
  /// "jxlmc+"=>楼号
  ///
  /// "cdejlbmc+"=>场地二级类别
  ///
  /// ......
  String queryModelSortName;

  /// 排序方式: "asc"=>正序，"desc"=>倒序
  String queryModelSortOrder;

  /// 查询次数，第一次是 "0"，第二次查询是 "1"……
  String time;

  FreeClassroomRequestDataZF({
    required this.xqhId,
    required this.xnm,
    required this.xqm,
    required this.cdlbId,
    this.cdejlbId = "",
    required this.qszws,
    required this.jszws,
    this.cdmc = "",
    required this.lh,
    this.jyfs = "",
    this.cdjylx = "",
    this.sfbhkc = "",
    required this.zcd,
    required this.xqj,
    required this.jcd,
    this.sSearch = "false",
    required this.nd,
    this.queryModelShowCount = "9999",
    this.queryModelCurrentPage = "1",
    this.queryModelSortName = "cdmc+",
    this.queryModelSortOrder = "asc",
    this.time = "0",
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['xqh_id'] = xqhId;
    data['xnm'] = xnm;
    data['xqm'] = xqm;
    data['cdlb_id'] = cdlbId;
    data['cdejlb_id'] = cdejlbId;
    data['qszws'] = qszws;
    data['jszws'] = jszws;
    data['cdmc'] = cdmc;
    data['lh'] = lh;
    data['jyfs'] = jyfs;
    data['cdjylx'] = cdjylx;
    data['sfbhkc'] = sfbhkc;
    data['zcd'] = zcd;
    data['xqj'] = xqj;
    data['jcd'] = jcd;
    data['_search'] = sSearch;
    data['nd'] = nd;
    data['queryModel.showCount'] = queryModelShowCount;
    data['queryModel.currentPage'] = queryModelCurrentPage;
    data['queryModel.sortName'] = queryModelSortName;
    data['queryModel.sortOrder'] = queryModelSortOrder;
    data['time'] = time;
    return data;
  }
}
