import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class TagCell extends StatelessWidget {
  const TagCell({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.cell(context)[600],
        color: ColorUtil.random(title).withOpacity(0.2),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ColorUtil.random(title)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
        child: Text(
          "#$title",
          textAlign: TextAlign.center,
          style: ttcaption(
            context,
            color: getSwatch(ColorUtil.random(title))[600]!.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
