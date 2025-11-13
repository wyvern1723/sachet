/// 登录结果
enum LoginResponseStatus {
  success, //成功
  unknowError, // 未知错误
  failed, // 登录失败（用户名或密码错误，验证码错误……）
  otherStatusCode // 返回了其他 StatusCode
}
