import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CategoryCell extends StatelessWidget {
  const CategoryCell({
    super.key,
    required this.categoryId,
    this.padding = const EdgeInsets.all(0),
  });
  final String categoryId;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = context.read<DataModel>();
    if (!dmodel.categories.any((element) => element.categoryId == categoryId)) {
      return Container();
    }
    return Padding(
      padding: padding,
      child: Container(
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
                getTitle(dmodel).capitalize(),
                style: ttBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIcon(DataModel dmodel) {
    var match = dmodel.categories.firstWhere(
      (element) => element.categoryId == categoryId,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.icon.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: getImageIcon(match.icon, size: 20),
    );
  }

  String getTitle(DataModel dmodel) {
    var match = dmodel.categories.firstWhere(
      (element) => element.categoryId == categoryId,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    if (match.title.isEmpty) {
      return "Invalid";
    }
    return match.title;
  }
}
