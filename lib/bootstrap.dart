import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function(SharedPreferences sharedPreferences) builder,
) async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(await builder(sharedPreferences));
}
