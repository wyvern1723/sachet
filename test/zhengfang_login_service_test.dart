import 'package:flutter_test/flutter_test.dart';
import 'package:sachet/services/zhengfang_jwxt/login/zhengfang_login_service.dart';

void main() {
  group('ZhengFangLoginService', () {
    test(
      '使用用户名和密码登录正方教务系统',
      () async {
        // 创建服务实例
        final service = ZhengFangLoginService();

        // 登录
        await service.login(username: 'xxx', password: 'xxx');
      },
      skip: '需要真实用户信息登录，默认跳过',
    );
  });
}
