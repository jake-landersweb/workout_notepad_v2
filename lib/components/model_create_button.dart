import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/text_themes.dart';

class ModelCreateButton extends StatelessWidget {
  const ModelCreateButton({
    super.key,
    required this.onTap,
    this.title = "Create",
    this.isValid = true,
    this.isLoading,
  });
  final VoidCallback onTap;
  final String title;
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
      child: isLoading ?? false
          ? const sui.LoadingIndicator()
          : Text(
              title,
              style: ttLabel(context).copyWith(
                fontWeight: isValid ? FontWeight.w600 : null,
                color: isValid
                    ? Theme.of(context).primaryColor
                    : sui.CustomColors.textColor(context).withOpacity(0.3),
              ),
            ),
    );
  }
}
