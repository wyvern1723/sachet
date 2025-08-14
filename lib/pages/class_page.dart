import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sachet/models/nav_type.dart';
import 'package:sachet/utils/app_global.dart';
import 'package:sachet/providers/screen_nav_provider.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/providers/class_page_provider.dart';
import 'package:sachet/widgets/classpage_widgets/classpage_appbar.dart';
import 'package:sachet/widgets/utils_widgets/nav_drawer.dart';
import 'package:provider/provider.dart';

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassPageProvider(),
      child: PopScope(
        canPop: AppGlobal.startupPage == '/class',
        onPopInvokedWithResult: (bool didPop, Object? result) {
          if (didPop) {
            return;
          }
          if (SettingsProvider.navigationType ==
              NavType.navigationDrawer.type) {
            Navigator.of(context).pushReplacementNamed(AppGlobal.startupPage);
          }
          context.read<ScreenNavProvider>().setCurrentPageToStartupPage();
        },
        child: Scaffold(
          drawer:
              SettingsProvider.navigationType == NavType.navigationDrawer.type
                  ? myNavDrawer
                  : null,
          appBar: ClassPageAppBar(),
          body: Selector<SettingsProvider, (String, Map?)>(
              selector: (_, settingsProvider) => (
                    settingsProvider.classScheduleFilePath,
                    settingsProvider.courseColorData,
                  ),
              builder: (_, __, ___) {
                return FutureBuilder(
                    future: context.read<SettingsProvider>().generatePageList(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          if (kDebugMode) {
                            print(snapshot.error);
                          }
                          return Text('${snapshot.error}');
                        } else {
                          final pageListData = snapshot.data;
                          return ClassPageView(
                            pageList: pageListData ?? <Widget>[],
                          );
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    });
              }),
        ),
      ),
    );
  }
}

class ClassPageView extends StatefulWidget {
  const ClassPageView({
    super.key,
    required this.pageList,
  });
  final List<Widget> pageList;

  @override
  State<ClassPageView> createState() => _ClassPageViewState();
}

class _ClassPageViewState extends State<ClassPageView> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<ClassPageProvider>()
          .pageController
          .jumpToPage(context.read<ClassPageProvider>().currentWeekCount - 1);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: context.read<ClassPageProvider>().pageController,
      onPageChanged: (value) {
        context.read<ClassPageProvider>().updateCurrentWeekCount(value + 1);
      },
      allowImplicitScrolling: true,
      children: widget.pageList,
    );
  }
}
