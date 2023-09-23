import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

import 'package:workout_notepad_v2/text_themes.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return HeaderBar.sheet(
      title: "Welcome!",
      trailing: const [CancelButton(title: "Done")],
      children: [
        const SizedBox(height: 16),
        Text(
          "Welcome to Workout Notepad! This is a passion project of mine, I hope you enjoy it as much as I do.",
          style: ttLabel(context),
        ),
        const SizedBox(height: 4),
        Text("  - The Developer (Jake)", style: ttcaption(context)),
        const SizedBox(height: 16),
        Text(
          "The main philosophy behind this app is to give experienced users a seamless transition from pen and paper to an app.",
          style: ttLabel(context),
        ),
        const SizedBox(height: 16),
        Text(
          "The focus is to provide a great interface for inputting your exercise set data, then showing you that information in extremely cool ways.",
          style: ttLabel(context),
        ),
        const SizedBox(height: 16),
        Text(
          "You can think of workouts as playlists, and your exercises as songs. Compose your workout playlists dynamically as you workout, with default and custom exericses!",
          style: ttLabel(context),
        ),
        const SizedBox(height: 16),
        WrappedButton(
          title: "Begin!",
          type: WrappedButtonType.main,
          onTap: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
