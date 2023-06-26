import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
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
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              getIcon(dmodel),
              Text(
                title.capitalize(),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getIcon(DataModel dmodel) {
    var match = dmodel.categories.firstWhere(
      (element) => element.title == title,
      orElse: () => Category(title: "", userId: "", icon: ""),
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
