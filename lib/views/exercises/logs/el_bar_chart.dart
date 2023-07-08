
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
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
    return ChangeNotifierProvider(
      create: ((context) => BarDataModel(elmodel: elmodel)),
      builder: (context, _) => _body(context, elmodel),
    );
  }

  Widget _body(BuildContext context, ELModel elmodel) {
    var bmodel = Provider.of<BarDataModel>(context);
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
                if (elmodel.exercise.type == ExerciseType.weight)
                  Clickable(
                    onTap: () {
                      bmodel.toggleType(elmodel);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          bmodel.titleButton,
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
                    "${bmodel.titleType(elmodel)} Distribution By Set",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // legend
            const Text(
              "Low,Avg,High",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            // graph
            Expanded(
              child: BarChart(
                swapAnimationCurve: Curves.easeInOut,
                swapAnimationDuration: const Duration(milliseconds: 700),
                BarChartData(
                  barGroups: bmodel.getBarData(context, elmodel),
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
                          bmodel.tooltip(elmodel, rod.toY, a, b),
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
                        interval: bmodel.high / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            bmodel.barY(elmodel, value),
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
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            "Set #${value.round() + 1}",
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.subtext(context),
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
}
