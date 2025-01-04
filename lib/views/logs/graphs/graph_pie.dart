import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_legend.dart';

class GraphPie extends StatelessWidget {
  const GraphPie({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();

    // fold sum for getting percentages
    var sum =
        data.map((v) => v.v2.toDouble()).reduce((item, val) => val + item);

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: [
                for (var i in data)
                  PieChartSectionData(
                    value: i.v2.toDouble(),
                    color: logBuilder.getColor(context, item: i),
                    radius: MediaQuery.of(context).size.width / 4,
                    title: i.v2.toDouble() / sum > 0.1
                        ? logBuilder.titleBuilder(dmodel, i)
                        : "", // only show titles that have a large enough percentage
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (logBuilder.showLegend)
          GraphLegend(logBuilder: logBuilder, data: data),
      ],
    );
  }
}
