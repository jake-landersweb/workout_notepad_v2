import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CategoryCell extends StatelessWidget {
  const CategoryCell({
    super.key,
    required this.title,
  });
  final String title;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = context.read<DataModel>();
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.subtext(context),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            getIcon(dmodel),
            Text(
              title.capitalize(),
              style: ttBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget getIcon(DataModel dmodel) {
    var match = dmodel.categories.firstWhere(
      (element) => element.title == title,
      orElse: () => Category(title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: getImageIcon(match.icon, size: 20),
    );
  }
}
