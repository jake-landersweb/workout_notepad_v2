import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_distribution.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_sets.dart';
import 'package:workout_notepad_v2/views/exercises/logs/el_tags.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ExerciseLogs extends StatefulWidget {
  const ExerciseLogs({
    super.key,
    required this.exerciseId,
    this.isInteractive = true,
  });
  final String exerciseId;
  final bool isInteractive;

  @override
  State<ExerciseLogs> createState() => _ExerciseLogsState();
}

class _ExerciseLogsState extends State<ExerciseLogs> {
  Exercise? _exercise;
  bool _error = false;

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    try {
      var db = await getDB();
      var resp = await db.rawQuery(
          "SELECT * FROM exercise WHERE exerciseId = '${widget.exerciseId}'");
      if (resp.isEmpty) {
        setState(() {
          _error = true;
        });
        return;
      }
      setState(() {
        _exercise = Exercise.fromJson(resp[0]);
      });
    } catch (e) {
      print(e);
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return const Center(
        child: Text("There was an error"),
      );
    }
    if (_exercise == null) {
      return const Center(
        child: comp.LoadingIndicator(),
      );
    }
    if (widget.isInteractive) {
      return ChangeNotifierProvider(
        create: ((context) => ELModel(exercise: _exercise!)),
        builder: ((context, child) {
          return Navigator(
            onGenerateRoute: (settings) {
              return MaterialWithModalsPageRoute(
                settings: settings,
                builder: (context) => _body(context),
              );
            },
          );
        }),
      );
    } else {
      return ChangeNotifierProvider(
        create: ((context) => ELModel(exercise: _exercise!)),
        builder: ((context, child) {
          return _body(context);
        }),
      );
    }
  }

  Widget _body(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    if (widget.isInteractive) {
      return comp.InteractiveSheet(
        headerPadding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        header: (context) {
          return SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          comp.CloseButton2(
                            useRoot: true,
                            color: AppColors.subtext(context),
                          ),
                        ],
                      ),
                      Text(
                        elmodel.exercise.title,
                        style: ttTitle(context, size: 24),
                      ),
                      const SizedBox(height: 8),
                      _navigation(context, elmodel),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        builder: (context) => _content(context, elmodel),
      );
    } else {
      return comp.HeaderBar.sheet(
        title: elmodel.exercise.title,
        canScroll: false,
        horizontalSpacing: 0,
        leading: const [comp.CloseButton2()],
        children: [
          const SizedBox(
            height: 60,
          ),
          Expanded(child: _content(context, elmodel)),
        ],
      );
    }
  }

  List<IconData> navItems = [
    Icons.dashboard_rounded,
    Icons.stacked_line_chart_rounded,
    Icons.bar_chart_rounded,
    Icons.pie_chart,
  ];

  Widget _navigation(BuildContext context, ELModel elmodel) {
    return Row(
      children: [
        for (int i = 0; i < navItems.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _navCell(context, i, navItems[i], elmodel),
          )
      ],
    );
  }

  Widget _navCell(
      BuildContext context, int index, IconData icon, ELModel elmodel) {
    return Clickable(
      onTap: () {
        elmodel.setPage(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(
          icon,
          color: index == elmodel.index
              ? AppColors.cell(context)
              : AppColors.subtext(context),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, ELModel elmodel) {
    return PageView(
      controller: elmodel.pageController,
      onPageChanged: (value) => elmodel.setIndex(value),
      children: elmodel.logs.isEmpty
          ? [
              // TODO!! MAKE BETTER
              const Center(
                child: Text("No Logs!"),
              )
            ]
          : [
              const ELOverview(),
              ELDistribution(exercise: elmodel.exercise),
              ELSets(exercise: elmodel.exercise),
              ELTags(exercise: elmodel.exercise),
            ],
    );
  }
}
