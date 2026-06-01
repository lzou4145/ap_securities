import 'package:ap_securities/core/api/json/json_read.dart';

/// `{ value, label }` option (e.g. follow multiplier).
class LabelValueOption {
  const LabelValueOption({required this.value, required this.label});

  factory LabelValueOption.fromJson(Map<String, dynamic> json) {
    return LabelValueOption(
      value: JsonRead.asInt(json['value']),
      label: JsonRead.asString(json['label']),
    );
  }

  final int value;
  final String label;
}

class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.lastPage,
    required this.currentPage,
    required this.perPage,
  });

  factory PaginatedResponse.fromJson(
    Object? json,
    T Function(Map<String, dynamic> json) itemFromJson,
  ) {
    final map = JsonRead.map(json);
    return PaginatedResponse(
      items: JsonRead.list(map['data'], itemFromJson),
      total: JsonRead.asInt(map['total']),
      lastPage: JsonRead.asInt(map['last_page'], defaultValue: 1),
      currentPage: JsonRead.asInt(map['current_page'], defaultValue: 1),
      perPage: JsonRead.asInt(map['per_page'], defaultValue: 30),
    );
  }

  final List<T> items;
  final int total;
  final int lastPage;
  final int currentPage;
  final int perPage;
}

List<T> parseListOrEmpty<T>(
  Object? json,
  T Function(Map<String, dynamic> json) fromJson,
) {
  return JsonRead.list(json, fromJson);
}

void parseVoid(Object? json) {}
