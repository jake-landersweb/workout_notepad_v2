import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/profile/config_categories.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  int _loadingIndex = -1;

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
        ContainedList<Tuple4<String, IconData, Color, AsyncCallback>>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            Tuple4(
              "Configure Categories",
              Icons.category_rounded,
              Colors.blue,
              () async {
                cupertinoSheet(
                  context: context,
                  builder: (context) => ConfigureCategories(
                    categories: dmodel.categories,
                  ),
                );
              },
            ),
            Tuple4(
              "Configure Tags",
              Icons.tag_rounded,
              Colors.deepOrange,
              () async {},
            ),
            Tuple4(
              "Logout",
              Icons.logout_rounded,
              AppColors.cell(context)[700]!,
              () async {
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
                }
              },
            ),
          ],
          onChildTap: (context, item, index) async {
            setState(() {
              _loadingIndex = index;
            });
            await item.v4();
            setState(() {
              _loadingIndex = -1;
            });
          },
          childBuilder: (context, item, index) {
            return WrappedButton(
              title: item.v1,
              icon: item.v2,
              iconBg: item.v3,
              isLoading: _loadingIndex == index,
            );
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
          isLoading: _loadingIndex == 100,
          onTap: () async {
            setState(() {
              _loadingIndex = 100;
            });
            var response = await dmodel.exportToJSON();
            if (response) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Success!"),
                ),
              );
            }
            setState(() {
              _loadingIndex = -1;
            });
          },
        ),
        const SizedBox(height: 8),
        WrappedButton(
          title: "Import Data",
          icon: Icons.upload_rounded,
          iconBg: Colors.blue,
          isLoading: _loadingIndex == 101,
          onTap: () async {
            setState(() {
              _loadingIndex = 101;
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
              _loadingIndex = -1;
            });
          },
        ),
      ],
    );
  }
}
