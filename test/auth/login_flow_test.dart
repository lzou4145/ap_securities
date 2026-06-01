import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/helpers.dart';

void main() {
  group('Login flow', () {
    testWidgets('shows login when signed out', (tester) async {
      await tester.pumpApp(signedIn: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byKey(const Key('login_page')), findsOneWidget);
      expect(find.text('Securities and Futures Commission'), findsOneWidget);
    });
  });
}
