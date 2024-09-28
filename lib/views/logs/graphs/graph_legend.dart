import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class GraphLegend extends StatelessWidget {
  const GraphLegend({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 45),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(color: AppColors.text(context).withOpacity(0.1))),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i in data)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: logBuilder.getColor(context, item: i),
                        ),
                        height: 10,
                        width: 10,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        logBuilder.titleBuilder(dmodel, i, separator: " - "),
                        style: ttcaption(context, color: logBuilder.color),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
