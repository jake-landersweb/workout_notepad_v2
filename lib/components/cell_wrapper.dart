import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CellWrapper extends StatelessWidget {
  const CellWrapper({
    super.key,
    required this.child,
    this.minHeight = 50,
    this.backgroundColor,
    this.borderRadius = 10,
    this.horizontalPadding = 16,
    this.border,
  });
  final Widget child;
  final double minHeight;
  final Color? backgroundColor;
  final double borderRadius;
  final double horizontalPadding;
  final Border? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cell(context),
        border: border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minHeight: minHeight, minWidth: double.infinity),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(child: child),
        ),
      ),
    );
  }
}
