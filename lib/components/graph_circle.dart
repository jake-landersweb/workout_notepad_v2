import 'package:flutter/material.dart';

class GraphCircle extends StatelessWidget {
  const GraphCircle({
    super.key,
    required this.value,
    this.titleBuilder,
    this.size = 50,
    this.textColor,
    this.backgroundColor,
    this.foregroundColor,
  });
  final double value;
  final String Function(BuildContext context, double value)? titleBuilder;
  final double size;
  final Color? textColor;
  final Color? foregroundColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            value: _getValue(),
            color: foregroundColor ?? Colors.teal.shade300,
            backgroundColor: backgroundColor ??
                Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
            strokeWidth: 7,
          ),
        ),
        Text(
          _getTitle(context),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ],
    );
  }

  double _getValue() {
    if (value.isInfinite || value.isNaN) {
      return 0;
    }
    return value;
  }

  String _getTitle(BuildContext context) {
    if (titleBuilder != null) {
      return titleBuilder!(context, _getValue());
    }
    return "${(_getValue() * 100).toInt()}%";
  }
}
