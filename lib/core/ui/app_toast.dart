import 'dart:async';

import 'package:ap_securities/providers/router.dart';
import 'package:flutter/material.dart';

/// Lightweight top toast (centered horizontally, upper area).
///
/// Flutter [SnackBar] is always anchored to the bottom of [Scaffold]; use this
/// for app-wide messages instead.
enum AppMessageVariant {
  normal,
  error,
}

abstract final class AppToast {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static const _horizontalMargin = 16.0;
  static const _topOffsetBelowSafeArea = 48.0;
  static const defaultDuration = Duration(seconds: 2);
  static const tradeErrorDuration = Duration(seconds: 3);

  /// Shows a message. Prefer [BuildContext] from a route under [MaterialApp].
  static void show(
    BuildContext? context, {
    required String message,
    AppMessageVariant variant = AppMessageVariant.normal,
    Duration duration = defaultDuration,
  }) {
    if (message.trim().isEmpty) return;

    final overlayState = _resolveOverlay(context);
    if (overlayState == null) return;

    hide();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (overlayContext) => _AppToastOverlay(
        message: message,
        variant: variant,
        onDismiss: () {
          if (_entry == entry) hide();
        },
      ),
    );

    _entry = entry;
    overlayState.insert(entry);

    _timer = Timer(duration, hide);
  }

  static void hide() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }

  static OverlayState? _resolveOverlay(BuildContext? context) {
    if (context != null && context.mounted) {
      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay != null) return overlay;
    }
    return rootNavigatorKey.currentState?.overlay;
  }
}

class _AppToastOverlay extends StatefulWidget {
  const _AppToastOverlay({
    required this.message,
    required this.variant,
    required this.onDismiss,
  });

  final String message;
  final AppMessageVariant variant;
  final VoidCallback onDismiss;

  @override
  State<_AppToastOverlay> createState() => _AppToastOverlayState();
}

class _AppToastOverlayState extends State<_AppToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  )..forward();

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, -0.12),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top =
        MediaQuery.paddingOf(context).top + AppToast._topOffsetBelowSafeArea;
    final isError = widget.variant == AppMessageVariant.error;

    return Positioned(
      top: top,
      left: AppToast._horizontalMargin,
      right: AppToast._horizontalMargin,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: isError
                    ? const Color(0xFFE53935).withValues(alpha: 0.94)
                    : const Color(0xFF323232).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        textHeightBehavior: const TextHeightBehavior(
                          applyHeightToFirstAscent: false,
                          applyHeightToLastDescent: false,
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 32,
                      height: 32,
                      child: IconButton(
                        onPressed: widget.onDismiss,
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xCCFFFFFF),
                        ),
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

extension AppMessageContext on BuildContext {
  void showAppMessage(
    String message, {
    AppMessageVariant variant = AppMessageVariant.normal,
    Duration duration = AppToast.defaultDuration,
  }) {
    AppToast.hide();
    AppToast.show(
      this,
      message: message,
      variant: variant,
      duration: duration,
    );
  }
}
