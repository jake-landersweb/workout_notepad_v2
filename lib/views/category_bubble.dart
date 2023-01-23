import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class CategoryBuble extends StatelessWidget {
  const CategoryBuble({
    super.key,
    required this.text,
  });
  final String text;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: dmodel.color[300],
        borderRadius: BorderRadius.circular(100),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 5),
        child: Text(
          text.uppercase(),
          style: ttBody(context, color: Colors.white),
        ),
      ),
    );
  }
}
