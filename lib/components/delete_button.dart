import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class DeleteButton extends StatelessWidget {
  const DeleteButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading,
    this.minHeight = 50,
  });
  final String title;
  final VoidCallback onTap;
  final bool? isLoading;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: minHeight,
            minWidth: double.infinity,
          ),
          child: Center(
            child: isLoading ?? false
                ? const LoadingIndicator()
                : Text(
                    title,
                    style: ttLabel(context).copyWith(
                      color: Theme.of(context).colorScheme.onError,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
