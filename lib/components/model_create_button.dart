import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:workout_notepad_v2/components/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';

class ModelCreateButton extends StatelessWidget {
  const ModelCreateButton({
    super.key,
    required this.onTap,
    this.title = "Create",
    this.isValid = true,
    this.isLoading,
    this.textColor,
  });
  final VoidCallback onTap;
  final String title;
  final bool isValid;
  final bool? isLoading;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        if (isValid) {
          onTap();
        }
      },
      child: isLoading ?? false
          ? const LoadingIndicator()
          : Text(
              title,
              style: ttLabel(context).copyWith(
                color: textColor ??
                    (isValid
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline),
              ),
            ),
    );
  }
}
