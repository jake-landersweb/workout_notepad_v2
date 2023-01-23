import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sapphireui/sapphireui.dart' as sui;
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/data/workout.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/icon_picker.dart';
import 'package:workout_notepad_v2/views/root.dart';

class CEWRoot extends StatefulWidget {
  const CEWRoot({
    super.key,
    required this.isCreate,
    this.workout,
    this.onCreate,
    this.onUpdate,
    this.useRoot = true,
  });
  final bool isCreate;
  final Workout? workout;
  final VoidCallback? onCreate;
  final VoidCallback? onUpdate;
  final bool useRoot;

  @override
  State<CEWRoot> createState() => _CEWRootState();
}

class _CEWRootState extends State<CEWRoot> {
  @override
  void initState() {
    if (widget.isCreate && widget.onCreate == null) {
      throw "If [isCreate] is true, [onCreate] cannot be null";
    }
    if (!widget.isCreate &&
        (widget.onUpdate == null || widget.workout == null)) {
      throw "If [isCreate] is false, [onUpdate, workout] cannot be null";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => widget.isCreate
          ? CEWModel.create()
          : CEWModel.update(widget.workout!),
      builder: (context, _) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var cmodel = Provider.of<CEWModel>(context);
    return sui.AppBar.sheet(
      title: "Create Workout",
      isFluid: true,
      itemSpacing: 16,
      crossAxisAlignment: CrossAxisAlignment.center,
      leading: [comp.CloseButton(useRoot: widget.useRoot)],
      children: [
        _icon(context, cmodel),
        _title(context, cmodel),
      ],
    );
  }

  Widget _icon(BuildContext context, CEWModel cmodel) {
    return sui.Button(
      onTap: () => showIconPicker(
          context: context,
          initialIcon: cmodel.icon,
          closeOnSelection: true,
          onSelection: (icon) {
            setState(() {
              cmodel.icon = icon;
            });
          }),
      child: Column(
        children: [
          getImageIcon(cmodel.icon, size: 100),
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

  Widget _title(BuildContext context, CEWModel cmodel) {
    return sui.ListView<Widget>(
      childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      backgroundColor: sui.CustomColors.textColor(context).withOpacity(0.1),
      horizontalPadding: 0,
      children: [
        sui.TextField(
          labelText: "Title",
          hintText: "Title (ex. Arm Day)",
          charLimit: 40,
          value: cmodel.title,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cmodel.title = val;
            });
          },
        ),
        sui.TextField(
          labelText: "Description",
          charLimit: 100,
          value: cmodel.description,
          showCharacters: true,
          onChanged: (val) {
            setState(() {
              cmodel.description = val;
            });
          },
        ),
      ],
    );
  }
}
