import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELBarChart extends StatefulWidget {
  const ELBarChart({super.key});

  @override
  State<ELBarChart> createState() => _ELBarChartState();
}

class _ELBarChartState extends State<ELBarChart> {
  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    return SafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            Row(
              children: [
                if (elmodel.exercise.type == 0)
                  Clickable(
                    onTap: () {
                      elmodel.toggleDistributionBarType();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          elmodel.getBarTitle(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                Expanded(
                  child: Text(
                    "${elmodel.exercise.type == 0 ? '' : 'Time'} Distribution By Set",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // legend
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _legendItem(
                  context,
                  "Low",
                  Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 4),
                _legendItem(
                  context,
                  "Avg",
                  Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 4),
                _legendItem(
                  context,
                  "High",
                  Theme.of(context).colorScheme.tertiary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // graph
            Expanded(
              child: BarChart(
                swapAnimationCurve: Sprung(36),
                swapAnimationDuration: const Duration(milliseconds: 700),
                BarChartData(
                  barGroups: elmodel.barData.getBarData(context),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.7),
                      getTooltipItem: (group, a, rod, b) {
                        return BarTooltipItem(
                          "${rod.toY.toStringAsFixed(2)} ${elmodel.getDistributionPost()}",
                          const TextStyle(),
                        );
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
                        interval: elmodel.lineData == null
                            ? 1
                            : max(
                                elmodel.lineData!.spots.length == 1
                                    ? elmodel.lineData!.graphHigh
                                    : (elmodel.lineData!.graphHigh -
                                            elmodel.lineData!.graphLow) /
                                        3,
                                1),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.round()} ${elmodel.getDistributionPost()}",
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
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "Set #${value.round() + 1}",
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(BuildContext context, String title, Color color) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
          height: 30,
          width: 30,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
