import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/account/accountButton.dart';
import 'package:workout_notepad_v2/views/account/create_account.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class AnonCreateAccount extends StatefulWidget {
  const AnonCreateAccount({super.key});

  @override
  State<AnonCreateAccount> createState() => _AnonCreateAccountState();
}

class _AnonCreateAccountState extends State<AnonCreateAccount> {
  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      title: "",
      children: [
        Text("Oh no! Your anonymous trial is up.", style: ttTitle(context)),
        Text(
          "Create a full account to continue where you left off.",
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
            cupertinoSheet(
              context: context,
              builder: (context) => const CreateAccount(),
            );
          },
        ),
      ],
    );
  }
}
