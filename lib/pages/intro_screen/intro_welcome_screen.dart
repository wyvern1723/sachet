import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/utils/utils_funtions.dart';

class IntroWelcomeScreen extends StatefulWidget {
  /// 欢迎页/声明页
  const IntroWelcomeScreen({super.key});

  @override
  State<IntroWelcomeScreen> createState() => _IntroWelcomeScreenState();
}

class _IntroWelcomeScreenState extends State<IntroWelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16.0,
            AppBar().preferredSize.height +
                MediaQuery.of(context).viewPadding.top,
            16.0,
            0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(6),
              child: FittedBox(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icon/icon-fg.png',
                      width: 80,
                      height: 80,
                      fit: BoxFit.fill,
                      cacheWidth: (80 * MediaQuery.of(context).devicePixelRatio)
                          .round(),
                      cacheHeight:
                          (80 * MediaQuery.of(context).devicePixelRatio)
                              .round(),
                    ),
                    Text(
                      '你好👋\n'
                      '欢迎使用 Sachet🍃',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 40),
            MarkdownBody(
              data: '# 声明\n$disclaimer',
              onTapLink: (text, href, title) {
                if (href != null) {
                  openLink(href);
                }
              },
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
