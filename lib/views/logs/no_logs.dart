import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class NoLogs extends StatelessWidget {
  const NoLogs({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Oh No!", style: ttTitle(context)),
        Text(
          "You do not have enough logged exercises to show anything useful here yet. Use the app, get your workouts in, then come back later!",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 2,
          ),
          child: SvgPicture.asset(
            "assets/svg/graph2.svg",
            semanticsLabel: 'Empty Screen',
          ),
        ),
      ],
    );
  }
}
