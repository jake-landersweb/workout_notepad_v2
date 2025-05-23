import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class GraphTable extends StatelessWidget {
  const GraphTable({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();
    return Column(
      children: [
        Divider(color: AppColors.border(context)),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: data.sorted((a, b) => b.v2.compareTo(a.v2)).mapIndexed(
                (index, element) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                logBuilder.titleBuilder(
                                  dmodel,
                                  element,
                                  includeValue: false,
                                ),
                                style:
                                    ttLabel(context, color: logBuilder.color),
                              ),
                            ),
                            Text(
                              logBuilder.formatValue(element.v2),
                              style:
                                  ttcaption(context, color: logBuilder.color),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: AppColors.divider(context)),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
