import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
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

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  LoadingStatus _loadingStatus = LoadingStatus.loading;
  late ProductDetails _premiumDetails;
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    _fetchSubscriptions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        HeaderBar.sheet(
          title: "",
          horizontalSpacing: 0,
          trailing: const [CloseButton2()],
          children: [
            _content(context),
            const SizedBox(height: 100),
          ],
        ),
        if (_loadingStatus == LoadingStatus.done) _overlay(context),
      ],
    );
  }

  Widget _overlay(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context)[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      width: double.infinity,
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "${_premiumDetails.price}/month",
                style: ttBody(
                  context,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              WrappedButton(
                title: "Continue",
                bg: Colors.amber[600],
                center: true,
                rowAxisSize: MainAxisSize.max,
                onTap: () async {
                  print("Attemting to purchase premium");
                  var response = await _purchase(context);
                  if (!response) {
                    // TODO
                    print("There was an error making the purchase");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    switch (_loadingStatus) {
      case LoadingStatus.loading:
        return LoadingIndicator(
          color: Theme.of(context).colorScheme.primary,
        );
      case LoadingStatus.error:
        return Text("There was an error"); // TODO
      case LoadingStatus.done:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Supercharge your app with",
                    style: ttLabel(
                      context,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Workout Notepad Premium",
                    style: ttLabel(
                      context,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // show sliding screenshots of premium features
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6),
              child: PageView(
                controller: _pageController,
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                children: [
                  Container(
                    color: Colors.red[300],
                    width: double.infinity,
                  ),
                  Container(
                    color: Colors.blue[300],
                    width: double.infinity,
                  ),
                  Container(
                    color: Colors.green[300],
                    width: double.infinity,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < 3; i++)
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: i == _pageIndex
                            ? AppColors.subtext(context)
                            : AppColors.light(context),
                        shape: BoxShape.circle,
                      ),
                      height: 7,
                      width: 7,
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Section(
                    "Advanced Logging Features",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i in _loggingFeatures)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _featureCell(
                              context: context,
                              feature: i,
                              iconBg: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Section(
                    "Additional Features",
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i in _moreFeatures)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: _featureCell(
                              context: context,
                              feature: i,
                              iconBg: AppColors.cell(context)[700]!,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
    }
  }

  Widget _featureCell({
    required BuildContext context,
    required Tuple3<IconData, String, String> feature,
    required Color iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cell(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(feature.v1, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.v2,
                          style: ttLabel(
                            context,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          feature.v3,
                          style: ttcaption(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchSubscriptions() async {
    setState(() {
      _loadingStatus = LoadingStatus.loading;
    });
    const Set<String> _kIds = <String>{'wn_premium'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(_kIds);
    if (response.error != null) {
      print(response.error!.message); // TODO
      setState(() {
        _loadingStatus = LoadingStatus.error;
      });
      return;
    }
    if (response.productDetails.isEmpty) {
      print("The product details was empty"); // TODO
      setState(() {
        _loadingStatus = LoadingStatus.error;
      });
      return;
    }
    _premiumDetails = response.productDetails[0];
    setState(() {
      _loadingStatus = LoadingStatus.done;
    });
  }

  Future<bool> _purchase(BuildContext context) async {
    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _premiumDetails,
    );

    return await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
  }
}

List<Tuple3<IconData, String, String>> _loggingFeatures = [
  Tuple3(
    Icons.all_inclusive_rounded,
    "Unlimited Exercise Logs",
    "The exercise log dashboard will show all exercises logged instead of most recent 7.",
  ),
  Tuple3(
    Icons.tune_rounded,
    "Filtering Exercise Logs",
    "Filter your exercise logs based by tag on logging dashboard.",
  ),
  Tuple3(
    Icons.ssid_chart_rounded,
    "Exercise Distribution Graphs",
    "Advanced graphs to show your exercise progress by workout and by set number.",
  ),
  Tuple3(
    Icons.pie_chart_rounded,
    "Exercise Tagging distribution",
    "View how many exercise sets were tagged a specific way.",
  ),
  Tuple3(
    Icons.bar_chart_rounded,
    "Workout Logs Breakdown",
    "View the trends in your workouts by duration, exercise count, and set count.",
  ),
  Tuple3(
    Icons.speed_rounded,
    "Max Sets Dashboard",
    "A place where your max weight, reps, and times can live distributed by category and type.",
  ),
  Tuple3(
    Icons.pie_chart_rounded,
    "Exercise Type Distribution",
    "View your favorite exercises by type along with a dsitribution comparing the types against each other.",
  ),
  Tuple3(
    Icons.hub_rounded,
    "Category Overview",
    "How many exercises you log per category, along with a web graph to show deficiencies in your training.",
  ),
  Tuple3(
    Icons.category_rounded,
    "Per-Category Dashboard",
    "Comprehensive dashboards to give insights into your training at a per-category granularity.",
  ),
];
List<Tuple3<IconData, String, String>> _moreFeatures = [
  Tuple3(
    Icons.image_rounded,
    "Exercise Assets",
    "Attach your own images and videos to exercises allowing for greater clarify.",
  ),
  Tuple3(
    Icons.camera_rounded,
    "Workout Snapshots",
    "Point-in-time snapshots automatically created for workouts allowing you to explore how your workouts have progressed.",
  ),
  Tuple3(
    Icons.cloud_rounded,
    "Cloud Sync",
    "Automicaic Back-ups of your data to the cloud, along with the ability to restore from a point in time.",
  ),
  Tuple3(
    Icons.category_rounded,
    "Custom Categories",
    "Edit your existing categories, and create new ones that contain all the logging functionality of the defaults.",
  ),
  Tuple3(
    Icons.sell_rounded,
    "Custom Tags",
    "Edit your existing tags, and create new ones that contain all the logging functionality of the defaults.",
  ),
  Tuple3(
    Icons.loyalty_rounded,
    "Enhanced Tags",
    "Attach more than one tag to an exercise set to allow for greater log filtering flexibility.",
  ),
  Tuple3(
    Icons.download_rounded,
    "Export Data",
    "We hate vendor lock-in. Export your data to a format that makes sense to you, or contact our support to create a custom exporting solution.",
  ),
];
