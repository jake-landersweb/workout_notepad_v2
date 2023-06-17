import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:fl_chart/fl_chart.dart';

class ELWeightChart extends StatefulWidget {
  const ELWeightChart({super.key});

  @override
  State<ELWeightChart> createState() => _ELWeightChartState();
}

class _ELWeightChartState extends State<ELWeightChart> {
  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                sui.Button(
                  onTap: () {
                    elmodel.wNextPage();
                  },
                  child: Icon(Icons.chevron_left_rounded),
                ),
                const Spacer(),
                sui.Button(
                  onTap: () {
                    elmodel.wPrevPage();
                  },
                  child: Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  maxY: elmodel.wMax + (elmodel.wMax * 0.15),
                  minY: elmodel.wMin - (elmodel.wMin * 0.15),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.7),
                      getTooltipItems: (touchedSpots) {
                        List<LineTooltipItem> items = [];
                        List<String> dates = elmodel.wgetDates();
                        for (var i in touchedSpots) {
                          items.add(
                            LineTooltipItem(
                              "${i.y.round()} lbs\n${dates[i.spotIndex]}",
                              ttBody(
                                context,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          );
                        }
                        return items;
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: elmodel.wMax / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.round()} lbs",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: elmodel.wgetData(),
                      barWidth: 5,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.tertiary,
                        ],
                      ),
                      isCurved: false,
                      preventCurveOverShooting: true,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                            Theme.of(context)
                                .colorScheme
                                .tertiary
                                .withOpacity(0.3),
                          ],
                        ),
                        show: true,
                      ),
                    ),
                  ],
                ),
                swapAnimationCurve: Sprung(36),
                swapAnimationDuration: const Duration(milliseconds: 700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
