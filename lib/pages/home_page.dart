import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/url_constants.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/pages/home_child_pages/exam_time_page_zf.dart';
import 'package:sachet/pages/home_child_pages/gpa_page_zf.dart';
import 'package:sachet/pages/home_child_pages/grade_page_zf.dart';
import 'package:sachet/pages/home_child_pages/score_pdf_page_zf.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/pages/home_child_pages/cultivate_page.dart';
import 'package:sachet/pages/home_child_pages/free_classroom_page_zf.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/utils_funtions.dart';
import 'package:sachet/widgets/homepage_widgets/card_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    OpenLinkListTile campusNetworkAuth = OpenLinkListTile(
      title: '校园网认证',
      subtitle: '打开校园网认证的网页',
      //  icon: Icons.travel_explore_outlined,
      //  Material Symbol 的 captive_portal 完美契合，但 Material Symbol 还不支持 Flutter
      // icon: Icons.signal_wifi_statusbar_connected_no_internet_4_outlined,
      icon: Icons.wifi,
      link: campusNetworkAuthUrl,
    );
    OpenLinkListTile campusNetworkSelfService = OpenLinkListTile(
      title: '校园网自助服务系统',
      subtitle: '踢出占线设备',
      // icon: Icons.wifi_protected_setup_outlined,
      icon: Icons.devices,
      link: campusNetworkSelfServiceUrl,
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
    OpenLinkListTile jwxt = OpenLinkListTile(
      title: '旧教务系统',
      subtitle: jwxtBaseUrlHttps,
      icon: Icons.work,
      link: jwxtBaseUrlHttps,
    );
    List<OpenLinkListTile> openLinkListTileList = [
      campusNetworkAuth,
      campusNetworkSelfService,
      xinXiMenHu,
      newJwxt,
      jwxt,
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shadowColor: primaryColor.withOpacity(0.4),
                  clipBehavior: Clip.hardEdge,
                  color: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FreeClassroomPageZF(),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '空闲教室',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '快速查询自习室',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            Icons.meeting_room_rounded,
                            size: 44,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: CardWidget(
                        title: '培养方案',
                        icon: Icons.school_rounded,
                        page: CultivatePage(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CardWidget(
                        title: '考试时间',
                        icon: Icons.schedule_rounded,
                        page: ExamTimePageZF(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: CardWidget(
                        title: '成绩查询',
                        // icon: Icons.emoji_events_outlined,
                        icon: Icons.history_edu_outlined,
                        // icon: Icons.analytics_rounded,
                        page: GradePageZF(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardWidget(
                        title: '绩点排名',
                        icon: Icons.leaderboard_rounded,
                        page: GPAPageZF(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CardWidget(
                        title: '成绩单',
                        // icon: Icons.picture_as_pdf,
                        icon: Icons.description_rounded,
                        page: ScorePdfPageZF(),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(4.0, 24.0, 4.0, 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '打开外部网站',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(children: [
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
                  ))
                ]),
                Row(children: [
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
                ]),
                Row(
                  children: [
                    Expanded(
                      child: CardLinkWidget(
                        title: '湘大校历',
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
                SizedBox(height: 6),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    children:
                        List.generate(openLinkListTileList.length, (index) {
                      return Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 4,
                            ),
                            leading: Align(
                              widthFactor: 1,
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                openLinkListTileList[index].icon,
                                color: primaryColor,
                              ),
                            ),
                            title: Text(
                              openLinkListTileList[index].title,
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              openLinkListTileList[index].subtitle,
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                            ),
                            trailing: Icon(
                              // Icons.chevron_right,
                              Icons.launch_outlined,
                              color: colorScheme.outline,
                            ),
                            onTap: () =>
                                openLink(openLinkListTileList[index].link),
                            onLongPress: () {
                              Clipboard.setData(ClipboardData(
                                  text: openLinkListTileList[index].link));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("链接已复制到剪贴板")),
                              );
                            },
                          ),
                          // 添加分割线，除了最后一个
                          if (index != openLinkListTileList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 60,
                              endIndent: 40,
                            ),
                        ],
                      );
                    }),
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
