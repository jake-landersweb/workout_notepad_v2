import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isValid = true,
    this.isLoading,
    this.minHeight = 50,
    this.icon,
  });
  final String title;
  final VoidCallback onTap;
  final bool isValid;
  final bool? isLoading;
  final double minHeight;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Clickable(
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
          borderRadius: BorderRadius.circular(100),
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
                ? const LoadingIndicator()
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Icon(
                            icon,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      Text(
                        title,
                        style: ttLabel(context).copyWith(
                          color: isValid
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
