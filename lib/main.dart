import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            initialRoute: AppGlobal.appSettings.startupPage ?? '/class',
            routes: {
              '/class': (context) => ClassPage(),
              '/home': (context) => HomePage(),
              '/settings': (context) => SettingsPage(),
              '/about': (context) => AboutPage(),
              '/login': (context) => LoginPage(),
            },
          );
        },
      ),
    );
  }
}
