import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/data/log_builder/log_builder.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/string_utils.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'dart:math' as math;

class GraphLine extends StatelessWidget {
  const GraphLine({
    super.key,
    required this.logBuilder,
    required this.data,
  });
  final LogBuilder logBuilder;
  final List<Tuple2<Object, num>> data;

  @override
  Widget build(BuildContext context) {
    _getInterval();
    if (data.isEmpty) {
      return Center(
        child: Text("No data found.", style: ttcaption(context)),
      );
    }
    return LineChart(
      LineChartData(
        maxY: data.reduce((a, b) => a.v2 > b.v2 ? a : b).v2 * 1.1,
        minY: data.reduce((a, b) => a.v2 < b.v2 ? a : b).v2 * 0.9,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipColor: (spot) => AppColors.cell(context),
            tooltipBorder: BorderSide(color: AppColors.divider(context)),
            getTooltipItems: (touchedSpots) {
              List<LineTooltipItem> items = [];
              if (touchedSpots.isEmpty) {
                return items;
              }
              items.add(
                LineTooltipItem(
                  logBuilder.titleBuilder(
                    context.read(),
                    Tuple2(
                      DateTime.fromMillisecondsSinceEpoch(
                        touchedSpots[0].x.round(),
                      ),
                      touchedSpots[0].y.toInt(),
                    ),
                  ),
                  ttcaption(context),
                ),
              );

              return items;
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
            sideTitles: SideTitles(
              showTitles: logBuilder.showXAxis,
              reservedSize: 20,
              interval: _getInterval(),
              getTitlesWidget: (value, meta) {
                if (meta.max == value || meta.min == value) {
                  return Container();
                }
                return Text(
                  formatDateTime(
                    DateTime.fromMillisecondsSinceEpoch(value.round()),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subtext(context),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          _getLineData(logBuilder.getColor(context), data),
        ],
      ),
      // swapAnimationCurve: Curves.easeInOutSine,
      // swapAnimationDuration: const Duration(milliseconds: 500),
    );
  }

  LineChartBarData _getLineData(Color color, List<Tuple2<Object, num>> data) {
    return LineChartBarData(
      spots: data.length == 1
          ? [
              // use two data points to show a line on a single data point
              FlSpot(
                (data[0].v1 as DateTime).millisecondsSinceEpoch.toDouble(),
                data[0].v2.toDouble(),
              ),
              FlSpot(
                (data[0].v1 as DateTime).millisecondsSinceEpoch.toDouble() + 1,
                data[0].v2.toDouble(),
              ),
            ]
          : [
              for (var i in data)
                FlSpot(
                  (i.v1 as DateTime).millisecondsSinceEpoch.toDouble(),
                  i.v2.toDouble(),
                ),
            ],
      barWidth: 3,
      color: color,
      isCurved: false,
      preventCurveOverShooting: false,
      curveSmoothness: 0.3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: true,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
            radius: 1,
            color: color,
            strokeWidth: 0,
          );
        },
      ),
      // belowBarData: BarAreaData(
      //   color: color.withOpacity(0.3),
      //   show: true,
      // ),
    );
  }

  double _getInterval() {
    var dates = data.map((e) => (e.v1 as DateTime).millisecondsSinceEpoch);
    var max =
        dates.reduce((value, element) => value > element ? value : element);
    var min =
        dates.reduce((value, element) => value < element ? value : element);
    var interval = (max - min) / 3;
    return math.max(1, interval);
  }
}
