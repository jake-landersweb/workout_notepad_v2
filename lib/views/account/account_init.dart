// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/anon_account.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class AccountInit extends StatefulWidget {
  const AccountInit({super.key});

  @override
  State<AccountInit> createState() => _AccountInitState();
}

class _AccountInitState extends State<AccountInit> {
  @override
  Widget build(BuildContext context) {
    return comp.HeaderBar(
      children: [
        Text("Welcome to Workout Notepad.", style: ttTitle(context)),
        Text(
          "The Uncomplicated Route to Fitness Planning and Tracking.",
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
            "assets/svg/workout.svg",
            semanticsLabel: 'Workout Logo',
          ),
        ),
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
        const SizedBox(height: 8),
        AccountButton(
          title: "Try Anonymously",
          bg: AppColors.cell(context),
          fg: AppColors.subtext(context),
          onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => const AnonAccount(),
            );
          },
        ),
        const SizedBox(height: 16),
        comp.Clickable(
          onTap: () {
            comp.cupertinoSheet(
              context: context,
              builder: (context) => const Login(),
            );
          },
          child: Text(
            "Login",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.subtext(context),
            ),
          ),
        )
      ],
    );
  }
}

bool emailIsValid(String email) {
  final validEmail = RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$");
  return validEmail.hasMatch(email);
}
