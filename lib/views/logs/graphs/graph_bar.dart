import 'dart:math';

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:workout_notepad_v2/views/logs/graphs/graph_legend.dart';

class GraphBar extends StatelessWidget {
  const GraphBar({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();
    var maxY = data.reduce((a, b) => a.v2 > b.v2 ? a : b).v2 * 1.3;
    return Column(
      children: [
        Expanded(
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  tooltipBgColor: AppColors.cell(context),
                  tooltipBorder: BorderSide(color: AppColors.divider(context)),
                  getTooltipItem: (group, a, rod, b) {
                    return BarTooltipItem(
                      logBuilder.titleBuilder(
                        dmodel,
                        Tuple2(data[group.x].v1, rod.toY),
                      ),
                      const TextStyle(),
                    );
                  },
                ),
              ),
              maxY: maxY,
              barGroups: data
                  .mapIndexed(
                    (index, element) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          borderRadius: BorderRadius.circular(10),
                          toY: element.v2.toDouble(),
                          width: min(
                              (MediaQuery.of(context).size.width /
                                      data.length) -
                                  ((32 + 100) / data.length),
                              70),
                          // color: Theme.of(context).colorScheme.primary,
                          color: logBuilder.getColor(context, item: element),
                        ),
                      ],
                    ),
                  )
                  .toList(),
              titlesData: FlTitlesData(
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: logBuilder.showYAxis,
                    reservedSize: 50,
                    getTitlesWidget: (value, meta) {
                      if (meta.max == value || meta.min == value) {
                        return Container();
                      }
                      return Text(
                        logBuilder.formatValue(value),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subtext(context),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
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
