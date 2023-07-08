import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
    this.textAlign,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
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
  final TextAlign? textAlign;
  final EdgeInsets padding;

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
        color: bg ?? AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      height: height,
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
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
                : Text(
                    title,
                    textAlign: textAlign,
                    style: ttLabel(context, color: fg),
                  ),
          ],
        ),
      ),
    );
  }
}
