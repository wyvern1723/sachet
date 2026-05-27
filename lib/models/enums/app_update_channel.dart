import 'package:sachet/constants/app_info_constants.dart';

enum AppUpdateChannel {
  github('api.github.com', appUpdateSourceUrlApiGithubCom),
  wyvernlab(
    'update.sachet.wyvernlab.com',
    appUpdateSourceUrlUpdateSachetWyvernlabCom,
  );

  const AppUpdateChannel(this.host, this.url);

  final String host;
  final String url;
}
