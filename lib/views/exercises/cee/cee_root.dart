import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/exercise.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/exercises/cee/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';

class CEERoot extends StatefulWidget {
  const CEERoot({
    super.key,
    required this.isCreate,
    this.onAction,
    this.exercise,
    this.runPostAction = true,
  });
  final bool isCreate;
  final Exercise? exercise;
  final Function(Exercise e)? onAction;
  final bool runPostAction;

  @override
  State<CEERoot> createState() => _CEERootState();
}

class _CEERootState extends State<CEERoot> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider(
      create: (context) => widget.isCreate
          ? CreateExerciseModel.create(dmodel, dmodel.user!.userId)
          : CreateExerciseModel.update(dmodel, widget.exercise!),
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cemodel = Provider.of<CreateExerciseModel>(context);
    return sui.AppBar.sheet(
      title: widget.isCreate ? "Create Exercise" : "Update Exercise",
      isFluid: true,
      itemSpacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      leading: const [comp.CloseButton()],
      trailing: [
        comp.ModelCreateButton(
          title: widget.isCreate ? "Create" : "Edit",
          isValid: cemodel.isValid(),
          onTap: () async {
            if (widget.runPostAction) {
              Exercise? response = await cemodel.post(dmodel, !widget.isCreate);
              if (response != null) {
                if (widget.runPostAction) {
                  await dmodel.refreshExercises();
                  await dmodel.refreshCategories();
                }
                if (widget.onAction != null) {
                  widget.onAction!(cemodel.exercise);
                }
              }
              Navigator.of(context).pop();
            } else {
              widget.onAction!(cemodel.exercise);
            }
          },
        )
      ],
      horizontalSpacing: 0,
      children: [
        _icon(context, cemodel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _title(context, cemodel),
        ),
        _category(context, cemodel, dmodel),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _sets(context, cemodel),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _reps(context, cemodel),
        ),
      ],
    );
  }

  Widget _icon(BuildContext context, CreateExerciseModel cemodel) {
    return sui.Button(
      onTap: () => showIconPicker(
          context: context,
          initialIcon: cemodel.exercise.icon,
          closeOnSelection: true,
          onSelection: (icon) {
            setState(() {
              cemodel.exercise.icon = icon;
            });
          }),
      child: Column(
        children: [
          getImageIcon(cemodel.exercise.icon, size: 100),
          Text(
            "Edit",
            style: TextStyle(
                fontSize: 12,
                color: sui.CustomColors.textColor(context).withOpacity(0.3),
                fontWeight: FontWeight.w300),
          ),
        ],
      ),
    );
  }

  Widget _title(BuildContext context, CreateExerciseModel cemodel) {
    return sui.ListView<Widget>(
      childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      backgroundColor: sui.CustomColors.textColor(context).withOpacity(0.1),
      leadingPadding: 0,
      trailingPadding: 0,
      children: [
        sui.TextField(
          labelText: "Title",
          hintText: "Title (ex. Bicep Curls)",
          charLimit: 40,
          value: cemodel.exercise.title,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cemodel.exercise.title = val;
            });
          },
        ),
        sui.TextField(
          labelText: "Description",
          charLimit: 100,
          value: cemodel.exercise.description,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cemodel.exercise.description = val;
            });
          },
        ),
      ],
    );
  }

  Widget _category(
      BuildContext context, CreateExerciseModel cemodel, DataModel dmodel) {
    return SingleChildScrollView(
      key: const ValueKey("Category Key"),
      scrollDirection: Axis.horizontal,
      controller: ScrollController(),
      physics: const AlwaysScrollableScrollPhysics()
          .applyTo(const BouncingScrollPhysics()),
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: Row(
          children: [
            const SizedBox(width: 16),
            sui.Button(
              onTap: () {
                comp.cupertinoSheet(
                  context: context,
                  builder: (context) => CreateCategory(
                      categories: cemodel.categories,
                      onCompletion: (val) {
                        setState(() {
                          cemodel.categories.insert(0, val);
                          cemodel.exercise.category = val;
                        });
                      }),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: sui.CustomColors.textColor(context).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Icon(LineIcons.plus,
                      color: sui.CustomColors.textColor(context), size: 20),
                ),
              ),
            ),
            const SizedBox(width: 8),
            for (int i = 0; i < cemodel.categories.length; i++)
              Padding(
                padding: EdgeInsets.only(
                    right: i < cemodel.categories.length ? 8 : 0),
                child: _categoryCell(context, cemodel.categories[i], cemodel),
              ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _categoryCell(
      BuildContext context, String title, CreateExerciseModel cemodel) {
    return sui.Button(
      onTap: () {
        setState(() {
          cemodel.exercise.category = title;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: title == cemodel.exercise.category
              ? Theme.of(context).primaryColor
              : sui.CustomColors.textColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            title.uppercase(),
            style: TextStyle(
              color: title == cemodel.exercise.category
                  ? Colors.white
                  : sui.CustomColors.textColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sets(BuildContext context, CreateExerciseModel cemodel) {
    return comp.LabeledWidget(
      label: "Sets",
      child: comp.NumberPicker(
        minValue: 0,
        intialValue: cemodel.exercise.sets,
        onChanged: (val) {
          cemodel.exercise.sets = val;
        },
      ),
    );
  }

  Widget _reps(BuildContext context, CreateExerciseModel cemodel) {
    return comp.LabeledWidget(
      label: "Reps",
      child: comp.NumberPicker(
        minValue: 0,
        intialValue: cemodel.exercise.reps,
        onChanged: (val) {
          cemodel.exercise.reps = val;
        },
      ),
    );
  }
}
