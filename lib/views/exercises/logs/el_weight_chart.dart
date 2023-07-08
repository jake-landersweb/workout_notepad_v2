import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
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
    return ChangeNotifierProvider(
      create: ((context) => LineDataModel(elmodel: elmodel)),
      builder: (context, _) => _body(context, elmodel),
    );
  }

  Widget _body(BuildContext context, ELModel elmodel) {
    var lmodel = Provider.of<LineDataModel>(context);
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
                const Text(
                  "Set ",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Clickable(
                  onTap: () {
                    lmodel.toggleAccumulate();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        lmodel.accumulateType.name.capitalize(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const Expanded(
                  child: Text(
                    " By Date",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (lmodel.dates.isNotEmpty)
              Text("${lmodel.dates.last} - ${lmodel.dates.first}"),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  maxY: lmodel.high.isInfinite ? 100 : lmodel.high * 1.05,
                  minY: lmodel.low.isInfinite ? 10 : lmodel.low * 0.95,
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
                        for (var i in touchedSpots) {
                          items.add(
                            LineTooltipItem(
                              lmodel.tooltip(elmodel, i.y, i.spotIndex),
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
                        interval:
                            (elmodel.logs.length < 2) ? 10 : lmodel.high / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            lmodel.barY(elmodel, value),
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
                  lineBarsData: [
                    LineChartBarData(
                      spots: lmodel.getItems(elmodel),
                      barWidth: 5,
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.7),
                      isCurved: false,
                      preventCurveOverShooting: true,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.3),
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
