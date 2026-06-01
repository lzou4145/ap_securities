import 'package:flutter/material.dart';

/// Loads a PNG from `AppIcons` (or any `assets/...` path) with automatic
/// **1× / 2× / 3×** selection when matching files exist under `2.0x/` and
/// `3.0x/`.
class AppRasterIcon extends StatelessWidget {
  const AppRasterIcon.asset(
    this.assetPath, {
    super.key,
    this.size,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.semanticLabel,
    this.color,
    this.colorBlendMode,
    this.filterQuality = FilterQuality.medium,
  });

  /// Full asset key, e.g. `AppIcons.logo`.
  final String assetPath;
  final double? size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final String? semanticLabel;
  final Color? color;
  final BlendMode? colorBlendMode;
  final FilterQuality filterQuality;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    return Image.asset(
      assetPath,
      width: w,
      height: h,
      fit: fit,
      alignment: alignment,
      semanticLabel: semanticLabel,
      color: color,
      colorBlendMode: colorBlendMode,
      filterQuality: filterQuality,
      gaplessPlayback: true,
    );
  }
}
