import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CollectionProgressBar extends StatelessWidget {
  const CollectionProgressBar({
    super.key,
    required this.collection,
    this.height = 30,
    this.bg,
  });
  final Collection collection;
  final double height;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    var completed = collection.items
        .where((element) => element.workoutLogId != null)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$completed / ${collection.items.length}",
          style: ttBody(
            context,
            color: AppColors.subtext(context),
            size: 12,
          ),
        ),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width =
                constraints.maxWidth * completed / collection.items.length;
            return Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: height,
                  decoration: BoxDecoration(
                    color: bg ?? AppColors.cell(context)[600],
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                Container(
                  width: width,
                  height: height,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
