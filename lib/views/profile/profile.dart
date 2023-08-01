import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/cupertino_sheet.dart';
import 'package:workout_notepad_v2/components/header_bar.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/components/wrapped_button.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/data/snapshot.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/profile/config_categories.dart';
import 'package:workout_notepad_v2/views/profile/configure_tags.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:workout_notepad_v2/views/profile/manage_data.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class ProfileItem {
  final String title;
  final IconData icon;
  final Color color;
  final int postType;
  final AsyncCallback onTap;

  ProfileItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.postType,
    required this.onTap,
  });
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
          )
        else if (dmodel.user!.subscriptionStatus == SubscriptionStatus.none)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: WrappedButton(
              title: "Explore Premium",
              icon: Icons.star,
              iconBg: Colors.amber[700],
              onTap: () {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const Subscriptions(),
                );
              },
            ),
          ),
        ContainedList<ProfileItem>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            ProfileItem(
              title: "Configure Categories",
              icon: Icons.category_rounded,
              color: Colors.blue[300]!,
              postType: 1,
              onTap: () async {
                cupertinoSheet(
                  context: context,
                  builder: (context) => ConfigureCategories(
                    categories: dmodel.categories,
                  ),
                );
              },
            ),
            ProfileItem(
              title: "Configure tags",
              icon: Icons.tag_rounded,
              color: Colors.deepOrange[300]!,
              postType: 1,
              onTap: () async {
                cupertinoSheet(
                  context: context,
                  builder: (context) => ConfigureTags(
                    tags: dmodel.tags,
                  ),
                );
              },
            ),
            ProfileItem(
              title: "Manage Data",
              icon: Icons.tag_rounded,
              color: Colors.green[300]!,
              postType: 2,
              onTap: () async {
                navigate(
                  context: context,
                  builder: (context) => const ManageData(),
                );
              },
            ),
          ],
          onChildTap: (context, item, index) async {
            setState(() {
              _loadingIndex = index;
            });
            await item.onTap();
            setState(() {
              _loadingIndex = -1;
            });
          },
          childBuilder: (context, item, index) {
            return Row(
              children: [
                Expanded(
                  child: WrappedButton(
                    title: item.title,
                    icon: item.icon,
                    iconBg: item.color,
                    isLoading: _loadingIndex == index,
                  ),
                ),
                if (item.postType > 0)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Transform.rotate(
                      angle: item.postType == 1 ? math.pi / -2 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.subtext(context),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        WrappedButton(
          title: "Logout",
          rowAxisSize: MainAxisSize.max,
          onTap: () async {
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
                  await dmodel.logout(context);
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
                  await dmodel.logout(context);
                },
              );
            }
          },
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}
