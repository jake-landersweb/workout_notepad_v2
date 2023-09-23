import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

enum WrappedButtonType { standard, main }

class WrappedButton extends StatelessWidget {
  const WrappedButton({
    super.key,
    required this.title,
    this.bg,
    this.fg,
    this.onTap,
    this.icon,
    this.iconBg,
    this.iconFg,
    this.isLoading = false,
    this.height = 45,
    this.center = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.type = WrappedButtonType.standard,
    this.rowAxisSize = MainAxisSize.min,
    this.iconSpacing = 12,
  });

  final String title;
  final Color? bg;
  final Color? fg;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? iconBg;
  final Color? iconFg;
  final bool isLoading;
  final double? height;
  final bool center;
  final EdgeInsets padding;
  final WrappedButtonType type;
  final MainAxisSize rowAxisSize;
  final double iconSpacing;

  @override
  Widget build(BuildContext context) {
    if (onTap != null) {
      return Clickable(onTap: onTap!, child: _body(context));
    }
    return _body(context);
  }

  Widget _body(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: getBg(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: height ?? 50),
        child: Padding(
          padding: padding,
          child: _content(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Row(
      mainAxisSize: rowAxisSize,
      mainAxisAlignment:
          center ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        if (icon != null)
          Padding(
            padding: EdgeInsets.only(right: iconSpacing),
            child: Container(
              decoration: BoxDecoration(
                color: iconBg ?? Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  icon!,
                  color: iconFg ?? Colors.white,
                ),
              ),
            ),
          ),
        isLoading
            ? LoadingIndicator(color: fg)
            : Expanded(
                child: Text(
                  title,
                  textAlign: center ? TextAlign.center : TextAlign.left,
                  style: ttLabel(context, color: getFg(context)),
                ),
              ),
      ],
    );
  }

  Color? getBg(BuildContext context) {
    switch (type) {
      case WrappedButtonType.standard:
        return bg ?? AppColors.cell(context);
      case WrappedButtonType.main:
        return Theme.of(context).primaryColor;
    }
  }

  Color? getFg(BuildContext context) {
    switch (type) {
      case WrappedButtonType.standard:
        return fg;
      case WrappedButtonType.main:
        return Colors.white;
    }
  }
}
