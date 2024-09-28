import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class GraphPanel extends StatelessWidget {
  const GraphPanel({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              logBuilder.titleBuilder(context.read(), data.first,
                  includeValue: false),
              style: ttcaption(
                context,
                color: logBuilder.color,
              )),
          Text(
            logBuilder.formatValue(data.first.v2),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 52,
              color: logBuilder.color,
            ),
          ),
        ],
      ),
    );
  }
}
