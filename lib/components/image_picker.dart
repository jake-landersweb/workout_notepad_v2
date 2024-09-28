import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

class ImgagePicker extends StatefulWidget {
  const ImgagePicker({
    super.key,
    this.initialUrl,
  });
  final String? initialUrl;

  @override
  State<ImgagePicker> createState() => _ImgagePickerState();
}

class _ImgagePickerState extends State<ImgagePicker> {
  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {},
      child: Container(),
    );
  }
}
