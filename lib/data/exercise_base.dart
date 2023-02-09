import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:sapphireui/sapphireui.dart' as sui;

abstract class ExerciseBase {
  late String title;
  late String category;
  late String description;
  late String icon;
  late int type;
  late int sets;
  late int reps;
  late int time;
  late String timePost;

  ExerciseBase({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.type,
    required this.sets,
    required this.reps,
    required this.time,
    required this.timePost,
  });

  // create a copy of sorts, mostly helpful for implementations
  // converting between each other
  ExerciseBase.fromSelf(ExerciseBase e) {
    title = e.title;
    category = e.category;
    description = e.description;
    icon = e.icon;
    type = e.type;
    sets = e.sets;
    reps = e.reps;
    time = e.time;
    timePost = e.timePost;
  }

  // for converting to json
  ExerciseBase.fromJson(dynamic json) {
    title = json['title'];
    category = json['category'];
    description = json['description'];
    icon = json['icon'];
    type = json['type'];
    sets = json['sets'];
    reps = json['reps'];
    time = json['time'];
    timePost = json['timePost'];
  }

  ExerciseBase.empty() {
    title = "";
    category = "";
    description = "";
    icon = "";
    type = 0;
    sets = 1;
    reps = 1;
    time = 0;
    timePost = "sec";
  }

  Image getIcon({double? size}) {
    return getImageIcon(icon, size: size);
  }

  // method implementations
  Future<int> insert();
  Future<int> update();
  Map<String, dynamic> toMap();

  // easy printing
  @override
  String toString() {
    return toMap().toString();
  }

  Widget info(
    BuildContext context, {
    TextStyle? style,
  }) {
    return RichText(text: infoRaw(context));
  }

  TextSpan infoRaw(
    BuildContext context, {
    TextStyle? style,
  }) {
    switch (type) {
      case 1:
        return TextSpan(
          text: "$sets x $time",
          style: style ?? ttBody(context),
          children: [
            TextSpan(
              text: timePost,
              style: TextStyle(
                fontWeight: style?.fontWeight ?? FontWeight.w500,
                fontSize: style?.fontSize ?? 16,
                color: style?.color?.withOpacity(0.5) ??
                    sui.CustomColors.textColor(context).withOpacity(0.5),
              ),
            ),
          ],
        );
      default:
        return TextSpan(
          text: "$sets x $reps",
          style: style ?? ttBody(context),
        );
    }
  }
}
