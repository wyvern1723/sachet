import 'dart:io';

/// 教务系统网址 （默认登录的网址，也是教务系统所有(?)功能的 baseURL）
const String jwxtBaseUrl = 'http://jwxt.xtu.edu.cn/jsxsd/';

/// 教务系统网址 (https)
const String jwxtBaseUrlHttps = 'https://jwxt.xtu.edu.cn/jsxsd/';

/// 信息门户网址
const String xinXiMenHuBaseUrl = 'https://portal2020.xtu.edu.cn/cas/login';

/// 教务系统主页（登录成功后跳转的网址）， **仅用于判断是否登录成功** 。直接访问会跳转到登录网址。
const String jwxtMainPageUrl =
    'http://jwxt.xtu.edu.cn/jsxsd/framework/xsMain.jsp';
const String jwxtMainPageUrlHttps =
    'https://jwxt.xtu.edu.cn/jsxsd/framework/xsMain.jsp';

/// 湘大校历网址
const String xtuSchoolCalendarUrl = 'https://www.xtu.edu.cn/xysh1/ggfw/xl.htm';

/// 校园网上网认证
const String campusNetworkAuthUrl = 'http://172.16.0.32:8080';

/// 校园网自助服务（踢出在线设设备……）
const String campusNetworkSelfServiceUrl = 'https://zz.xtu.edu.cn/selfservice';

/// 图书馆的馆藏检索网址
// TODO 平板大屏也改为桌面端网页
String libraryLookUpUrl =
    Platform.isWindows || Platform.isLinux || Platform.isMacOS
        ? 'https://findxtu.libsp.cn/#/home'
        : 'https://mfindxtu.libsp.cn/#/home';

/// 体测云网址（体测预约、选体育课）
const String ticeyunUrl = 'http://xtu.ticeyun.com:90/weixin';

/* 
2025年6月12日，学校将校园邮箱从腾讯企业邮箱迁移至网易企业邮箱。

- 原访问地址：

  - 学生： https://mail.smail.xtu.edu.cn
  - 教师： https://mail.xtu.edu.cn

  在 mail.xtu.edu.cn 不能选择以学生账号登录，需要访问 mail.smail.xtu.edu.cn 才能登录学生邮箱。

- 新访问地址：

  - https://mail.xtu.edu.cn

  在 mail.xtu.edu.cn 可以选择以学生/教师账号登录。
  虽然通知上只说明了 https://mail.xtu.edu.cn 这一访问地址，其实旧的 mail.smail.xtu.edu.cn 依旧可以使用。
  且访问 mail.smail.xtu.edu.cn 默认选择以学生账号登录，而访问 mail.xtu.edu.cn 默认选择以教师账号登录。
  所以还将继续使用 https://mail.smail.xtu.edu.cn/ 这个地址。

官方通知：
[关于湘潭大学邮箱迁移的通知-湘潭大学网络与信息中心](https://nic.xtu.edu.cn/info/1014/2134.htm)
[关于湘潭大学邮箱数据备份和平台切换的通知-湘潭大学](https://www.xtu.edu.cn/info/1373/22830.htm)
[新邮箱登录操作说明-湘潭大学网络与信息中心](https://nic.xtu.edu.cn/info/1023/1186.htm)
*/
/// 湘大学生邮箱网址
const String xtuMailUrl = 'https://mail.smail.xtu.edu.cn/';

/// 大物实验网址
const String collegePhysicsExperimentUrl = 'https://wlsy.xtu.edu.cn';

/// 湘大新闻网址
const String xtuNewsUrl = 'https://www.xtu.edu.cn';

/// 检查应用更新的 API（Github 自动生成的）
const String checkAppUpdateAPI =
    'https://api.github.com/repos/wyvern1723/sachet/releases/latest';

/// App Release Page 网址
const String appReleaseUrl = "https://github.com/wyvern1723/sachet/releases";

/// App 项目主页网址
const String appRepoUrl = "https://github.com/wyvern1723/sachet";

/// App 开发者个人资料网址
const String appDeveloperProfileUrl = "https://github.com/wyvern1723";
