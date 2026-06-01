import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lot size for chart tab quick trade panel (default 0.01).
final chartQuickTradeLotProvider = StateProvider<double>((ref) => 0.01);
