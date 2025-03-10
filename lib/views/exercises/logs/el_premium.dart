import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

class ELPremiumOverlay extends StatelessWidget {
  const ELPremiumOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlurredContainer(
      backgroundColor: AppColors.background(context),
      blur: 10,
      borderRadius: BorderRadius.circular(0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Looking for more logging capabilities?",
                style: ttTitle(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              WrappedButton(
                title: "Explore Premium",
                icon: Icons.star,
                iconBg: Colors.amber[700],
                onTap: () {
                  showPaywall(context);
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }
}
