import 'dart:ui';
import 'package:flutter/material.dart';

///[BlurredContainer] Container with frosted glass effect
///
///Note:
///
///It Inherit properties of [Container] so expect layout effect as container,
///while tinkering with height and width
class BlurredContainer extends StatelessWidget {
  ///```
  ///opacity is used to control the glass frosted effect
  ///
  ///value should be in between 0 and 1
  ///
  ///--1 means fully opaque
  ///--0 means fully transparent
  ///
  ///default value : 0.1
  ///```
  final double opacity;

  ///[Widget] [child]
  final Widget? child;

  ///```
  ///blur intensity
  ///default value : 5
  ///```
  final double blur;

  ///```
  ///borderRadius [BorderRadiusGeometry]
  ///
  ///example:
  ///BorderRadius.circular(10),
  ///
  /// default value : BorderRadius.circular(10),
  ///
  ///```
  final BorderRadiusGeometry? borderRadius;

  ///[GlassContainer] Height
  final double? height;

  ///[GlassContainer] Width
  final double? width;

  ///```
  ///border [BoxBorder]
  ///
  ///example:
  ///Border.all(
  ///   color: Colors.white.withOpacity(0.3),
  ///   width: 0.3,
  ///   style: BorderStyle.solid,
  ///),
  ///
  ///default is same as example
  ///```
  final BoxBorder? border;

  final Color? backgroundColor;

  final AlignmentGeometry? alignment;

  final bool shrink;

  const BlurredContainer({
    Key? key,
    this.opacity = 0.05,
    this.child,
    this.blur = 5,
    this.border,
    this.height,
    this.width,
    this.borderRadius,
    this.backgroundColor,
    this.alignment,
    this.shrink = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      foregroundDecoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
      width: width,
      child: shrink
          ? Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _child(context),
                ],
              ),
            )
          : _child(context),
    );
  }

  Widget _child(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius as BorderRadius? ?? BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(10),
            color: backgroundColor?.withOpacity(opacity),
            border: border,
          ),
          alignment: alignment,
          child: child,
        ),
      ),
    );
  }
}
