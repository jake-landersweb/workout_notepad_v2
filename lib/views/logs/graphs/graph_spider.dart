import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

class GraphSpider extends StatelessWidget {
  const GraphSpider({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    if (data.length < 3) {
      return Center(
        child: Text(
          "Not enough data for this graph type",
          style: ttcaption(context),
        ),
      );
    }
    var dmodel = context.watch<DataModel>();
    return RadarChart(
      RadarChartData(
        tickBorderData: BorderSide.none,
        gridBorderData: BorderSide.none,
        radarBorderData: BorderSide.none,
        titlePositionPercentageOffset: 0,
        borderData: FlBorderData(
          show: false,
        ),
        tickCount: 1,
        radarShape: RadarShape.circle,
        ticksTextStyle:
            const TextStyle(color: Colors.transparent, fontSize: 10),
        dataSets: [
          RadarDataSet(
            fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            borderColor: Theme.of(context).colorScheme.primary,
            dataEntries: [
              for (var i in data) RadarEntry(value: i.v2.toDouble()),
            ],
          ),
        ],
        getTitle: (index, angle) {
          return RadarChartTitle(
            text: logBuilder.titleBuilder(dmodel, data[index]),
            angle: angle < 270 && angle > 90 ? angle - 180 : angle,
          );
        },
      ),
      swapAnimationDuration: const Duration(milliseconds: 150), // Optional
      swapAnimationCurve: Curves.linear, // Optional
    );
  }
}
