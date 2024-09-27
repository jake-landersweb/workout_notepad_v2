import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:workout_notepad_v2/components/contained_list.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/labeled_cell.dart';
import 'package:workout_notepad_v2/components/loading_indicator.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/root.dart';

import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/image.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/root.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:flutter_animate/flutter_animate.dart';

class ExerciseDetail extends StatefulWidget {
  const ExerciseDetail({
    super.key,
    this.exercise,
    this.exerciseId,
    this.showEdit = true,
  });
  final Exercise? exercise;
  final String? exerciseId;
  final bool showEdit;

  @override
  State<ExerciseDetail> createState() => _ExerciseDetailState();
}

class _ExerciseDetailState extends State<ExerciseDetail> {
  AppFile? _file;
  Exercise? _exercise;
  bool _loading = true;
  bool _err = false;

  @override
  void initState() {
    assert(widget.exercise != null || widget.exerciseId != null,
        "BOTH CANNOT BE NULL");
    if (widget.exercise != null) {
      _exercise = widget.exercise;
    }
    _init();
    super.initState();
    print("exerciseId: ${widget.exercise?.exerciseId}");
  }

  Future<void> _init() async {
    try {
      if (_exercise == null) {
        var db = await DatabaseProvider().database;
        var response = await db.rawQuery(
            "SELECT * FROM exercise WHERE exerciseId = ?", [widget.exerciseId]);
        if (response.isEmpty) {
          setState(() {
            _err = true;
          });
          return;
        }
        _exercise = Exercise.fromJson(response[0]);
      }
      setState(() {
        _loading = false;
      });
      if (_exercise!.filename?.isNotEmpty ?? false) {
        _file = await AppFile.fromFilename(filename: _exercise!.filename!);
        setState(() {});
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "exercise_detail_render"},
      );
      setState(() {
        _err = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return HeaderBar.sheet(
      // title: _exercise?.title ?? "Loading",
      title: "",
      crossAxisAlignment: CrossAxisAlignment.center,
      isFluid: false,
      itemSpacing: 16,
      horizontalSpacing: 0,
      leading: const [comp.CloseButton2()],
      trailing: [
        if (widget.showEdit)
          comp.EditButton(
            onTap: () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) => CEERoot(
                  isCreate: false,
                  exercise: widget.exercise,
                  onAction: (_) {
                    // close the detail screen
                    Navigator.of(context).pop();
                  },
                ),
              );
            },
          )
      ],
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_err) {
      return const Center(
        child: Text("There was an unknown issue"),
      );
    } else if (_loading) {
      return Center(
        child: LoadingIndicator(
          color: dmodel.color,
        ),
      );
    } else if (_exercise == null) {
      return const Center(
        child: Text("There was an unknown issue"),
      );
    } else {
      return _content(context, dmodel, _exercise!);
    }
  }

  Widget _content(BuildContext context, DataModel dmodel, Exercise e) {
    var category = dmodel.categories.firstWhere(
      (element) => element.categoryId == e.category,
      orElse: () => Category(categoryId: "", title: "", icon: ""),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(_exercise?.title ?? "",
                    style: ttTitle(context, size: 24)),
              )
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (e.difficulty.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context)[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                  child: Text(
                    e.difficulty,
                    style: ttcaption(context, color: dmodel.color),
                  ),
                ),
              ),
            ),
          ),
        if (_file != null && _file?.type != AppFileType.none)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 3,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _file!.getRenderer(),
              ),
            ),
          ),
        if (e.description.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(e.description, style: ttLabel(context)),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ExerciseItemGoup(exercise: e),
        )
            .animate(delay: (50 * 2).ms)
            .slideY(
                begin: 0.25,
                curve: Sprung(36),
                duration: const Duration(milliseconds: 500))
            .fadeIn(),
        const SizedBox(height: 16),
        if (e.category.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ContainedList<Widget>(
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                if (category.categoryId.isNotEmpty)
                  LabeledCell(
                    label: "Category",
                    child: Row(
                      children: [
                        getImageIcon(category.icon, size: 40),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            category.title.capitalize(),
                            style: ttLabel(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            )
                .animate(delay: (50 * 3).ms)
                .slideY(
                    begin: 0.25,
                    curve: Sprung(36),
                    duration: const Duration(milliseconds: 500))
                .fadeIn(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: WrappedButton(
            title: "View Logs",
            type: WrappedButtonType.main,
            icon: Icons.bar_chart_rounded,
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                enableDrag: true,
                builder: (context) => ExerciseLogs(exerciseId: e.exerciseId),
              );
            },
          ),
        ),
      ],
    );
  }
}
