import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sachet/constants/app_constants.dart';
import 'package:sachet/pages/profile_page.dart';
import 'package:sachet/pages/with_navbar_view.dart';
import 'package:sachet/provider/app_global.dart';
import 'package:sachet/provider/course_card_settings_provider.dart';
import 'package:sachet/provider/screen_nav_provider.dart';
import 'package:sachet/provider/settings_provider.dart';
import 'package:sachet/provider/theme_provider.dart';
import 'package:sachet/provider/user_provider.dart';
import 'package:sachet/pages/class_page.dart';
import 'package:sachet/pages/home_page.dart';
import 'package:sachet/pages/settings_page.dart';
import 'package:sachet/pages/utilspages/login_page.dart';
import 'package:sachet/pages/about_page.dart';
import 'package:sachet/utils/auto_check_update.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarContrastEnforced: false,
  ));

  AppGlobal.init().then((e) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CourseCardSettingsProvider()),
        ChangeNotifierProvider(create: (_) => ScreenNavProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // 是否使用动态取色
          if (themeProvider.isUsingDynamicColors) {
            return DynamicColorBuilder(
              builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
                // **********从 dynamic_color-1.7.0/example/lib/complete_example.dart 复制的代码**********
                ColorScheme lightColorScheme;
                ColorScheme darkColorScheme;

                if (lightDynamic != null && darkDynamic != null) {
                  // On Android S+ devices, use the provided dynamic color scheme.
                  // (Recommended) Harmonize the dynamic color scheme' built-in semantic colors.
                  lightColorScheme = lightDynamic.harmonized();

                  // Repeat for the dark color scheme.
                  darkColorScheme = darkDynamic.harmonized();
                } else {
                  // Otherwise, use fallback schemes.
                  lightColorScheme = ColorScheme.fromSeed(
                    seedColor: appBrandColor,
                    brightness: Brightness.light,
                  );
                  darkColorScheme = ColorScheme.fromSeed(
                    seedColor: appBrandColor,
                    brightness: Brightness.dark,
                  );
                }
                // **********从 dynamic_color-1.7.0/example/lib/complete_example.dart 复制的代码**********

                return MaterialApp(
                  title: 'Sachet',
                  scaffoldMessengerKey: SnackbarGlobal.key,
                  navigatorKey: NavigatorGlobal.navigatorKey,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: const [
                    Locale('zh', 'CN'), // 中文
                  ],
                  debugShowCheckedModeBanner: false,
                  themeMode: ThemeMode.values[themeProvider.themeMode],
                  theme: ThemeData(
                    colorScheme: lightColorScheme,
                    useMaterial3: themeProvider.isMD3 ? true : false,
                    pageTransitionsTheme: const PageTransitionsTheme(
                      builders: <TargetPlatform, PageTransitionsBuilder>{
                        // Set the predictive back transitions for Android.
                        TargetPlatform.android:
                            PredictiveBackPageTransitionsBuilder(),
                      },
                    ),
                  ),
                  darkTheme: ThemeData(
                    colorScheme: darkColorScheme,
                    useMaterial3: themeProvider.isMD3 ? true : false,
                    pageTransitionsTheme: const PageTransitionsTheme(
                      builders: <TargetPlatform, PageTransitionsBuilder>{
                        // Set the predictive back transitions for Android.
                        TargetPlatform.android:
                            PredictiveBackPageTransitionsBuilder(),
                      },
                    ),
                  ),
                  initialRoute: SettingsProvider.navigationType ==
                          NavType.navigationDrawer.type
                      ? AppGlobal.appSettings.startupPage ?? '/class'
                      : '/navBarView',
                  routes: {
                    '/class': (context) => ClassPage(),
                    '/home': (context) => HomePage(),
                    '/settings': (context) => SettingsPage(),
                    '/about': (context) => AboutPage(),
                    '/login': (context) => LoginPage(),
                    '/profile': (context) => ProfilePage(),
                    '/navBarView': (context) => WithNavigationBarView(),
                  },
                );
              },
            );
          } else {
            return MaterialApp(
              title: 'Sachet',
              scaffoldMessengerKey: SnackbarGlobal.key,
              navigatorKey: NavigatorGlobal.navigatorKey,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('zh', 'CN'), // 中文
              ],
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.values[themeProvider.themeMode],
              theme: ThemeData(
                colorSchemeSeed: themeProvider.themeColor,
                brightness: Brightness.light,
                useMaterial3: themeProvider.isMD3 ? true : false,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    // Set the predictive back transitions for Android.
                    TargetPlatform.android:
                        PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              darkTheme: ThemeData(
                colorSchemeSeed: themeProvider.themeColor,
                brightness: Brightness.dark,
                useMaterial3: themeProvider.isMD3 ? true : false,
                pageTransitionsTheme: const PageTransitionsTheme(
                  builders: <TargetPlatform, PageTransitionsBuilder>{
                    // Set the predictive back transitions for Android.
                    TargetPlatform.android:
                        PredictiveBackPageTransitionsBuilder(),
                  },
                ),
              ),
              initialRoute: SettingsProvider.navigationType ==
                      NavType.navigationDrawer.type
                  ? AppGlobal.appSettings.startupPage ?? '/class'
                  : '/navBarView',
              routes: {
                '/class': (context) => ClassPage(),
                '/home': (context) => HomePage(),
                '/settings': (context) => SettingsPage(),
                '/about': (context) => AboutPage(),
                '/login': (context) => LoginPage(),
                '/profile': (context) => ProfilePage(),
                '/navBarView': (context) => WithNavigationBarView(),
              },
            );
          }
        },
      ),
    );
  }
}
