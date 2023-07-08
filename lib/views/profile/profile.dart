import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/clickable.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart' as comp;
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/account/root.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _logoutLoading = false;
  bool _exportLoading = false;
  bool _importLoading = false;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    if (dmodel.user == null) {
      return const Center(
        child: Text("No user found"),
      );
    }
    return HeaderBar(
      title: "",
      children: [
        const SizedBox(height: 16),
        Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: dmodel.user!.avatar(context, size: 125)),
        if (dmodel.user!.displayName != null)
          Text(
            dmodel.user!.displayName!,
            style: ttSubTitle(context),
            textAlign: TextAlign.center,
          ),
        if (dmodel.user!.isAnon)
          Text(
            "Anonymous User",
            style: ttSubTitle(context),
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 32),
        if (dmodel.user!.isAnon)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: WrappedButton(
              title: "Create Account",
              icon: Icons.person_outline_outlined,
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const CreateAccount(),
                );
              },
            ),
          ),
        WrappedButton(
          title: "Logout",
          icon: Icons.logout_rounded,
          iconBg: AppColors.cell(context)[700],
          isLoading: _logoutLoading,
          onTap: () async {
            setState(() {
              _logoutLoading = true;
            });
            if (dmodel.user!.isAnon) {
              await showAlert(
                context: context,
                title: "WARNING!",
                body: const Text(
                    "As an anonymous user, once you logout, your exercise data will be UNRECOVERABLE. If you want to switch accounts, it is recommended that you first create an account under this user."),
                cancelText: "Cancel",
                onCancel: () {},
                cancelBolded: true,
                submitText: "Delete Data",
                submitColor: Colors.red,
                onSubmit: () async {
                  await dmodel.logout();
                },
              );
              setState(() {
                _logoutLoading = false;
              });
            } else {
              await showAlert(
                context: context,
                title: "Are You Sure?",
                body: const Text(
                    "Your exercise data will be removed from your phone on logout. If you are online, a snapshot will be automatically created for you."),
                cancelText: "Cancel",
                onCancel: () {},
                cancelBolded: true,
                submitText: "Logout",
                submitColor: Colors.red,
                onSubmit: () async {
                  await dmodel.logout();
                },
              );
              setState(() {
                _logoutLoading = false;
              });
            }
          },
        ),
        const SizedBox(height: 32),
        // TODO!! -- remove
        Text("DEV"),
        const SizedBox(height: 8),
        WrappedButton(
          title: "Export Data",
          icon: Icons.download_rounded,
          iconBg: Colors.purple,
          onTap: () async {
            setState(() {
              _exportLoading = true;
            });
            await dmodel.exportToJSON();
            setState(() {
              _exportLoading = false;
            });
          },
        ),
        const SizedBox(height: 8),
        WrappedButton(
          title: "Import Data",
          icon: Icons.upload_rounded,
          iconBg: Colors.blue,
          onTap: () async {
            setState(() {
              _importLoading = true;
            });
            await showAlert(
              context: context,
              title: "Caution",
              body: const Text(
                  "Importing a file will overwrite your current workouts, exercises, and logs. Are you sure you want to continue?"),
              cancelText: "Cancel",
              onCancel: () {},
              cancelBolded: true,
              submitText: "Overwrite",
              submitColor: Colors.red,
              onSubmit: () async {
                await dmodel.importData();
              },
            );
            setState(() {
              _importLoading = false;
            });
          },
        ),
      ],
    );
  }
}
