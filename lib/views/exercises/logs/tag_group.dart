import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/root.dart';

class SetGroup extends StatelessWidget {
  const SetGroup({
    super.key,
    required this.title,
    required this.tagTitles,
    this.allowsTap = true,
  });
  final String title;
  final Iterable<String> tagTitles;
  final bool allowsTap;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        showFloatingSheet(
          context: context,
          builder: (context) => FloatingSheet(
            title: "Tags",
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Wrap(
                alignment: WrapAlignment.start,
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (var i in tagTitles) TagCell(title: i),
                ],
              ),
            ),
          ),
        );
      },
      child: Column(
        children: [
          Center(
            child: Text(
              title,
              style: ttBody(
                context,
                color: AppColors.subtext(context),
              ),
            ),
          ),
          TagGroup(titles: tagTitles),
        ],
      ),
    );
  }
}

class TagGroup extends StatelessWidget {
  const TagGroup({super.key, required this.titles});
  final Iterable<String> titles;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (var i in titles) _cell(context, i),
      ],
    );
  }

  Widget _cell(BuildContext context, String title) {
    return Container(
      decoration: BoxDecoration(
        // color: AppColors.cell(context)[600],
        color: ColorUtil.random(title),
        shape: BoxShape.circle,
      ),
      height: 7,
      width: 7,
    );
  }
}
