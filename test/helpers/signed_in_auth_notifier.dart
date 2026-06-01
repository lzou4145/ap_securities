import 'package:ap_securities/providers/auth.dart';

/// Pre-authenticated session for widget tests that need the main shell.
class SignedInAuthNotifier extends AuthNotifier {
  @override
  AuthState build() => const AuthStateSignedIn(
        userLabel: 'demo@apsecurities.example',
        accessToken: 'widget-test-token',
        accountId: 'test-account-id',
      );
}
