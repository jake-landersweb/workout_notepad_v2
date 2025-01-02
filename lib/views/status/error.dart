import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_notepad_v2/text_themes.dart';

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height / 3,
          ),
          child: SvgPicture.asset(
            "assets/svg/error.svg",
            semanticsLabel: 'List Graph',
          ),
        ),
        const SizedBox(height: 32),
        Center(
          child: Text(
            title,
            style: ttLabel(context),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
