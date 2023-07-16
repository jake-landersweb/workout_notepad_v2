import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

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
    var dmodel = Provider.of<DataModel>(context);
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
                    (isValid ? dmodel.color : AppColors.subtext(context)),
              ),
            ),
    );
  }
}
