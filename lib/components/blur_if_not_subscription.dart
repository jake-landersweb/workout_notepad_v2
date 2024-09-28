import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

class BlurIfNotSubscription extends StatelessWidget {
  const BlurIfNotSubscription({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = context.read();
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (!dmodel.hasValidSubscription())
          Container(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
        if (!dmodel.hasValidSubscription())
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Looking for more features?",
                  style: ttTitle(context),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: WrappedButton(
                    title: "Explore Premium",
                    icon: Icons.star,
                    iconBg: Colors.amber[700],
                    backgroundColor: Colors.amber[700],
                    fg: Colors.white,
                    borderColor: Colors.amber[800],
                    onTap: () {
                      cupertinoSheet(
                        context: context,
                        builder: (context) => const Subscriptions(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
