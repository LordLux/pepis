import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

class Svg extends StatelessWidget {
  final String assetName;
  final Color? color;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Alignment alignment;
  final bool allowDrawingOutsideViewBox;
  final String? semanticsLabel;
  final AssetBundle? bundle;
  final Clip clipBehavior;
  final bool excludeFromSemantics;
  final bool matchTextDirection;
  final String? package;
  final Widget Function(BuildContext)? placeholderBuilder;
  final SvgTheme? theme;

  const Svg(
    this.assetName, {
    super.key,
    this.color,
    this.fit = BoxFit.contain,
    this.width,
    this.height,
    this.alignment = Alignment.center,
    this.allowDrawingOutsideViewBox = false,
    this.semanticsLabel,
    this.bundle,
    this.clipBehavior = Clip.hardEdge,
    this.excludeFromSemantics = false,
    this.matchTextDirection = false,
    this.package,
    this.placeholderBuilder,
    this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetName,
      colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
      fit: fit,
      width: width,
      height: height,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      semanticsLabel: semanticsLabel,
      bundle: bundle,
      clipBehavior: clipBehavior,
      excludeFromSemantics: excludeFromSemantics,
      key: key,
      matchTextDirection: matchTextDirection,
      package: package,
      placeholderBuilder: placeholderBuilder,
      theme: theme,
    );
  }
}
