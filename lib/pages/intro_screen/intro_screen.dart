import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sachet/pages/intro_screen/intro_nav_type_screen.dart';
import 'package:sachet/pages/intro_screen/intro_theme_screen.dart';
import 'package:sachet/pages/intro_screen/intro_complete_screen.dart';
import 'package:sachet/pages/intro_screen/intro_welcome_screen.dart';
import 'package:sachet/providers/settings_provider.dart';
import 'package:sachet/utils/custom_route.dart';

class IntroScreen extends StatefulWidget {
  /// 引导页/介绍页
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  late PageController _pageController;
  int _currentPageIndex = 0;
  static const int _totalPages = 3;

  // 下一页
  void _goToNextPage() {
    if (_currentPageIndex == 0) {
      // 第一页，声明页：阅读后进入下一页
      context.read<SettingsProvider>().setHasReadDisclaimer();
      _pageController.nextPage(
        duration: Durations.long3,
        curve: Curves.ease,
      );
    } else if (_currentPageIndex < _totalPages - 1) {
      _pageController.nextPage(
        duration: Durations.long3,
        curve: Curves.ease,
      );
    } else {
      // 最后一页：点击后进入「设置完成！询问是否要登录」
      Navigator.of(context).pushReplacement(
        slideTransitionPageRoute(IntroCompleteScreen()),
      );
    }
  }

  // 上一页
  void _goToPreviousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: Durations.long3,
        curve: Curves.ease,
      );
    }
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _currentPageIndex == 0
            ? BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.centerRight,
                  colors: Theme.of(context).brightness == Brightness.light
                      ? [
                          Color(0xFFA5D6A7).withAlpha(180),
                          Color(0xFFA5D6A7).withAlpha(160),
                          Color(0xFFA5D6A7).withAlpha(140),
                        ]
                      : [
                          Color(0xff445844).withAlpha(120),
                          Color(0xff445844).withAlpha(100),
                          Color(0xff445844).withAlpha(80),
                        ],
                ),
              )
            : BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: _currentPageIndex == 0
                    ? NeverScrollableScrollPhysics()
                    : null,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                children: [
                  IntroWelcomeScreen(),
                  IntroThemeScreen(),
                  IntroNavTypeScreen(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentPageIndex != 0)
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed:
                            _currentPageIndex == 0 ? null : _goToPreviousPage,
                        child: const Text('上一步'),
                      ),
                    ),
                  SizedBox(width: 12),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _goToNextPage,
                      child: Text(
                        _currentPageIndex == 0
                            ? '我知道了'
                            : _currentPageIndex == _totalPages - 1
                                ? '完成'
                                : '下一步',
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
