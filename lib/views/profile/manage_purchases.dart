// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/components/alert.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/main.dart';
import 'package:workout_notepad_v2/model/client.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:http/http.dart' as http;

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
  bool _isLoading = true;
  bool _loadingRestore = false;
  List<PurchaseTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    _getPurchases();
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
              title: "Manage Purchases",
              leading: const [BackButton2()],
              children: [
                Column(
                  children: [
                    StyledSection(
                      title: "",
                      items: [
                        StyledSectionItem(
                          title: "Missing A Purchase",
                          icon: Icons.search_rounded,
                          color: Colors.blueGrey[300]!,
                          onTap: () async {
                            await showAlert(
                              context: context,
                              title: "Are You Sure?",
                              body: const Column(
                                children: [
                                  Text(
                                      "The recommended way to restore purchases is through support or in your transaction history."),
                                  Text(
                                      "If you click yes, your purchases will be queried from the store, and your app will reload if a purchase is found.")
                                ],
                              ),
                              cancelText: "Cancel",
                              onCancel: () {},
                              cancelBolded: true,
                              submitText: "Yes",
                              onSubmit: () async {
                                var iap = InAppPurchase.instance;
                                await iap.restorePurchases();
                              },
                            );
                          },
                          post: StyledSectionItemPost.view,
                          isLocked: false,
                        ),
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
                    const SizedBox(height: 8),
                    Section(
                      "Transaction History",
                      child: Column(
                        children: [
                          if (_isLoading)
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cell(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: LoadingIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            )
                          else if (_transactions.isNotEmpty)
                            Column(
                              children: [
                                for (int i = 0; i < _transactions.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.cell(context),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            16, 8, 16, 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(6.0),
                                                child: Icon(
                                                  _transactions[i].getIcon(),
                                                  color: Colors.white,
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _transactions[i].productId,
                                                    style: ttcaption(context),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          _transactions[i]
                                                              .getTitle(),
                                                          style:
                                                              ttLabel(context),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Text(
                                                    formatDateTime(
                                                        _transactions[i]
                                                            .created),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: AppColors.subtext(
                                                          context),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (i == 0 &&
                                                _transactions[i]
                                                        .transactionType ==
                                                    PurchaseTransactionType
                                                        .assign &&
                                                dmodel.user!.subscriptionType ==
                                                    SubscriptionType.none)
                                              Clickable(
                                                onTap: () {
                                                  _restorePurchase(context);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: Colors.amber[500],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(8, 2, 8, 2),
                                                    child: Text(
                                                      "Restore Purchase",
                                                      style: ttcaption(
                                                        context,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          else
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.cell(context),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              width: double.infinity,
                              height: 40,
                              child: Center(
                                child: Text("No Transactions Found"),
                              ),
                            ),
                        ],
                      ),
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

  bool _isLoadingHandler(DataModel dmodel) {
    if (_loadingRestore) return true;
    if (dmodel.paymentLoadStatus == PaymentLoadStatus.loading) return true;
    return false;
  }

  Future<void> _getPurchases() async {
    setState(() {
      _isLoading = true;
    });
    try {
      var client = Client(client: http.Client());
      var response =
          await client.fetch("/users/${widget.user.userId}/transactions");
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        for (var i in body['body']) {
          _transactions.add(PurchaseTransaction.fromJson(i));
        }
        _transactions.sortBy((element) => element.created);
        _transactions = _transactions.reversed.toList();
      } else {
        print(response.body);
        snackbarErr(context, "There was an issue fetching your purchases");
        NewrelicMobile.instance.recordError(
          "There was an issue fetching the users transactions",
          null,
          attributes: {"err_code": "user_transactions"},
        );
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "user_transactions"},
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _restorePurchase(BuildContext context) async {
    setState(() {
      _loadingRestore = true;
    });
    try {
      var client = Client(client: http.Client());
      var response = await client.put(
        "/users/${widget.user.userId}/restorePurchase",
        {},
        null,
      );
      if (response.statusCode == 200) {
        var body = jsonDecode(response.body);
        if (body['body']) {
          RestartWidget.restartApp(context);
        } else {
          snackbarErr(
            context,
            "There was an issue restoring the purchase. If you think this is a mistake, please contact support",
          );
        }
      } else {
        print(response.body);
        NewrelicMobile.instance.recordError(
          response.body,
          StackTrace.current,
          attributes: {"err_code": "restore_purchase"},
        );
        snackbarErr(
          context,
          "There was an issue restoring the purchase. If you think this is a mistake, please contact support",
        );
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "restore_purchase"},
      );
      snackbarErr(context, "There was an unknown error restoring the purchase");
    }
    setState(() {
      _loadingRestore = false;
    });
  }
}
