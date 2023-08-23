import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_premium.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

enum ELDistributionType { weight, reps, time }

class ELDistribution extends StatefulWidget {
  const ELDistribution({
    super.key,
    required this.exercise,
  });
  final Exercise exercise;

  @override
  State<ELDistribution> createState() => _ELDistributionState();
}

class _ELDistributionState extends State<ELDistribution> {
  late ELDistributionType _type;
  bool _isLoading = false;
  final List<Tuple2<DateTime, num>> _maxData = [];
  final List<Tuple2<DateTime, num>> _minData = [];
  final List<Tuple2<DateTime, num>> _avgData = [];
  bool _isLbs = true;
  bool _hasError = false;

  @override
  void initState() {
    switch (widget.exercise.type) {
      case ExerciseType.weight:
        _type = ELDistributionType.weight;
        break;
      case ExerciseType.timed:
      case ExerciseType.duration:
      case ExerciseType.bw:
        _type = ELDistributionType.reps;
        break;
    }
    _fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (_isLoading) {
      return LoadingIndicator(
        color: Theme.of(context).colorScheme.primary,
      );
    }
    if (_hasError) {
      return Text("There was an error");
    }
    if (_maxData.isEmpty || _minData.isEmpty || _avgData.isEmpty) {
      return Text("No Data"); // TODO -- PRETTY
    } else {
      return Stack(
        children: [
          SafeArea(
            top: false,
            left: false,
            right: false,
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      _toggleButton(context),
                      Expanded(
                        child: Text(
                          " Distribution By Workout",
                          style: ttLabel(context, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _legend(context),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        maxY:
                            _maxData.reduce((a, b) => a.v2 > b.v2 ? a : b).v2 *
                                1.2,
                        minY: 0,
                        gridData: FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            tooltipBgColor: AppColors.cell(context),
                            getTooltipItems: (touchedSpots) {
                              List<LineTooltipItem> items = [];
                              items.add(
                                LineTooltipItem(
                                  formatDateTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                      touchedSpots[0].x.round(),
                                    ),
                                  ),
                                  ttcaption(context),
                                ),
                              );
                              for (var i in touchedSpots) {
                                items.add(
                                  LineTooltipItem(
                                    "${_getTitleFromIndex(i.barIndex)}: ${_getHoverTitle(i.y)}",
                                    ttBody(
                                      context,
                                      color: i.bar.color,
                                    ),
                                  ),
                                );
                              }

                              return items;
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              getTitlesWidget: (value, meta) {
                                if (meta.max == value || meta.min == value) {
                                  return Container();
                                }
                                return Text(
                                  _getHoverTitle(value),
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
                        lineBarsData: [
                          _getLineData(Colors.red[300]!, _maxData),
                          _getLineData(Colors.green[300]!, _avgData),
                          _getLineData(Colors.blue[300]!, _minData),
                        ],
                      ),
                      swapAnimationCurve: Curves.easeInOutSine,
                      swapAnimationDuration: const Duration(milliseconds: 500),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (dmodel.user!.subscriptionType == SubscriptionType.none)
            const ELPremiumOverlay(),
        ],
      );
    }
  }

  Widget _legend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _legendItem(context, Colors.red[300]!, "max"),
        _legendItem(context, Colors.green[300]!, "avg"),
        _legendItem(context, Colors.blue[300]!, "min"),
      ],
    );
  }

  Widget _legendItem(BuildContext context, Color color, String title) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            height: 30,
            width: 30,
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: ttcaption(context),
          ),
        ],
      ),
    );
  }

  String _getHoverTitle(double val) {
    switch (widget.exercise.type) {
      case ExerciseType.bw:
      case ExerciseType.weight:
        return val.toStringAsFixed(2);
      case ExerciseType.timed:
      case ExerciseType.duration:
        switch (_type) {
          case ELDistributionType.weight:
            return formatHHMMSS(val.round());
          case ELDistributionType.reps:
            return val.toStringAsFixed(2);
          case ELDistributionType.time:
            return formatHHMMSS(val.round());
        }
    }
  }

  Widget _toggleButton(BuildContext context) {
    String title;
    switch (_type) {
      case ELDistributionType.reps:
        title = "Reps";
        break;
      case ELDistributionType.weight:
        title = "Weight";
        break;
      case ELDistributionType.time:
        title = "Time";
        break;
    }
    return Clickable(
      onTap: () async {
        switch (_type) {
          case ELDistributionType.weight:
            _type = ELDistributionType.reps;
            break;
          case ELDistributionType.reps:
            switch (widget.exercise.type) {
              case ExerciseType.weight:
                _type = ELDistributionType.weight;
                break;
              case ExerciseType.timed:
              case ExerciseType.duration:
                _type = ELDistributionType.time;
                break;
              case ExerciseType.bw:
                break;
            }
            break;
          case ELDistributionType.time:
            _type = ELDistributionType.reps;
        }
        await _fetchData();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
          child: Text(
            title,
            style: ttLabel(
              context,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _getTitleFromIndex(int i) {
    switch (i) {
      case 0:
        return "Max";
      case 1:
        return "Avg";
      case 2:
        return "Min";
      default:
        return "";
    }
  }

  LineChartBarData _getLineData(Color color, List<Tuple2<DateTime, num>> data) {
    return LineChartBarData(
      spots: [
        for (var i in data)
          FlSpot(
            i.v1.millisecondsSinceEpoch.toDouble(),
            i.v2.toDouble(),
          ),
      ],
      barWidth: 5,
      color: color,
      isCurved: true,
      preventCurveOverShooting: true,
      curveSmoothness: 0.3,
      isStrokeCapRound: false,
      dotData: FlDotData(
        show: true,
        getDotPainter: (p0, p1, p2, p3) {
          return FlDotCirclePainter(
            radius: 6,
            color: color,
            strokeWidth: 0,
          );
        },
      ),
      belowBarData: BarAreaData(
        color: color.withOpacity(0.3),
        show: true,
      ),
    );
  }

  Future<void> _fetchData() async {
    _isLoading = true;
    _maxData.clear();
    _avgData.clear();
    _minData.clear();
    try {
      var db = await getDB();
      var response = await db.rawQuery("""
      SELECT 
          el.created,
          el.exerciseLogId,
          MAX($_maxQueryCase) AS max_val,
          AVG($_maxQueryCase) AS avg_val,
          MIN($_maxQueryCase) AS min_val
      FROM exercise_log AS el
      JOIN exercise_log_meta AS elm
      ON el.exerciseLogId = elm.exerciseLogId
      WHERE el.exerciseId = '${widget.exercise.exerciseId}'
      GROUP BY el.exerciseLogId
      ORDER BY el.created
    """);
      for (var i in response) {
        var d = DateTime.parse(i['created'] as String);
        _maxData.add(
          Tuple2(d, i['max_val'] as num),
        );
        _avgData.add(
          Tuple2(d, i['avg_val'] as num),
        );
        _minData.add(
          Tuple2(d, i['min_val'] as num),
        );
      }
    } catch (e) {
      print(e);
      _hasError = true;
    }
    setState(() {
      _isLoading = false;
    });
  }

  String get _maxQueryCase {
    switch (_type) {
      case ELDistributionType.weight:
        if (_isLbs) {
          return """
            CASE 
              WHEN elm.weightPost = 'kg' THEN elm.weight * 2.204
              ELSE elm.weight 
            END
          """;
        } else {
          return """
            CASE 
              WHEN elm.weightPost = 'lbs' THEN elm.weight / 2.204
              ELSE elm.weight 
            END
          """;
        }
      case ELDistributionType.reps:
        return "elm.reps";
      case ELDistributionType.time:
        return "elm.time";
    }
  }
}
