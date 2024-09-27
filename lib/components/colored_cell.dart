import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum ColoredCellSize {
  small,
  medium,
  large;

  EdgeInsets getPadding() {
    switch (this) {
      case ColoredCellSize.small:
        return const EdgeInsets.fromLTRB(10, 4, 10, 4);
      case ColoredCellSize.medium:
        return const EdgeInsets.fromLTRB(16, 6, 16, 6);
      case ColoredCellSize.large:
        return const EdgeInsets.fromLTRB(24, 10, 24, 10);
    }
  }

  BorderRadiusGeometry getBorderRadius() {
    switch (this) {
      case ColoredCellSize.small:
        return BorderRadius.circular(5);
      case ColoredCellSize.medium:
        return BorderRadius.circular(5);
      case ColoredCellSize.large:
        return BorderRadius.circular(10);
    }
  }

  double textSize() {
    switch (this) {
      case ColoredCellSize.small:
        return 14;
      case ColoredCellSize.medium:
        return 16;
      case ColoredCellSize.large:
        return 18;
    }
  }
}

class ColoredCell extends StatelessWidget {
  const ColoredCell({
    super.key,
    required this.title,
    this.size = ColoredCellSize.medium,
    this.seed,
    this.color,
    this.textColor,
    this.offColor,
    this.offTextColor,
    this.on = true,
    this.disabled = false,
    this.onTap,
    this.bordered,
    this.onBorded,
    this.offBordered,
    this.isTag = false,
    this.icon,
    this.padding,
  });
  final String title;
  final ColoredCellSize size;
  final String? seed;
  final Color? color;
  final Color? textColor;
  final Color? offColor;
  final Color? offTextColor;
  final bool on;
  final bool disabled;
  final bool? bordered;
  final bool? onBorded;
  final bool? offBordered;
  final bool isTag;
  final FutureOr<void> Function()? onTap;
  final IconData? icon;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    if (disabled || onTap == null) {
      return _body(context);
    }

    return Clickable(
      onTap: () async => await onTap!(),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var computedColor = color ?? ColorUtil.random(seed ?? title);
    var text = on
        ? textColor ?? getSwatch(computedColor)[800]!
        : offTextColor ?? AppColors.text(context);
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: on
              ? computedColor.withOpacity(0.2)
              : offColor ?? AppColors.cell(context),
          borderRadius: size.getBorderRadius(),
          border: Border.all(
            color: on
                ? ((bordered ?? onBorded ?? true)
                    ? computedColor
                    : computedColor.withOpacity(0.2))
                : offColor ??
                    ((bordered ?? offBordered ?? false)
                        ? AppColors.divider(context)
                        : AppColors.cell(context)),
          ),
        ),
        child: Padding(
          padding: padding ?? size.getPadding(),
          child: _getTitle(context, text),
        ),
      ),
    );
  }

  Widget _getTitle(BuildContext context, Color text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: Icon(icon!, color: text),
          ),
        _getTitleText(context, text),
      ],
    );
  }

  Widget _getTitleText(BuildContext context, Color text) {
    return Text(
      isTag ? "#$title" : title,
      textAlign: TextAlign.center,
      style: ttBody(
        context,
        size: size.textSize(),
        color: text,
      ),
    );
  }
}
