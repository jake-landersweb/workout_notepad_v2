import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/floating_sheet.dart';

class LWTags extends StatefulWidget {
  const LWTags({super.key});

  @override
  State<LWTags> createState() => _LWTagsState();
}

class _LWTagsState extends State<LWTags> {
  @override
  Widget build(BuildContext context) {
    return FloatingSheet(title: "Create Tag", child: Container());
  }
}
