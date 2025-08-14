/// 作者名称
const String authorName = "wyvern1723";

/// 作者邮箱（关于页面的反馈邮箱）
const String authorMail = "wyvern1723@outlook.com";

/// App 开发者个人资料网址
const String appDeveloperProfileUrl = "https://github.com/wyvern1723";

/// App 项目主页网址（源码仓库）
const String appRepoUrl = "https://github.com/wyvern1723/sachet";

/// App Releases Page 网址
const String appReleaseUrl = "https://github.com/wyvern1723/sachet/releases";

/// 检查应用更新的 API 地址（内容为 Github 自动生成的）
const String checkAppUpdateAPI =
    'https://api.github.com/repos/wyvern1723/sachet/releases/latest';

/// App 包名
const String appPackageName = "io.github.wyvern1723.sachet";

/// 当前安装包的 abi。用于检查更新时判断应该下载哪个 apk（因为按 abi 拆分了安装包，以减小体积），发现通过函数动态获取当前设备的 abi 比较麻烦，就用了这种「宏定义」的方法。
///
/// 使用 `--dart-define="abi=$ABI"` 定义，如：
///
/// `flutter build apk --release --target-platform android-arm64 --dart-define="abi=arm64-v8a"`
///
/// `flutter build apk --release --target-platform android-arm --dart-define="abi=armeabi-v7a"`
///
/// `flutter build apk --release --target-platform android-x64 --dart-define="abi=x86_64"`
///
/// 默认为 arm64-v8a
const String abi = String.fromEnvironment('abi', defaultValue: "arm64-v8a");
