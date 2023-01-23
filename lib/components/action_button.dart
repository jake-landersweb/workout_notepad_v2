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
  });
  final String title;
  final VoidCallback onTap;
  final bool isValid;
  final bool? isLoading;

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
          color: Theme.of(context).primaryColor.withOpacity(isValid ? 1 : 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isValid
                  ? Theme.of(context).primaryColor
                  : sui.CustomColors.textColor(context).withOpacity(0.1),
              width: 1),
        ),
        height: 50,
        width: double.infinity,
        child: Center(
          child: isLoading ?? false
              ? const sui.LoadingIndicator()
              : Text(
                  title,
                  style: ttLabel(context).copyWith(
                    color: isValid
                        ? Colors.white
                        : sui.CustomColors.textColor(context).withOpacity(0.3),
                  ),
                ),
        ),
      ),
    );
  }
}
