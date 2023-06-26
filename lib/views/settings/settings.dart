import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:material_color_utilities/scheme/scheme.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/color_schemes.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/dynamicgv.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/color.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Settings",
      isLarge: true,
      children: [
        const SizedBox(height: 16),
        _selectColor(context, dmodel),
        const SizedBox(height: 16),
        comp.LabeledWidget(
          label: "",
          child: Clickable(
            onTap: () {
              dmodel.exportToJSON();
            },
            child: Text("Export"),
          ),
        ),
      ],
    );
  }

  Widget _selectColor(BuildContext context, DataModel dmodel) {
    return comp.LabeledWidget(
      label: "Color",
      child: DynamicGridView(
        itemCount: appColors.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        builder: (context, index) {
          return _cell(context, dmodel, appColors[index]);
        },
      ),
    );
  }

  Widget _cell(BuildContext context, DataModel dmodel, Color color) {
    final CorePalette pallete = CorePalette.of(color.value);
    final Scheme lightScheme = Scheme.lightFromCorePalette(pallete);
    final Scheme darkScheme = Scheme.darkFromCorePalette(pallete);
    return Clickable(
      onTap: () => dmodel.setColor(color),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: double.infinity,
              child: AspectRatio(
                aspectRatio: 1,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        width: double.infinity,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Color(lightScheme.primary)
                            : Color(darkScheme.primary),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Color(lightScheme.tertiary)
                            : Color(darkScheme.tertiary),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.light
                            ? Color(lightScheme.surfaceVariant)
                            : Color(darkScheme.surfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (dmodel.color == color)
            Container(
              height: MediaQuery.of(context).size.width / 10,
              width: MediaQuery.of(context).size.width / 10,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
        ],
      ),
    );
  }
}
