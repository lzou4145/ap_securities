import 'package:flutter/material.dart';

/// Shown while persisted session is loading — avoids login page flash.
class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  static const Color pageBg = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: Key('startup_page'),
      backgroundColor: pageBg,
      body: SizedBox.expand(),
    );
  }
}
