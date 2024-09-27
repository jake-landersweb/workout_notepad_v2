import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class ActionCell extends StatelessWidget {
  const ActionCell({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.constraints,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final bgColor = AppColors.cell(context);
    final textColor = AppColors.text(context);
    final iconColor = Theme.of(context).colorScheme.primary;
    return Clickable(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        constraints: constraints ??
            BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width / 2.5,
              minHeight: MediaQuery.of(context).size.width / 3,
            ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: iconColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: ttLabel(
                  context,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: ttBody(
                  context,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
