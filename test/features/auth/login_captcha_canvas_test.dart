import 'package:ap_securities/features/auth/presentation/widgets/login_captcha_canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoginCaptchaCanvas paints without error', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LoginCaptchaCanvas(
            code: '6169',
            seed: 42,
          ),
        ),
      ),
    );

    expect(find.byType(LoginCaptchaCanvas), findsOneWidget);
    await tester.pump();
  });
}
