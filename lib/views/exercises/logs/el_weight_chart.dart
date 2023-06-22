import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:fl_chart/fl_chart.dart';
import "package:workout_notepad_v2/utils/root.dart";

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
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Set ${elmodel.lineData!.accumulateType.name.capitalize()} By Date",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Clickable(
                  onTap: () {
                    switch (elmodel.pageSize) {
                      case 5:
                        elmodel.setPageSize(10);
                        break;
                      case 10:
                        elmodel.setPageSize(elmodel.lineData!.spots.length);
                        break;
                      default:
                        elmodel.setPageSize(5);
                        break;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5),
                    ),
                    height: 40,
                    width: 60,
                    child: Center(
                      child: Text(elmodel.pageSize.toString()),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Clickable(
                  onTap: () {
                    if (elmodel.lineData != null) {
                      setState(() {
                        elmodel.lineData!.toggleAccumulate(
                            elmodel.logs, elmodel.isLbs, elmodel.timeType);
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceVariant
                          .withOpacity(0.5),
                    ),
                    height: 40,
                    width: 60,
                    child: Center(
                      child: Text(
                          elmodel.lineData?.accumulateType.name.capitalize() ??
                              ""),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Clickable(
                    onTap: () {
                      elmodel.nextPage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.5),
                      ),
                      height: 40,
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.chevron_left_rounded),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Clickable(
                    onTap: () {
                      elmodel.wPrevPage();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (elmodel.lineData != null)
              Text(
                  "${elmodel.getLineDates().first} - ${elmodel.getLineDates().last}"),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  maxY: (elmodel.lineData?.setHigh ?? 0) +
                      ((elmodel.lineData?.setHigh ?? 0) * 0.15),
                  minY: (elmodel.lineData?.setLow ?? 0) +
                      ((elmodel.lineData?.setLow ?? 0) * -0.15),
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
                        List<String> dates = elmodel.getLineDates();
                        for (var i in touchedSpots) {
                          items.add(
                            LineTooltipItem(
                              "${i.y.toStringAsFixed(2)} ${elmodel.isLbs ? 'lbs' : 'kg'}\n${dates[i.spotIndex]}",
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
                        interval: elmodel.lineData == null
                            ? 1
                            : elmodel.lineData!.spots.length == 1
                                ? elmodel.lineData!.graphHigh
                                : (elmodel.lineData!.graphHigh -
                                        elmodel.lineData!.graphLow) /
                                    3,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "${value.round()} ${elmodel.isLbs ? 'lbs' : 'kg'}",
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
                      spots: elmodel.getLineData(),
                      barWidth: 5,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
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
