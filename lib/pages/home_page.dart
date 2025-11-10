import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/jwxt_type.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/pages/home_child_pages/exam_time_page_zf.dart';
import 'package:sachet/pages/home_child_pages/grade_page_zf.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/pages/home_child_pages/cultivate_page.dart';
import 'package:sachet/pages/home_child_pages/exam_time_page_qz.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_page_zf.dart';
import 'package:sachet/pages/home_child_pages/grade_page_qz.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/homepage_widgets/card_widget.dart';
import 'package:sachet/widgets/homepage_widgets/select_jwxt_as_source_dialog.dart';
import 'package:sachet/widgets/settingspage_widgets/settings_section_title.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:sachet/widgets/homepage_widgets/card_link_widget.dart';
import 'package:provider/provider.dart';

class OpenLinkListTile {
  String title;
  String subtitle;
  IconData icon;
  String link;
  OpenLinkListTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.link,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future _openExamTimePage(BuildContext context) async {
    final jwxtType = await showDialog(
      context: context,
      builder: (BuildContext context) =>
          const SelectJwxtAsSourceDialog(title: "选择考试时间数据来源"),
    );

    if (!context.mounted) return;

    switch (jwxtType) {
      case JwxtType.qiangzhi:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamTimePageQZ(),
          ),
        );
        break;
      case JwxtType.zhengfang:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExamTimePageZF(),
          ),
        );
        break;
    }
  }

  Future _openGradePage(BuildContext context) async {
    final jwxtType = await showDialog(
      context: context,
      builder: (BuildContext context) =>
          const SelectJwxtAsSourceDialog(title: "选择成绩数据来源"),
    );

    if (!context.mounted) return;

    switch (jwxtType) {
      case JwxtType.qiangzhi:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradePageQZ(),
          ),
        );
        break;
      case JwxtType.zhengfang:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradePageZF(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    OpenLinkListTile campusNetworkAuth = OpenLinkListTile(
      title: '校园网认证',
      subtitle: '打开校园网认证的网页',
      //  icon: Icons.travel_explore_outlined,
      //  Material Symbol 的 captive_portal 完美契合，但 Material Symbol 还不支持 Flutter
      icon: Icons.signal_wifi_statusbar_connected_no_internet_4_outlined,
      link: campusNetworkAuthUrl,
    );
    OpenLinkListTile campusNetworkSelfService = OpenLinkListTile(
      title: '校园网自助服务系统',
      subtitle: '踢出占线设备',
      icon: Icons.wifi_protected_setup_outlined,
      link: campusNetworkSelfServiceUrl,
    );
    OpenLinkListTile jwxt = OpenLinkListTile(
      title: '教务系统',
      subtitle: jwxtBaseUrlHttps,
      icon: Icons.work,
      link: jwxtBaseUrlHttps,
    );
    OpenLinkListTile xinXiMenHu = OpenLinkListTile(
      title: '信息门户',
      subtitle: xinXiMenHuBaseUrl,
      // Icons.explore
      // icon: Icons.public,
      icon: Icons.domain_outlined,
      link: xinXiMenHuBaseUrl,
    );
    OpenLinkListTile newJwxt = OpenLinkListTile(
      title: '新教务系统',
      subtitle: newJwxtBaseUrl,
      icon: Icons.public,
      link: newJwxtBaseUrl,
    );
    List<OpenLinkListTile> openLinkListTileList = [
      campusNetworkAuth,
      campusNetworkSelfService,
      jwxt,
      xinXiMenHu,
      newJwxt,
    ];

    return PopScope(
      canPop: AppGlobal.startupPage == '/home',
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          return;
        }
        if (SettingsProvider.navigationType == NavType.navigationDrawer.type) {
          Navigator.of(context).pushReplacementNamed(AppGlobal.startupPage);
        }
        context.read<ScreenNavProvider>().setCurrentPageToStartupPage();
      },
      child: Scaffold(
        drawer: SettingsProvider.navigationType == NavType.navigationDrawer.type
            ? myNavDrawer
            : null,
        appBar: AppBar(
          title: const Text('Home'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardWidget(
                  title: '空闲教室',
                  icon: Icons.meeting_room_outlined,
                  page: FreeClassroomPageZF(),
                ),
                Row(
                  children: [
                    Expanded(
                      child: CardWidget(
                        title: '培养方案',
                        icon: Icons.assignment_outlined,
                        page: CultivatePage(),
                      ),
                    ),
                    Expanded(
                      child: CardWidget(
                        title: '考试时间',
                        icon: Icons.alarm,
                        onTap: () => _openExamTimePage(context),
                      ),
                    ),
                    Expanded(
                      child: CardWidget(
                        title: '成绩查询',
                        // icon: Icons.emoji_events_outlined,
                        icon: Icons.history_edu_outlined,
                        page: GradePageQZ(),
                        onTap: () => _openGradePage(context),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 20.0, 12.0, 4.0),
                  child: SettingsSectionTitle(title: '打开外部网站'),
                ),

                Row(
                  children: [
                    Expanded(
                      child: CardLinkWidget(
                        title: '大物实验',
                        icon: Icons.science,
                        link: collegePhysicsExperimentUrl,
                      ),
                    ),
                    Expanded(
                      child: CardLinkWidget(
                        title: '湘大邮箱',
                        icon: Icons.email,
                        // icon: Icons.email_outlined,
                        link: xtuMailUrl,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CardLinkWidget(
                        title: '馆藏检索',
                        icon: Icons.book,
                        link: libraryLookUpUrl,
                      ),
                    ),
                    Expanded(
                      child: CardLinkWidget(
                        title: '体测网站',
                        // icon: Icons.directions_run_outlined,
                        icon: Icons.fitness_center_outlined,
                        link: ticeyunUrl,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: CardLinkWidget(
                        title: '教学周历',
                        icon: Icons.date_range,
                        link: xtuSchoolCalendarUrl,
                      ),
                    ),
                    Expanded(
                      child: CardLinkWidget(
                        title: '湘大新闻',
                        icon: Icons.newspaper,
                        link: xtuNewsUrl,
                      ),
                    ),
                  ],
                ),
                // openLinkListTileList
                ...List.generate(
                  openLinkListTileList.length,
                  (index) => ListTile(
                    leading: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Icon(openLinkListTileList[index].icon),
                    ),
                    // iconColor: Theme.of(context).colorScheme.onSurface,
                    title: Text(openLinkListTileList[index].title),
                    subtitle: Text(openLinkListTileList[index].subtitle),
                    trailing: Icon(Icons.launch_outlined),
                    onTap: () => openLink(openLinkListTileList[index].link),
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(
                          text: openLinkListTileList[index].link));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("链接已复制到剪贴板")),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
