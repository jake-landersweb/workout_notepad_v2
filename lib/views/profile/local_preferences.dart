import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/local_prefs.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class LocalPreferencesView extends StatefulWidget {
  const LocalPreferencesView({super.key});

  @override
  State<LocalPreferencesView> createState() => _LocalPreferencesViewState();
}

class _LocalPreferencesViewState extends State<LocalPreferencesView> {
  @override
  Widget build(BuildContext context) {
    var localPrefs = context.watch<LocalPrefs>();
    return Scaffold(
      body: HeaderBar(
        isLarge: true,
        title: "Local Settings",
        leading: [const BackButton2()],
        children: [
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              border: Border.all(color: AppColors.border(context), width: 3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _switchValue(
                  context,
                  localPrefs,
                  "Weight Unit",
                  ["lbs", "kg"],
                  localPrefs.defaultWeightPost,
                  (val) {
                    localPrefs.setDefaultWeightPost(val);
                  },
                ),
                // Container(
                //   color: AppColors.border(context),
                //   height: 2,
                //   width: double.infinity,
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchValue(
    BuildContext context,
    LocalPrefs localPrefs,
    String label,
    List<String> values,
    String initValue,
    Function(String) onSet,
  ) {
    return _wrapper(
      context,
      label,
      Expanded(
        flex: 1,
        child: SegmentedPicker<String>(
          titles: values,
          style: SegmentedPickerStyle(
            backgroundColor: AppColors.background(context),
          ),
          onSelection: (val) {
            onSet(val);
            snackbarStatus(context, "Succesfully saved.");
          },
          selection: initValue,
        ),
      ),
      flex: 2,
    );
  }

  Widget _boolValue(
    BuildContext context,
    LocalPrefs localPrefs,
    String label,
    bool initValue,
    Function(bool) onSet,
  ) {
    return _wrapper(
      context,
      label,
      Switch(value: initValue, onChanged: onSet),
    );
  }

  Widget _wrapper(
    BuildContext context,
    String label,
    Widget child, {
    int flex = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            flex: flex,
            child: Text(label, style: ttLabel(context)),
          ),
          child,
        ],
      ),
    );
  }
}
