import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

class Support extends StatefulWidget {
  const Support({super.key});

  @override
  State<Support> createState() => _SupportState();
}

class _SupportState extends State<Support> {
  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Support",
      leading: const [CancelButton()],
      children: [],
    );
  }
}
