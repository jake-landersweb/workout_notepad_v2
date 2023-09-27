import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/profile/config_categories.dart';
import 'package:workout_notepad_v2/views/profile/configure_tags.dart';
import 'dart:math' as math;

import 'package:workout_notepad_v2/views/profile/manage_data.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';
import 'package:workout_notepad_v2/views/welcome.dart';

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
          child: dmodel.user!.avatar(context, size: 125),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dmodel.user!.getName(),
                style: ttSubTitle(context),
                textAlign: TextAlign.center,
              ),
              if (dmodel.user!.isAnon)
                Text(
                  "Anonymous User",
                  style: ttSubTitle(context),
                  textAlign: TextAlign.center,
                ),
              if (dmodel.user!.subscriptionType != SubscriptionType.none)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.star_rounded,
                        color: AppColors.cell(context),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (dmodel.user!.isPremiumUser() && dmodel.snapshots.isNotEmpty)
          Center(
            child: Text(
              "Last sync: ${formatDateTime(DateTime.fromMillisecondsSinceEpoch(dmodel.snapshots.first.created.round()))}",
              style: ttcaption(context),
            ),
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
        else if (dmodel.user!.subscriptionType == SubscriptionType.none)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: WrappedButton(
              title: "Workout Notepad Unlocked",
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
        // else if (dmodel.user!.isPremiumUser())
        //   Padding(
        //     padding: const EdgeInsets.only(bottom: 16.0),
        //     child: WrappedButton(
        //       title: "Manage Purchases",
        //       icon: Icons.credit_card_rounded,
        //       iconBg: Colors.teal[400],
        //       onTap: () {},
        //     ),
        //   ),
        ContainedList<ProfileItem>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            ProfileItem(
              title: "Configure Categories",
              icon: Icons.category_rounded,
              color: Colors.green[500]!,
              postType: 1,
              onTap: () async {
                if (dmodel.user!.isPremiumUser()) {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => ConfigureCategories(
                      categories: dmodel.categories,
                    ),
                  );
                } else {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const Subscriptions(),
                  );
                }
              },
            ),
            ProfileItem(
              title: "Configure tags",
              icon: Icons.tag_rounded,
              color: Colors.green[500]!,
              postType: 1,
              onTap: () async {
                if (dmodel.user!.isPremiumUser()) {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => ConfigureTags(
                      tags: dmodel.tags,
                    ),
                  );
                } else {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const Subscriptions(),
                  );
                }
              },
            ),
            ProfileItem(
              title: "Manage Syncs",
              icon: Icons.sync_rounded,
              color: Colors.purple[500]!,
              postType: 2,
              onTap: () async {
                if (dmodel.user!.isPremiumUser()) {
                  navigate(
                    context: context,
                    builder: (context) => const ManageData(),
                  );
                } else {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const Subscriptions(),
                  );
                }
              },
            ),
            ProfileItem(
              title: "Export Data",
              icon: Icons.download_rounded,
              color: Colors.blue[700]!,
              postType: 0,
              onTap: () async {
                if (dmodel.user!.isPremiumUser()) {
                  await launchSupportPage(context, dmodel.user!, "Data Export");
                } else {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const Subscriptions(),
                  );
                }
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
                    child: dmodel.user!.isPremiumUser()
                        ? Transform.rotate(
                            angle: item.postType == 1 ? math.pi / -2 : 0,
                            child: Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.subtext(context),
                            ),
                          )
                        : Icon(
                            Icons.lock_rounded,
                            color: AppColors.subtext(context),
                          ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        ContainedList<ProfileItem>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            ProfileItem(
              title: "Contact Support",
              icon: Icons.call_rounded,
              color: Colors.blue[700]!,
              postType: 0,
              onTap: () async {
                await launchSupportPage(context, dmodel.user!, "App Issue");
              },
            ),
            ProfileItem(
              title: "Leave Feedback",
              icon: Icons.chat_rounded,
              color: Colors.blue[700]!,
              postType: 0,
              onTap: () async {
                await launchSupportPage(context, dmodel.user!, "Feedback");
              },
            ),
            ProfileItem(
              title: "View Help Screen",
              icon: Icons.info_outline_rounded,
              color: Colors.red[500]!,
              postType: 0,
              onTap: () async {
                cupertinoSheet(
                  context: context,
                  builder: (context) => const WelcomeScreen(),
                );
              },
            ),
          ],
          onChildTap: (context, item, index) async {
            setState(() {
              _loadingIndex = index + 100;
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
                      )),
              ],
            );
          },
        ),
        const SizedBox(height: 32),
        ContainedList<ProfileItem>(
          leadingPadding: 0,
          trailingPadding: 0,
          childPadding: EdgeInsets.zero,
          children: [
            ProfileItem(
              title: "Logout",
              icon: Icons.logout_rounded,
              color: Colors.grey[500]!,
              postType: 0,
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
                    submitColor: Colors.red[500],
                    onSubmit: () async {
                      await dmodel.logout(context);
                      setState(() {});
                    },
                  );
                }
              },
            ),
            ProfileItem(
              title: "Delete Account",
              icon: Icons.delete_forever_rounded,
              color: Colors.red[400]!,
              postType: 0,
              onTap: () async {
                await showAlert(
                  context: context,
                  title: "WARNING!",
                  body: const Column(
                    children: [
                      Text(
                          "Your account will be submitted for deletion. If there is no activity for 30 days, the account will be permanently deleted."),
                      SizedBox(height: 4),
                      Text(
                          "If you change your mind, logging into this account will reverse this process."),
                    ],
                  ),
                  cancelText: "Cancel",
                  onCancel: () {},
                  cancelBolded: true,
                  submitText: "Delete",
                  submitColor: Colors.red,
                  onSubmit: () async {
                    await dmodel.delete();
                  },
                );
              },
            ),
          ],
          onChildTap: (context, item, index) async {
            setState(() {
              _loadingIndex = index + 100;
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
                    isLoading: _loadingIndex == index + 100,
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
                      )),
              ],
            );
          },
        ),
        const SizedBox(height: 100),
      ],
    );
  }
}
