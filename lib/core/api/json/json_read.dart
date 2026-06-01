/// Safe JSON field readers for APP-api payloads.
abstract final class JsonRead {
  static int asInt(dynamic value, {int defaultValue = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static int? asIntOrNull(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static String asString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static String? asStringOrNull(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    return text.isEmpty ? null : text;
  }

  static bool asBool(dynamic value, {bool defaultValue = false}) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value == '1' || value.toLowerCase() == 'true';
    }
    return defaultValue;
  }

  static List<T> list<T>(
    dynamic value,
    T Function(Map<String, dynamic> json) map,
  ) {
    if (value is! List) return const [];
    return value
        .whereType<Map<dynamic, dynamic>>()
        .map((e) => map(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Map<String, dynamic> map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }
}
