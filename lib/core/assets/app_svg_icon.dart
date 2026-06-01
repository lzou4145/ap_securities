import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Vector icon from `assets/icons/*.svg` with optional theme tint.
class AppSvgIcon extends StatelessWidget {
  const AppSvgIcon.asset(
    this.assetPath, {
    super.key,
    this.size = 24,
    this.width,
    this.height,
    this.color,
    this.semanticLabel,
  });

  final String assetPath;
  final double? size;
  final double? width;
  final double? height;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;

    return Semantics(
      label: semanticLabel,
      child: SvgPicture.asset(
        assetPath,
        width: w,
        height: h,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : null,
      ),
    );
  }
}
