import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isValid = true,
    this.isLoading,
    this.minHeight = 50,
  });
  final String title;
  final VoidCallback onTap;
  final bool isValid;
  final bool? isLoading;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return sui.Button(
      onTap: () {
        if (isValid) {
          onTap();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: isValid
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isValid
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: double.infinity,
          ),
          child: Center(
            child: isLoading ?? false
                ? const sui.LoadingIndicator()
                : Text(
                    title,
                    style: ttLabel(context).copyWith(
                      color: isValid
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
