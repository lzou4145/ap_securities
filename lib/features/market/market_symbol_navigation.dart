import 'package:ap_securities/core/api/models/api_models_market.dart';
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/features/market/data/market_variety_mapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void openTradingSymbolDetail(BuildContext context, {required Variety variety}) {
  final detail = MarketVarietyMapper.detailFromVariety(variety);
  context.push(
    AppRoutes.marketSymbolDetail(detail.symbol),
    extra: detail,
  );
}
