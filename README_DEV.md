# README_DEV.md

## 开发环境

- Flutter 3.24.5
- JDK 17
- Adroid SDK 35

## 运行该软件

### 配置 Flutter 开发环境

根据 [flutter.dev 官网上的指导](https://docs.flutter.dev/get-started/install) 配置 Flutter 开发环境，并成功运行示例的 Counter App。

若要编译 Android 版本，请确保 `flutter doctor` 的输出中 Flutter、Android toolchain、Android Studio 配置正确（为绿色的 `✓` ）

> [!NOTE]
> 本项目使用的 Flutter 版本为 3.24.5, ~~可能~~不兼容最新版本的 Flutter SDK。
>
> 可能的解决方法：
>
> - 使用 [FVM](https://fvm.app) 管理 Flutter 版本。（配置可能较复杂，但 fvm 是长期开发 flutter 软件中非常实用的工具）
> - 将 Flutter 降级至项目使用的版本。

构建此项目时的 `flutter doctor -v` 输出：

```bash
$ flutter doctor -v

[✓] Flutter (Channel stable, 3.24.5, on Debian GNU/Linux 12 (bookworm) 6.1.0-32-amd64, locale en_US.UTF-8)
    • Flutter version 3.24.5 on channel stable at /home/mydebian/fvm/versions/3.24.5
    • Upstream repository https://github.com/flutter/flutter.git
    • Framework revision dec2ee5c1f (6 months ago), 2024-11-13 11:13:06 -0800
    • Engine revision a18df97ca5
    • Dart version 3.5.4
    • DevTools version 2.37.3

[✓] Android toolchain - develop for Android devices (Android SDK version 35.0.1)
    • Android SDK at /home/mydebian/Android/Sdk
    • Platform android-35, build-tools 35.0.1
    • Java binary at: /usr/lib/jvm/java-17-openjdk-amd64/bin/java
    • Java version OpenJDK Runtime Environment (build 17.0.14+7-Debian-1deb12u1)
    • All Android licenses accepted.

[✗] Chrome - develop for the web (Cannot find Chrome executable at google-chrome)
    ! Cannot find Chrome. Try setting CHROME_EXECUTABLE to a Chrome executable.

[✓] Linux toolchain - develop for Linux desktop
    • Debian clang version 14.0.6
    • cmake version 3.25.1
    • ninja version 1.11.1
    • pkg-config version 1.8.1
    
[✓] Android Studio (version 2024.3)
    • Android Studio at /home/mydebian/Dev/android-studio
    • Flutter plugin version 85.2.3
    • Dart plugin can be installed from:
    🔨 https://plugins.jetbrains.com/plugin/6351-dart
    • Java version OpenJDK Runtime Environment (build 21.0.5+-12932927-b750.29)

[✓] Connected device (2 available)
    • sdk gphone64 x86 64 (mobile) • emulator-5554 • android-x64 • Android 15 (API 35) (emulator)
    • Linux (desktop)              • linux         • linux-x64   • Debian GNU/Linux 12 (bookworm) 6.1.0-32-amd64

[✓] Network resources
    • All expected network resources are available.
```

### Build Android APK on Windows

克隆项目：

`git clone https://github.com/wyvern1723/sachet.git`

进入项目文件夹：

`cd sachet`

下载使用的 packages：

`flutter pub get`

编译 apk：

`flutter build apk --release --target-platform android-arm64 --dart-define="abi=arm64-v8a"`

### Build Android APK on Linux

克隆项目：

`git clone https://github.com/wyvern1723/sachet.git`

进入项目文件夹：

`cd sachet`

下载使用的 packages：

`flutter pub get`

编译 apk：

`flutter build apk --release --target-platform android-arm64 --dart-define="abi=arm64-v8a"`

## TreeView 文件树

```bash
lib
├── constants # 一些 constants
│   ├── app_constants.dart
│   └── url_constants.dart # 链接 constants
├── main.dart
├── model
│   ├── course_model.dart
│   ├── get_web_data # 获取网络数据
│   │   ├── check_update.dart # 检查更新
│   │   ├── fetch_data_from_jwxt # 获取返回的网页信息
│   │   │   ├── dio_get_post_jwxt.dart # 封装的 Dio
│   │   │   ├── fetch_class_schedule.dart
│   │   │   ├── fetch_class_schedule_semesters.dart
│   │   │   ├── fetch_cultivate_plan.dart
│   │   │   ├── fetch_exam_scores.dar
│   │   │   ├── fetch_exam_time.dart
│   │   │   ├── fetch_exam_time_semesters.dart
│   │   │   └── fetch_free_class.dart
│   │   ├── get_cacheable_data # 获取会缓存的数据
│   │   │   ├── get_cultivate_plan.dart # 获取培养方案
│   │   │   └── get_exam_time.dart # 获取考试时间
│   │   └── process_data # 对获取的网页数据进行处理
│   │       ├── generate_course_color.dart # 生成课程配色
│   │       ├── generate_cultivate_plan_data.dart # 生成培养方案数据
│   │       ├── generate_exam_time_data.dart # 生成考试时间数据
│   │       ├── get_class_schedule.dart # 获取课程表数据
│   │       ├── get_class_shedule_semesters.dart # 获取课程表的当前学期和可选学期
│   │       ├── get_exam_scores.dart # 获取考试成绩
│   │       ├── get_exam_time_semesters.dart # 获取考试时间的当前学期和可选学期
│   │       └── get_free_class.dart # 获取空闲教室
│   ├── login.dart # 登录
│   └── time_manager.dart # 时间管理
├── pages # 应用页面
│   ├── about_page.dart 
│   ├── class_child_pages
│   │   └── course_settings_page.dart
│   ├── class_page.dart
│   ├── class_single_page.dart
│   ├── home_child_pages
│   │   ├── cultivate_page.dart
│   │   ├── exam_time_page.dart
│   │   ├── free_class_page.dart
│   │   └── grade_page.dart
│   ├── home_page.dart # 主页
│   ├── settings_child_pages # 设置页面的子页面们
│   │   ├── advanced_settings_page.dart # 高级设置页面
│   │   ├── cached_data_listview_page.dart # 缓存数据查看页面
│   │   ├── class_schedule_data_listview_page.dart # 课程表数据查看页面
│   │   ├── color_settings_page.dart # 配色设置页面
│   │   ├── course_color_data_listview_page.dart # 配色数据查看页面
│   │   ├── customize_settings_page.dart # 自定义设置页面
│   │   ├── dev_settings_page.dartt # 开发者设置页面
│   │   ├── other_data_listview_page.dart
│   │   ├── palette_adjust_page.dart
│   │   ├── palette_settings_page.dart # 配色管理页面
│   │   ├── theme_settings_page.dart # 主题设置页面
│   │   └── view_data_page.dart # 缓存数据查看后点击查看数据的页面
│   ├── settings_page.dart # 设置页面
│   └── utilspages
│       ├── login_page.dart # 登录页面
│       └── manual_login_page.dart # 手动登录页面
├── provider
│   ├── app_global.dart
│   ├── class_page_provider.dart
│   ├── course_card_settings_provider.dart
│   ├── free_class_page_provider.dart
│   ├── grade_page_provider.dart
│   ├── screen_nav_provider.dart
│   ├── settings_provider.dart
│   ├── theme_provider.dart
│   └── user_provider.dart
├── utils
│   ├── auto_check_update.dart # 自动检查更新的 service
│   ├── custom_route.dart
│   ├── services
│   │   ├── local_storage_service.dart
│   │   └── path_provider_service.dart
│   ├── transform.dart # 对数据的变形和变换
│   └── utils_funtions.dart
└── widgets # widgets
    ├── classpage_widgets # 课程表页面用到的 widgets
    │   ├── class_session.dart
    │   ├── class_session_routine_column.dart
    │   ├── course_card.dart # 课程卡片
    │   ├── course_card_item.dart # 课程卡片里的每一项（文字）
    │   ├── day_of_the_week_topbar.dart # 课程表页面最上面的显示一周的星期/日期
    │   ├── rename_app_file_dialog.dartt # 重命名文件的对话框
    │   ├── switch_actived_app_file_dialog.dart # 切换正在使用（激活）的文件（课程表文件、配色文件……）
    │   ├── update_class_schedule_dialog.dart # 更新课程表 Dialog
    │   └── week_count_dropdown_menu.dart # Appbar 上显示周次(第x周点击后出现的可以快速选择周次)
    ├── homepage_widgets # Home 页面用到的 widgets
    │   ├── card_link_widget.dart # 点击打开网页链接的 Card
    │   ├── card_widget.dart # 点击打开应用功能的 Card
    │   ├── exam_page_widgets
    │   │   ├── change_semester_dialog.dart
    │   │   └── exam_time_widgets.dart
    │   ├── free_class_page_widgets
    │   │   └── filter_fab.dart
    │   └── grade_page_widgets
    │       ├── gpa_card.dart
    │       ├── gpa_table.dart
    │       ├── grade_details.dart
    │       ├── grade_simple.dart
    │       ├── help_dialog.dart
    │       ├── item_filter_dialog.dart
    │       └── semester_selector.dart
    ├── modified_widgets # 对 Material 库一些内置 widget 进行小修改后的 widgets
    │   ├── my_drop_down_menu.dart
    │   └── my_navigation_drawer.dart
    ├── settingspage_widgets # 设置页面用到的 widgets
    │   ├── advanced_settings_widgets
    │   │   ├── class_schedule_data_listview_widgets
    │   │   │   └── import_json_data_dialog.dart
    │   │   ├── set_curve_duration_dialog.dart
    │   │   └── set_curve_type_dialog.dart
    │   ├── color_settings_widgets
    │   │   ├── add_new_color_dialog.dart
    │   │   └── change_color_dialog.dart
    │   ├── customize_settings_widgets
    │   │   ├── preview_card.dart # 示例课程卡片（用来预览修改效果的）
    │   │   ├── set_course_card_appearance.dart
    │   │   └── set_double_value_dialog.dart
    │   ├── logout_dialog.dart
    │   ├── palette_settings_widgets
    │   │   ├── palette_card.dart
    │   │   └── showcase_palette_card.dart
    │   ├── startup_page_dropdownmenu.dart
    │   └── theme_settings_widgets
    │       ├── choose_theme_mode_dialog.dart
    │       └── pick_theme_color_dialog.dart
    ├── utilspages_widgets
    │   ├── login_page_widgets
    │   │   ├── error_info_snackbar.dart
    │   │   ├── fill_in_cookie_dialog.dart
    │   │   ├── logging_in_snackbar.dart
    │   │   ├── login_successful_dialog.dart
    │   │   ├── need_to_reset_password.dart
    │   │   ├── password_form_field.dart
    │   │   ├── use_cookie_login_successful_dialog.dart
    │   │   ├── username_form_field.dart
    │   │   └── verifycode_form_field.dart
    │   └── manual_login_page_widgets
    │       └── manual_login_successful_dialog.dart
    └── utils_widgets # 全局都会用到的 widgets
        ├── data_from_cache_or_http.dart # 数据使用缓存 or 实时获取的
        ├── disclaimer_dialog.dart
        ├── login_expired.dart # 登录失效
        ├── nav_drawer.dart
        ├── nav_drawer_md2.dart # Material Design 2 样式的 Drawer
        ├── nav_drawer_md3.dart # Material Design 3 样式的 Drawer
        └── new_version_available_dialog.dart # 导航抽屉，会根据设置判断使用 MD2/MD3 样式的 Drawer（上面两个文件）
```

## Contact

maiI: ```wyvern1723(AT)outlook[dot]com```
