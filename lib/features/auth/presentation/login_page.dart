import 'package:ap_securities/core/assets/assets.dart';
import 'package:ap_securities/core/network/api_exception.dart'
    show ApiErrorKind, ApiException;
import 'package:ap_securities/core/router/app_routes.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/auth/presentation/widgets/login_captcha_canvas.dart';
import 'package:ap_securities/features/auth/providers/auth_repository_provider.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:ap_securities/providers/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Design tokens aligned with the login mock (primary blue ≈ `#2D8BFF`).
abstract final class _LoginColors {
  static const Color primaryBlue = Color(0xFF2D8BFF);
  static const Color pageBg = Color(0xFFF4F6F9);
  static const Color label = Color(0xFF000000);
  static const Color hint = Color(0xFF9E9E9E);
  static const Color divider = Color(0xFFE0E0E0);
}

abstract final class _LoginLayout {
  static const double horizontalPadding = 28;
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaController = TextEditingController();
  late final TapGestureRecognizer _privacyTap;

  var _agreedToPrivacy = false;
  var _submitting = false;
  var _captchaLoading = false;
  Uint8List? _captchaImageBytes;
  String? _captchaText;
  int _captchaVisualSeed = 0;

  @override
  void initState() {
    super.initState();
    _privacyTap = TapGestureRecognizer()..onTap = _openPrivacyPolicy;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadCaptcha());
  }

  @override
  void dispose() {
    _privacyTap.dispose();
    _accountController.dispose();
    _passwordController.dispose();
    _captchaController.dispose();
    super.dispose();
  }

  Future<void> _loadCaptcha({bool clearInput = true}) async {
    if (_captchaLoading) return;
    setState(() => _captchaLoading = true);
    try {
      final challenge =
          await ref.read(authRepositoryProvider).fetchLoginCaptcha();
      if (!mounted) return;
      setState(() {
        _captchaImageBytes = challenge.imageBytes;
        _captchaText = challenge.textCaptcha;
        _captchaVisualSeed = challenge.rawCode.hashCode;
        if (clearInput) _captchaController.clear();
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _captchaImageBytes = null;
        _captchaText = null;
        _captchaVisualSeed = 0;
      });
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty
            ? message
            : context.l10n.loginCaptchaLoadFailedSnackbar,
        variant: AppMessageVariant.error,
      );
    } on Object {
      if (!mounted) return;
      setState(() {
        _captchaImageBytes = null;
        _captchaText = null;
        _captchaVisualSeed = 0;
      });
      context.showAppMessage(
        context.l10n.loginCaptchaLoadFailedSnackbar,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _captchaLoading = false);
    }
  }

  void _openPrivacyPolicy() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.loginPrivacyPolicy),
        content: SingleChildScrollView(
          child: Text(
            l10n.modulePlaceholder,
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      key: const Key('login_page'),
      backgroundColor: _LoginColors.pageBg,
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topHeight =
                (constraints.maxHeight * 0.28).clamp(180.0, 260.0).toDouble();
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: topHeight,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          AppIcons.authBg,
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                          filterQuality: FilterQuality.high,
                        ),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -32),
                    child: Column(
                      children: [
                        const AppRasterIcon.asset(
                          AppIcons.logo,
                          width: 80,
                          height: 80,
                          semanticLabel: 'Brand',
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _LoginLayout.horizontalPadding,
                          ),
                          child: Text(
                            l10n.loginRegulatoryTitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: _LoginColors.label,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _LoginLayout.horizontalPadding,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _UnderlineLabeledField(
                                label: l10n.loginAccountLabel,
                                hint: l10n.loginAccountHint,
                                controller: _accountController,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 22),
                              _UnderlineLabeledField(
                                label: l10n.loginPasswordLabel,
                                hint: l10n.loginPasswordHint,
                                controller: _passwordController,
                                obscureText: true,
                              ),
                              const SizedBox(height: 22),
                              _LoginCaptchaField(
                                label: l10n.loginCaptchaLabel,
                                hint: l10n.loginCaptchaHint,
                                controller: _captchaController,
                                imageBytes: _captchaImageBytes,
                                textCaptcha: _captchaText,
                                captchaVisualSeed: _captchaVisualSeed,
                                loading: _captchaLoading,
                                onRefresh: _loadCaptcha,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 22),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _LoginLayout.horizontalPadding,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _agreedToPrivacy,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  fillColor: WidgetStateProperty.resolveWith(
                                      (states) {
                                    if (states
                                        .contains(WidgetState.selected)) {
                                      return _LoginColors.primaryBlue;
                                    }
                                    return Colors.transparent;
                                  }),
                                  checkColor: Colors.white,
                                  side: const BorderSide(
                                    color: _LoginColors.divider,
                                    width: 1.5,
                                  ),
                                  shape: const CircleBorder(),
                                  onChanged: (v) {
                                    setState(() {
                                      _agreedToPrivacy = v ?? false;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: _LoginColors.label,
                                          height: 1.45,
                                        ),
                                    children: [
                                      TextSpan(text: l10n.loginAgreePrefix),
                                      TextSpan(
                                        text: l10n.loginPrivacyPolicy,
                                        style: const TextStyle(
                                          color: _LoginColors.primaryBlue,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        recognizer: _privacyTap,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: _LoginLayout.horizontalPadding,
                          ),
                          child: SizedBox(
                            height: 52,
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _submitting ? null : _onLogin,
                              style: FilledButton.styleFrom(
                                backgroundColor: _LoginColors.primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(l10n.loginPrimaryButton),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _onLogin() async {
    final l10n = context.l10n;

    if (!_agreedToPrivacy) {
      context.showAppMessage(l10n.loginAgreeRequiredSnackbar);
      return;
    }

    if (_captchaController.text.trim().isEmpty) {
      context.showAppMessage(l10n.loginCaptchaRequiredSnackbar);
      return;
    }

    if (_captchaImageBytes == null && _captchaText == null) {
      context.showAppMessage(
        l10n.loginCaptchaLoadFailedSnackbar,
        variant: AppMessageVariant.error,
      );
      await _loadCaptcha(clearInput: false);
      return;
    }

    setState(() => _submitting = true);
    try {
      final ok =
          await ref.read(authNotifierProvider.notifier).signInWithPassword(
                account: _accountController.text,
                password: _passwordController.text,
                loginCode: _captchaController.text,
                agreedToPrivacy: _agreedToPrivacy,
              );
      if (!mounted) return;
      if (!ok) {
        context.showAppMessage(l10n.loginInvalidCredentialsSnackbar);
        await _loadCaptcha();
        return;
      }
      context.go(AppRoutes.market);
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : l10n.loginFailedSnackbar,
        variant: AppMessageVariant.error,
      );
      if (e.kind != ApiErrorKind.network && e.kind != ApiErrorKind.timeout) {
        await _loadCaptcha();
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _LoginCaptchaField extends StatelessWidget {
  const _LoginCaptchaField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.imageBytes,
    required this.textCaptcha,
    required this.captchaVisualSeed,
    required this.loading,
    required this.onRefresh,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Uint8List? imageBytes;
  final String? textCaptcha;
  final int captchaVisualSeed;
  final bool loading;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _LoginColors.label,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                style: const TextStyle(
                  fontSize: 15,
                  color: _LoginColors.label,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: _LoginColors.hint,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: loading ? null : onRefresh,
              child: Container(
                width: 96,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _LoginColors.divider),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : imageBytes != null
                        ? Image.memory(
                            imageBytes!,
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                          )
                        : textCaptcha != null
                            ? LoginCaptchaCanvas(
                                code: textCaptcha!,
                                seed: captchaVisualSeed,
                              )
                            : Icon(
                                Icons.refresh,
                                size: 22,
                                color: _LoginColors.hint.withValues(alpha: 0.9),
                              ),
              ),
            ),
          ],
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: _LoginColors.divider,
        ),
      ],
    );
  }
}

class _UnderlineLabeledField extends StatelessWidget {
  const _UnderlineLabeledField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: _LoginColors.label,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: obscureText,
                keyboardType: keyboardType,
                style: const TextStyle(
                  fontSize: 15,
                  color: _LoginColors.label,
                ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: const TextStyle(
                    fontSize: 15,
                    color: _LoginColors.hint,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
              ),
            ),
          ],
        ),
        const Divider(
          height: 1,
          thickness: 1,
          color: _LoginColors.divider,
        ),
      ],
    );
  }
}
