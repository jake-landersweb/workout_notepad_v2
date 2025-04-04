// ignore_for_file: unused_field

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/internet_provider.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/account/root.dart';
import 'package:workout_notepad_v2/views/profile/config_categories.dart';
import 'package:workout_notepad_v2/views/profile/configure_tags.dart';
import 'package:workout_notepad_v2/views/profile/edit_profile.dart';
import 'package:workout_notepad_v2/views/profile/local_preferences.dart';

import 'package:workout_notepad_v2/views/profile/manage_data.dart';
import 'package:workout_notepad_v2/views/profile/manage_purchases.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';
import 'package:workout_notepad_v2/views/profile/re_auth.dart';
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
  late Key _avatarKey;
  int _loadingIndex = -1;
  String buildInfo = "";

  @override
  void initState() {
    _avatarKey = UniqueKey();
    init();
    super.initState();
  }

  Future<void> init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      buildInfo =
          "Version ${packageInfo.version} Build ${packageInfo.buildNumber}";
    });
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var internetModel = Provider.of<InternetProvider>(context);
    if (dmodel.user == null) {
      return const Scaffold(
        body: Center(child: Text("No user found")),
      );
    }
    return Scaffold(
      body: HeaderBar(
        title: "",
        leading: [BackButton2()],
        trailing: [
          if (dmodel.user != null)
            EditButton(onTap: () {
              if (!internetModel.hasInternet()) {
                snackbarErr(context, "You are offline.");
              } else {
                cupertinoSheet(
                  context: context,
                  builder: (context) => EditProfile(
                    user: dmodel.user!,
                    onSave: () {
                      setState(() {
                        _avatarKey = UniqueKey();
                      });
                    },
                  ),
                );
              }
            }),
        ],
        children: [
          const SizedBox(height: 16),
          Center(
            child: Padding(
              key: _avatarKey,
              padding: const EdgeInsets.only(bottom: 16.0),
              child: dmodel.user!.avatar(context, size: 125),
            ),
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
                if (dmodel.hasValidSubscription())
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.amber[500],
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
          if (dmodel.hasValidSubscription() && dmodel.snapshots.isNotEmpty)
            Center(
              child: Text(
                "Last sync: ${formatDateTime(DateTime.fromMillisecondsSinceEpoch(dmodel.snapshots.first.created.round()))}",
                style: ttcaption(context),
              ),
            ),
          const SizedBox(height: 16),
          if (dmodel.user!.requiresReAuth())
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: WrappedButton(
                title: "Re-Auth Required",
                icon: Icons.warning,
                iconBg: Colors.red.shade400,
                bg: Colors.red.shade400,
                fg: Colors.white,
                onTap: () => cupertinoSheet(
                  context: context,
                  builder: (context) => const ReAuth(),
                ),
              ),
            ),
          if (dmodel.user!.isAnon)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
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
          else if (!dmodel.hasValidSubscription())
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: WrappedButton(
                title: "Workout Notepad Premium",
                icon: Icons.star,
                iconBg: Colors.amber[500],
                onTap: () {
                  showPaywall(context);
                },
              ),
            ),
          if (dmodel.hasRecommendedUpdate)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: WrappedButton(
                title: "Update Available",
                icon: Icons.update_rounded,
                iconBg: Colors.teal[300],
                onTap: () async {
                  await launchAppStore();
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
          const SizedBox(height: 32),
          StyledSection(
            title: "",
            items: [
              StyledSectionItem(
                title: "Configure Categories",
                icon: Icons.category_rounded,
                color: Colors.green[500]!,
                post: StyledSectionItemPost.model,
                isLocked: !dmodel.hasValidSubscription(),
                onTap: () async {
                  if (dmodel.hasValidSubscription()) {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => ConfigureCategories(
                        categories: dmodel.categories,
                      ),
                    );
                  } else {
                    showPaywall(context);
                  }
                },
              ),
              StyledSectionItem(
                title: "Configure tags",
                icon: Icons.tag_rounded,
                color: Colors.blueGrey.shade300,
                post: StyledSectionItemPost.model,
                isLocked: !dmodel.hasValidSubscription(),
                onTap: () async {
                  if (dmodel.hasValidSubscription()) {
                    cupertinoSheet(
                      context: context,
                      builder: (context) => ConfigureTags(
                        tags: dmodel.tags,
                      ),
                    );
                  } else {
                    showPaywall(context);
                  }
                },
              ),
              StyledSectionItem(
                title: "Manage Syncs",
                icon: Icons.sync_rounded,
                color: Colors.red.shade300,
                post: StyledSectionItemPost.view,
                isLocked: !dmodel.hasValidSubscription(),
                onTap: () async {
                  if (dmodel.hasValidSubscription()) {
                    navigate(
                      context: context,
                      builder: (context) => const ManageData(),
                    );
                  } else {
                    showPaywall(context);
                  }
                },
              ),
              StyledSectionItem(
                title: "Local Settings",
                icon: Icons.settings_rounded,
                color: Colors.orange.shade300,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  navigate(
                    context: context,
                    builder: (context) => const LocalPreferencesView(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          StyledSection(
            title: "",
            items: [
              StyledSectionItem(
                title: "Manage Subscriptions",
                icon: Icons.local_mall_rounded,
                color: Colors.black,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  // var iap = InAppPurchase.instance;
                  // await iap.restorePurchases();
                  navigate(
                    context: context,
                    builder: (context) => ManagePurchases(user: dmodel.user!),
                  );
                },
              ),
              StyledSectionItem(
                title: "Export Data",
                icon: Icons.download_rounded,
                color: Colors.blue[500]!,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  await launchSupportPage(context, dmodel.user!, "Data Export");
                },
              ),
              StyledSectionItem(
                title: "Contact Support",
                icon: Icons.call_rounded,
                color: Colors.orangeAccent.shade200,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  await launchSupportPage(context, dmodel.user!, "App Issue");
                },
              ),
              StyledSectionItem(
                title: "Leave Feedback",
                icon: Icons.chat_rounded,
                color: Colors.purple.shade300,
                post: StyledSectionItemPost.external,
                isLocked: false,
                onTap: () async {
                  await launchSupportPage(context, dmodel.user!, "Feedback");
                },
              ),
              StyledSectionItem(
                title: "Rate The App!",
                icon: Icons.star_rounded,
                color: Colors.amber[500]!,
                post: StyledSectionItemPost.none,
                isLocked: false,
                onTap: () async {
                  final InAppReview inAppReview = InAppReview.instance;
                  inAppReview.openStoreListing(appStoreId: '6453561144');
                },
              ),
              StyledSectionItem(
                title: "View Help Screen",
                icon: Icons.info_outline_rounded,
                color: Colors.red.shade300,
                post: StyledSectionItemPost.model,
                isLocked: false,
                onTap: () async {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const WelcomeScreen(),
                  );
                },
              ),
              StyledSectionItem(
                title: "Open Docs",
                icon: Icons.book,
                color: Colors.lightGreen,
                post: StyledSectionItemPost.external,
                isLocked: false,
                onTap: () async {
                  launchUrl(Uri.parse("https://docs.workoutnotepad.co/"));
                },
              ),
            ],
          ),
          const SizedBox(height: 32),
          StyledSection(
            title: "",
            items: [
              StyledSectionItem(
                title: "Privacy Policy",
                icon: Icons.lock,
                color: Colors.green.shade400,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  if (!await launchUrl(
                      Uri.parse("https://workoutnotepad.co/privacy-policy"))) {
                    snackbarErr(context,
                        "There was an issue opening the privacy policy.");
                  }
                },
              ),
              StyledSectionItem(
                title: "EULA",
                icon: Icons.check,
                color: Colors.blue.shade400,
                post: StyledSectionItemPost.view,
                isLocked: false,
                onTap: () async {
                  if (!await launchUrl(
                      Uri.parse("https://workoutnotepad.co/eula"))) {
                    snackbarErr(
                        context, "There was an issue opening the EULA.");
                  }
                },
              ),
              StyledSectionItem(
                title: "Logout",
                icon: Icons.logout_rounded,
                color: Colors.grey[500]!,
                post: StyledSectionItemPost.none,
                isLocked: false,
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
                        Navigator.of(context).pop();
                        await dmodel.logout(context);
                      },
                    );
                  } else {
                    await showAlert(
                      context: context,
                      title: "Are You Sure?",
                      body: const Text(
                          "Your exercise data will be removed from your phone on logout. Ensure your data is properly synced."),
                      cancelText: "Cancel",
                      onCancel: () {},
                      cancelBolded: true,
                      submitText: "Logout",
                      submitColor: Colors.red[500],
                      onSubmit: () async {
                        Navigator.of(context).pop();
                        await dmodel.logout(context);
                        await Future.delayed(
                          const Duration(milliseconds: 1000),
                        );
                      },
                    );
                  }
                },
              ),
              StyledSectionItem(
                title: "Delete Account",
                icon: Icons.delete_forever_rounded,
                color: Colors.red[400]!,
                post: StyledSectionItemPost.none,
                isLocked: false,
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
          ),
          const SizedBox(height: 32),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Made with",
                  style: ttcaption(context, fontWeight: FontWeight.w400),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Icon(
                    Icons.favorite_rounded,
                    size: 16,
                    color: Colors.red[400],
                  ),
                ),
                Text(
                  "in Portland, OR",
                  style: ttcaption(context, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Clickable(
            onTap: () async {
              if (!await launchUrl(Uri.parse("https://sapphirenw.com"))) {
                snackbarErr(
                    context, "There was an issue opening the support page.");
              }
            },
            child: Center(
              child: Image.asset(
                "assets/images/sapphire_text_blue_small.png",
                height: 20,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              buildInfo,
              style: ttcaption(context, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
