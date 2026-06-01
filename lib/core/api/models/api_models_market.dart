import 'package:ap_securities/core/api/json/json_read.dart';
import 'package:ap_securities/core/api/models/api_models_common.dart';

class Variety {
  const Variety({
    required this.id,
    required this.code,
    required this.name,
    required this.pointDiff,
    required this.pointDiffMax,
    required this.feeInventoryShort,
    required this.feeInventoryLong,
    required this.unit,
    required this.multiplier,
    required this.undulateMin,
    required this.onlineStatus,
    required this.bailHedge,
    required this.bailPercent,
    required this.decimalPlace,
    required this.stopLossLevel,
    required this.type,
    this.varietyAccount = const [],
  });

  factory Variety.fromJson(Map<String, dynamic> json) {
    return Variety(
      id: JsonRead.asInt(json['id']),
      code: JsonRead.asString(json['code']),
      name: JsonRead.asString(json['name']),
      pointDiff: JsonRead.asInt(json['point_diff']),
      pointDiffMax: JsonRead.asInt(json['point_diff_max']),
      feeInventoryShort: JsonRead.asString(json['fee_inventory_short']),
      feeInventoryLong: JsonRead.asString(json['fee_inventory_long']),
      unit: JsonRead.asString(json['unit']),
      multiplier: JsonRead.asInt(json['multiplier']),
      undulateMin: JsonRead.asString(json['undulate_min']),
      onlineStatus: JsonRead.asInt(json['online_status']),
      bailHedge: JsonRead.asString(json['bail_hedge']),
      bailPercent: JsonRead.asString(json['bail_percent']),
      decimalPlace: JsonRead.asInt(json['decimal_place']),
      stopLossLevel: JsonRead.asInt(json['stop_loss_level']),
      type: JsonRead.asInt(json['type']),
      varietyAccount: JsonRead.list(
        json['variety_account'],
        (e) => VarietyAccountRef.fromJson(e),
      ),
    );
  }

  final int id;
  final String code;
  final String name;
  final int pointDiff;
  final int pointDiffMax;
  final String feeInventoryShort;
  final String feeInventoryLong;
  final String unit;
  final int multiplier;
  final String undulateMin;
  final int onlineStatus;
  final String bailHedge;
  final String bailPercent;
  final int decimalPlace;
  final int stopLossLevel;
  final int type;
  final List<VarietyAccountRef> varietyAccount;
}

class VarietyAccountRef {
  const VarietyAccountRef({required this.varietyId});

  factory VarietyAccountRef.fromJson(Map<String, dynamic> json) {
    return VarietyAccountRef(varietyId: JsonRead.asInt(json['variety_id']));
  }

  final int varietyId;
}

class AccountVarietyItem {
  const AccountVarietyItem({
    required this.varietyId,
    required this.sort,
    required this.variety,
  });

  factory AccountVarietyItem.fromJson(Map<String, dynamic> json) {
    return AccountVarietyItem(
      varietyId: JsonRead.asInt(json['variety_id']),
      sort: JsonRead.asInt(json['sort']),
      variety: Variety.fromJson(JsonRead.map(json['variety'])),
    );
  }

  final int varietyId;
  final int sort;
  final Variety variety;
}

/// Grouped account varieties keyed by category (e.g. metal, energy, forex, …).
///
/// Parses every list-valued field in the API object so unknown future groups
/// are not dropped.
class VarietyGroupMap {
  const VarietyGroupMap({this.groups = const {}});

  factory VarietyGroupMap.fromJson(Object? json) {
    final map = JsonRead.map(json);
    final groups = <String, List<AccountVarietyItem>>{};

    for (final entry in map.entries) {
      final value = entry.value;
      if (value is List) {
        groups[entry.key] = JsonRead.list(value, AccountVarietyItem.fromJson);
      }
    }

    return VarietyGroupMap(groups: groups);
  }

  final Map<String, List<AccountVarietyItem>> groups;

  List<AccountVarietyItem> get all {
    final items = <AccountVarietyItem>[];
    for (final list in groups.values) {
      items.addAll(list);
    }
    return items;
  }

  List<AccountVarietyItem>? group(String key) => groups[key];
}

List<Variety> parseVarietyList(Object? json) =>
    parseListOrEmpty(json, Variety.fromJson);
