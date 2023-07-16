import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class AnonAccount extends StatefulWidget {
  const AnonAccount({super.key});

  @override
  State<AnonAccount> createState() => _AnonAccountState();
}

class _AnonAccountState extends State<AnonAccount> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return comp.HeaderBar.sheet(
      title: "",
      leading: const [comp.CloseButton2()],
      children: [
        Text("Anon Mode:", style: ttTitle(context)),
        Text(
          "Feel free to try this app without an account!",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Terms:",
          style: ttLabel(context),
        ),
        Text(
          " - 3 Day Limit",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        Text(
          " - All Features Unlocked",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        Text(
          " - No Liability",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        Text(
          " - Free Registration",
          style: ttLabel(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "After 3 days, you will be prompted to create a free account. If you choose not to, then the app will remain in a locked-down state.",
          style: ttBody(
            context,
            color: AppColors.subtext(context),
          ),
        ),
        const SizedBox(height: 16),
        AccountButton(
          title: "I Agree",
          bg: Theme.of(context).colorScheme.primary,
          fg: AppColors.cell(context),
          onTap: () async {
            setState(() {
              _isLoading = true;
            });
            await dmodel.createAnonymousUser(context);
            Navigator.of(context).pop();
          },
          isLoading: _isLoading,
        ),
        AccountAuthButtons(
          onSignIn: (credential) async {
            await dmodel.loginUser(context, credential);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
