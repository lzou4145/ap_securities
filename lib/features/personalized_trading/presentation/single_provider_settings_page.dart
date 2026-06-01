import 'package:ap_securities/core/api/models/api_models_follow.dart';
import 'package:ap_securities/core/network/api_exception.dart';
import 'package:ap_securities/core/ui/app_toast.dart';
import 'package:ap_securities/features/personalized_trading/presentation/personalized_trading_colors.dart';
import 'package:ap_securities/features/personalized_trading/providers/personalized_trading_providers.dart';
import 'package:ap_securities/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SingleProviderSettingsPage extends ConsumerStatefulWidget {
  const SingleProviderSettingsPage({super.key});

  @override
  ConsumerState<SingleProviderSettingsPage> createState() =>
      _SingleProviderSettingsPageState();
}

class _SingleProviderSettingsPageState
    extends ConsumerState<SingleProviderSettingsPage> {
  final _amountController = TextEditingController();
  final _rateController = TextEditingController();

  bool _submitting = false;
  bool _fieldsReady = false;

  @override
  void dispose() {
    _amountController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  void _applyConfig(SingleConfig config) {
    if (_fieldsReady) return;
    _amountController.text = _formatAmount(config.followWalletsTradeAmount);
    _rateController.text = '${config.followCommissionRate}';
    _fieldsReady = true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final configAsync = ref.watch(singleProviderConfigProvider);

    ref.listen(singleProviderConfigProvider, (previous, next) {
      next.whenData(_applyConfig);
    });
    configAsync.whenData(_applyConfig);

    return Scaffold(
      backgroundColor: PersonalizedTradingColors.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.singleProviderSettingsTitle,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: PersonalizedTradingColors.title,
          ),
        ),
        leading: IconButton(
          onPressed: _submitting ? null : () => context.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: PersonalizedTradingColors.primaryBlue,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: PersonalizedTradingColors.divider,
          ),
        ),
      ),
      body: configAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorBody(
          message: '$e',
          onRetry: () => ref.invalidate(singleProviderConfigProvider),
          retryLabel: l10n.retryButton,
        ),
        data: (_) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _InfoBanner(text: l10n.singleProviderSettingsIntro),
                  const SizedBox(height: 20),
                  _SettingsField(
                    label: l10n.singleProviderFollowAmountLabel,
                    hint: l10n.singleProviderFollowAmountHint,
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,5}'),
                      ),
                    ],
                    suffix: null,
                  ),
                  const SizedBox(height: 16),
                  _SettingsField(
                    label: l10n.singleProviderCommissionLabel,
                    hint: l10n.singleProviderCommissionHint,
                    controller: _rateController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    suffix: l10n.singleProviderCommissionSuffix,
                  ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _submitting ? null : _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: PersonalizedTradingColors.primaryBlue,
                      disabledBackgroundColor:
                          PersonalizedTradingColors.primaryBlue.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.singleProviderSettingsSave,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    final l10n = context.l10n;
    final amountRaw = _amountController.text.trim();
    final rateRaw = _rateController.text.trim();

    if (amountRaw.isEmpty) {
      context.showAppMessage(l10n.singleProviderAmountRequired);
      return;
    }
    final amount = double.tryParse(amountRaw);
    if (amount == null || amount <= 0) {
      context.showAppMessage(l10n.singleProviderAmountInvalid);
      return;
    }

    if (rateRaw.isEmpty) {
      context.showAppMessage(l10n.singleProviderCommissionRequired);
      return;
    }
    final rate = int.tryParse(rateRaw);
    if (rate == null || rate < 0 || rate > 100) {
      context.showAppMessage(l10n.singleProviderCommissionInvalid);
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(personalizedTradingRepositoryProvider).setSingleConfig(
            followWalletsTradeAmount: amount.toStringAsFixed(2),
            followCommissionRate: rate,
          );
      if (!mounted) return;
      ref.invalidate(singleProviderConfigProvider);
      context.showAppMessage(l10n.singleProviderSettingsSuccess);
      context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      final message = e.message.trim();
      context.showAppMessage(
        message.isNotEmpty ? message : l10n.singleProviderSettingsFailed,
        variant: AppMessageVariant.error,
        duration: AppToast.tradeErrorDuration,
      );
    } on Object {
      if (!mounted) return;
      context.showAppMessage(
        l10n.singleProviderSettingsFailed,
        variant: AppMessageVariant.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  static String _formatAmount(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return '';
    final value = double.tryParse(trimmed);
    if (value == null) return trimmed;
    return value.toStringAsFixed(2);
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        height: 1.4,
        color: PersonalizedTradingColors.subtitle,
      ),
    );
  }
}

class _SettingsField extends StatelessWidget {
  const _SettingsField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.inputFormatters,
    required this.suffix,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: PersonalizedTradingColors.title,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: PersonalizedTradingColors.title,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: PersonalizedTradingColors.searchHint,
            ),
            filled: true,
            fillColor: PersonalizedTradingColors.searchBg,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: PersonalizedTradingColors.subtitle,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({
    required this.message,
    required this.onRetry,
    required this.retryLabel,
  });

  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: Text(retryLabel)),
          ],
        ),
      ),
    );
  }
}
