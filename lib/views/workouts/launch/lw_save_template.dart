import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/field.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/workouts/launch/lw_model.dart';

class LWSaveAsTemplate extends StatefulWidget {
  const LWSaveAsTemplate({
    super.key,
    required this.initTitle,
  });
  final String initTitle;

  @override
  State<LWSaveAsTemplate> createState() => _LWSaveAsTemplateState();
}

class _LWSaveAsTemplateState extends State<LWSaveAsTemplate> {
  String title = "";
  bool isLoading = false;

  @override
  void initState() {
    title = widget.initTitle;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var lmodel = Provider.of<LaunchWorkoutModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Spacer(),
              comp.CloseButton2(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
            child: Field(
              fieldPadding: const EdgeInsets.symmetric(horizontal: 16),
              showBackground: false,
              charLimit: 50,
              value: title,
              highlightColor: dmodel.color,
              hasClearButton: true,
              textCapitalization: TextCapitalization.words,
              labelText: "Title",
              onChanged: (val) {
                setState(() {
                  title = val;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: WrappedButton(
                  title: "Cancel",
                  center: true,
                  type: WrappedButtonType.standard,
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: WrappedButton(
                  title: "Save",
                  center: true,
                  isLoading: isLoading,
                  type: WrappedButtonType.main,
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });
                    var res = await lmodel.saveWorkoutAsTemplate(title);
                    Navigator.of(context).pop();
                    if (res) {
                      snackbarStatus(context, "Successfully saved!");
                    } else {
                      snackbarErr(context, "There was an issue.");
                    }
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
