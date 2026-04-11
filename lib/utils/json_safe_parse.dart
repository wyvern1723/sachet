/// JSON 安全解析扩展方法
///
/// 用于处理后端返回类型不一致的场景（String/num/null 混用）
extension JsonSafeParse on Map<String, dynamic> {
  /// 安全解析为 String?
  String? safeString(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is String) return value;
    if (value is num) return value.toString();
    return value.toString();
  }

  /// 安全解析为 int?
  int? safeInt(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt(); // 向下取整，如需四舍五入请用 .round()
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  /// 安全解析为 double?
  double? safeDouble(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  /// 安全解析为 bool?
  /// 支持: null, bool, String('true'/'1'), int(1/0)
  bool? safeBool(String key) {
    final value = this[key];
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      final lower = value.trim().toLowerCase();
      if (lower == 'true' || lower == '1') return true;
      if (lower == 'false' || lower == '0') return false;
    }
    return null;
  }
}
