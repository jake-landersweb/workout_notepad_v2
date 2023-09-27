import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';

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
      trailing: const [CancelButton(title: "Close")],
      horizontalSpacing: 0,
      children: [
        const SizedBox(height: 16),
        const PhoneAssetCarrossel(
          heightFactor: 0.7,
          assets: [
            "assets/images/RAW-dashboard.png",
            "assets/images/RAW-wedit.png",
            "assets/images/RAW-wlaunch.png",
            "assets/images/RAW-reps-graph.png",
          ],
          titles: [
            "Welcome to Workout Notepad! This is a passion project of mine, I hope you enjoy it as much as I do.",
            "Workouts are playlists! The exercises are songs. Compose them dynamically to fit your needs.",
            "Seamless but customizable input and tagging lets you track workouts the way you want to.",
            "Lastly, view advanced statistics on your logged exercises to tailor your future workouts better!",
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: WrappedButton(
            title: "Begin!",
            center: true,
            type: WrappedButtonType.main,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ],
    );
  }
}
