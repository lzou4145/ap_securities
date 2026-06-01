import 'package:ap_securities/shell/shell.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('App', () {
    testWidgets('renders MainShellPage when signed in', (tester) async {
      await tester.pumpApp();
      await tester.pumpAndSettle();
      expect(find.byType(MainShellPage), findsOneWidget);
    });
  });
}
