// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class ManagePurchases extends StatefulWidget {
  const ManagePurchases({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<ManagePurchases> createState() => _ManagePurchasesState();
}

class _ManagePurchasesState extends State<ManagePurchases> {
  // bool _isLoading = true;
  final bool _loadingRestore = false;

  @override
  void initState() {
    super.initState();
    // _getPurchases();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(
            ignoring: _isLoadingHandler(dmodel),
            child: HeaderBar(
              title: "Manage Subscriptions",
              leading: const [BackButton2()],
              children: [
                Column(
                  children: [
                    _currentSubscription(context, dmodel),
                    StyledSection(
                      title: "",
                      items: [
                        // StyledSectionItem(
                        //   title: "Missing A Purchase",
                        //   icon: Icons.search_rounded,
                        //   color: Colors.blueGrey[300]!,
                        //   onTap: () async {
                        //     await showAlert(
                        //       context: context,
                        //       title: "Are You Sure?",
                        //       body: const Column(
                        //         children: [
                        //           Text(
                        //               "The recommended way to restore purchases is through support or in your transaction history."),
                        //           Text(
                        //               "If you click yes, your purchases will be queried from the store, and your app will reload if a purchase is found.")
                        //         ],
                        //       ),
                        //       cancelText: "Cancel",
                        //       onCancel: () {},
                        //       cancelBolded: true,
                        //       submitText: "Yes",
                        //       onSubmit: () async {
                        //         var iap = InAppPurchase.instance;
                        //         await iap.restorePurchases();
                        //       },
                        //     );
                        //   },
                        //   post: StyledSectionItemPost.view,
                        //   isLocked: false,
                        // ),
                        StyledSectionItem(
                          title: "Request a Refund",
                          icon: Icons.currency_exchange_rounded,
                          color: Colors.blueGrey[300]!,
                          onTap: () async {
                            late Uri uri;
                            if (Platform.isIOS) {
                              uri = Uri.parse(
                                  "https://support.apple.com/HT204084");
                            } else if (Platform.isAndroid) {
                              uri = Uri.parse(
                                  "https://support.google.com/googleplay/workflow/9813244");
                            } else {
                              uri = Uri.parse(
                                "https://workoutnotepad.co/support?userId=${widget.user.userId}",
                              );
                            }
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          },
                          post: StyledSectionItemPost.view,
                          isLocked: false,
                        ),
                        StyledSectionItem(
                          title: "Purchase Support",
                          icon: Icons.support_agent_rounded,
                          color: Colors.blueGrey[300]!,
                          onTap: () async {
                            await launchSupportPage(
                                context, dmodel.user!, "Premium Issue");
                          },
                          post: StyledSectionItemPost.view,
                          isLocked: false,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isLoadingHandler(dmodel))
            Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: LoadingIndicator(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _currentSubscription(BuildContext context, DataModel dmodel) {
    late String title;
    late String dates;
    if (dmodel.user!.subscriptionType == SubscriptionType.wn_unlocked) {
      title = "Permanently Unlocked";
      dates = "";
    } else if (dmodel.subscription != null) {
      title = dmodel.subscription!.title;
      dates = "${formatDateTime(
        DateTime.parse(dmodel.subscription!.created),
      )} - ${dmodel.subscription!.active == 1 ? "Current" : ("${formatDateTime(
          DateTime.parse(dmodel.subscription!.updated),
        )} (expired)")}";
    } else {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.amber, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            height: 75,
            width: 75,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset("assets/images/app-icon.png"),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: ttLabel(context),
          ),
          if (dates.isNotEmpty)
            Text(
              dates,
              style: ttcaption(context),
            ),
        ],
      ),
    );
  }

  bool _isLoadingHandler(DataModel dmodel) {
    if (_loadingRestore) return true;
    if (dmodel.paymentLoadStatus == PaymentLoadStatus.loading) return true;
    return false;
  }

  // Future<void> _getPurchases() async {
  //   setState(() {
  //     _isLoading = true;
  //   });
  //   try {
  //     var client = PurchaseClient(client: http.Client());
  //     var response =
  //         await client.fetch("/users/${widget.user.userId}/transactionHistory");
  //     client.client.close();

  //     if (response.statusCode == 404) {
  //       print("No transactions found");
  //     } else if (response.statusCode != 200) {
  //       print(response.body);
  //       snackbarErr(
  //         context,
  //         "There was an issue getting your transaction history",
  //       );
  //     } else {
  //       // decode
  //       var body = jsonDecode(response.body);

  //       // parse apple transactions
  //       for (var i in body['app_store']) {
  //         var decoded = ApplePurchaseRecord.fromJson(i);
  //         if (decoded.records.isNotEmpty) {
  //           print(decoded.records[0]);
  //         }
  //       }
  //     }
  //   }  catch (e, stack) { logger.exception(e, stack);
  //     print(e);
  //     NewrelicMobile.instance.recordError(
  //       e,
  //       StackTrace.current,
  //       attributes: {"err_code": "user_transactions"},
  //     );
  //   }
  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  // Future<void> _restorePurchase(BuildContext context) async {
  //   setState(() {
  //     _loadingRestore = true;
  //   });
  //   try {
  //     var client = Client(client: http.Client());
  //     var response = await client.put(
  //       "/users/${widget.user.userId}/restorePurchase",
  //       {},
  //       null,
  //     );
  //     if (response.statusCode == 200) {
  //       var body = jsonDecode(response.body);
  //       if (body['body']) {
  //         RestartWidget.restartApp(context);
  //       } else {
  //         snackbarErr(
  //           context,
  //           "There was an issue restoring the purchase. If you think this is a mistake, please contact support",
  //         );
  //       }
  //     } else {
  //       NewrelicMobile.instance.recordError(
  //         response.body,
  //         StackTrace.current,
  //         attributes: {"err_code": "restore_purchase"},
  //       );
  //       snackbarErr(
  //         context,
  //         "There was an issue restoring the purchase. If you think this is a mistake, please contact support",
  //       );
  //     }
  //   }  catch (e, stack) { logger.exception(e, stack);
  //     print(e);
  //     NewrelicMobile.instance.recordError(
  //       e,
  //       StackTrace.current,
  //       attributes: {"err_code": "restore_purchase"},
  //     );
  //     snackbarErr(context, "There was an unknown error restoring the purchase");
  //   }
  //   setState(() {
  //     _loadingRestore = false;
  //   });
  // }
}
