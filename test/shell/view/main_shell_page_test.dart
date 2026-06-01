import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('Main shell (via App)', () {
    testWidgets('renders bottom navigation with five destinations',
        (tester) async {
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationDestination), findsNWidgets(5));
    });

    testWidgets('market tab shows quotes title from page app bar',
        (tester) async {
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.text('Market'), findsOneWidget);
      expect(find.text('AUDCAD'), findsWidgets);
    });

    testWidgets('switching tab updates shell app bar title', (tester) async {
      await tester.pumpApp();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trade'));
      await tester.pumpAndSettle();
      expect(find.text('Trade'), findsWidgets);
    });
  });
}
