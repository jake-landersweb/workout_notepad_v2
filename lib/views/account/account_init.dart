// ignore_for_file: avoid_print
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/login_new.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/account/signin_with.dart';

class AccountInit extends StatefulWidget {
  const AccountInit({super.key});

  @override
  State<AccountInit> createState() => _AccountInitState();
}

class _AccountInitState extends State<AccountInit> {
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    return comp.HeaderBar(
      forceNoBar: true,
      children: [
        Text("Welcome to Workout Notepad.", style: ttTitle(context)),
        Text(
          "The Uncomplicated Route to Fitness Planning and Tracking.",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        GestureDetector(
          onLongPressStart: (details) {
            _timer = Timer(const Duration(seconds: 3), () {
              comp.cupertinoSheet(
                context: context,
                builder: (context) => const LoginOld(),
              );
            });
          },
          onLongPressEnd: (details) {
            _timer?.cancel();
          },
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height / 2,
            ),
            child: SvgPicture.asset(
              "assets/svg/workout.svg",
              semanticsLabel: 'Workout Logo',
            ),
          ),
        ),
        SingInWith(),
        const SizedBox(height: 16),
        AccountButton(
          title: "Create Account",
          bg: Theme.of(context).colorScheme.primary,
          fg: AppColors.cell(context),
          onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => const CreateAccount(),
            );
          },
        ),
        const SizedBox(height: 16),
        comp.Clickable(
          onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => const LoginNew(),
            );
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.subtext(context),
            ),
          ),
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}

bool emailIsValid(String email) {
  final validEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return validEmail.hasMatch(email);
}
