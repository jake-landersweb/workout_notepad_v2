import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/profile/subscription_loading.dart';

class Subscriptions extends StatefulWidget {
  const Subscriptions({super.key});

  @override
  State<Subscriptions> createState() => _SubscriptionsState();
}

class _SubscriptionsState extends State<Subscriptions> {
  late PageController _controller;
  late int _pageIndex;

  bool _initLoading = true;
  bool _hasError = false;
  List<ProductDetails> _products = [];
  ProductDetails? _selectedProduct;
  bool sheetHasBeenShown = false;

  final List<Tuple3<String, String, IconData>> _items = [
    Tuple3(
      "Visualize Your Data",
      "Comprehesive graphs to view your progress overtime.",
      Icons.bar_chart_rounded,
    ),
    Tuple3(
      "Filtering Exercise Logs",
      "Filter your exercise logs based by tag on your logging dashboard.",
      Icons.tune_rounded,
    ),
    Tuple3(
      "Exercise Assets",
      "Attach your own images and videos to exercises allowing for greater clarify.",
      Icons.image_rounded,
    ),
    Tuple3(
      "Cloud Sync",
      "Automicaic Back-ups of your data to the cloud, along with the ability to restore from a point in time.",
      Icons.cloud_rounded,
    ),
    Tuple3(
      "Custom Categories",
      "Edit your existing categories, and create new ones that contain all the logging functionality of the defaults.",
      Icons.category_rounded,
    ),
    Tuple3(
      "Custom Tags",
      "Edit your existing tags, and create new ones that contain all the logging functionality of the defaults.",
      Icons.sell_rounded,
    ),
    Tuple3(
      "Export Data",
      "We hate vendor lock-in. Export your data to a format that makes sense to you, or contact our support to create a custom exporting solution.",
      Icons.download_rounded,
    ),
  ];

  @override
  void initState() {
    _pageIndex = 0;
    _controller = PageController(initialPage: _pageIndex);
    super.initState();
    _fetchSubscriptions();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    if (dmodel.paymentLoadStatus != PaymentLoadStatus.none &&
        !sheetHasBeenShown) {
      sheetHasBeenShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cupertinoSheet(
          context: context,
          isDismissible: false,
          enableDrag: false,
          builder: (context) => const SubscriptionLoading(),
        );
      });
    }

    return HeaderBar.sheet(
      title: "",
      horizontalSpacing: 0,
      trailing: const [CloseButton2()],
      canScroll: false,
      children: [
        const SizedBox(height: 70),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Padding(
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
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: WrappedButton(
            title: "Explore All Features",
            onTap: () {
              launchUrl(Uri.parse("https://workoutnotepad.co/premium"),
                  mode: LaunchMode.externalApplication);
            },
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: AppColors.subtext(context),
            ),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: PageView(
            controller: _controller,
            onPageChanged: (value) {
              setState(() {
                _pageIndex = value;
              });
            },
            children: [
              for (var i in _items) _itemCell(context, i),
            ],
          ),
        ),
        const SizedBox(height: 4),
        if (_hasError)
          Center(
              child: Text(
            "There was an issue getting the available subscriptions",
            textAlign: TextAlign.center,
          ))
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < _items.length; i++)
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
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i in _products) _productCell(context, i),
                  const SizedBox(height: 16),
                  WrappedButton(
                    title: "Subscribe",
                    type: WrappedButtonType.main,
                    rowAxisSize: MainAxisSize.max,
                    center: true,
                    isLoading: _initLoading,
                    onTap: () {
                      _purchase(context, dmodel);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom),
      ],
    );
  }

  Widget _itemCell(BuildContext context, Tuple3 item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(item.v1, style: ttSubTitle(context)),
              const SizedBox(height: 8),
              Text(
                item.v2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Icon(
                item.v3,
                size: 75,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _productCell(BuildContext context, ProductDetails details) {
    var metadata = _getMetadata(details);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Clickable(
        onTap: () {
          setState(() {
            _selectedProduct = details;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: (details.id == (_selectedProduct?.id ?? ""))
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.cell(context),
            ),
            borderRadius: BorderRadius.circular(15),
            color: AppColors.cell(context),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        metadata.v1,
                        style: ttLabel(context),
                      ),
                    ),
                    Icon(
                      details.id == (_selectedProduct?.id ?? "")
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                      color: details.id == (_selectedProduct?.id ?? "")
                          ? Theme.of(context).colorScheme.primary
                          : AppColors.subtext(context),
                    ),
                  ],
                ),
                Text(
                  metadata.v2,
                  style: ttcaption(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Tuple2 _getMetadata(ProductDetails details) {
    if (details.id == "wn_premium") {
      return Tuple2("Monthly Plan", "1 week free, then ${details.price}/month");
    } else if (details.id == "wn_premium_year") {
      return Tuple2("Yearly Plan", "${details.price}/year, Save 40%");
    } else {
      return Tuple2("Unknown", "Unkown");
    }
  }

  Future<void> _fetchSubscriptions() async {
    const Set<String> kIds = <String>{'wn_premium', 'wn_premium_year'};
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(kIds);

    if (response.error != null) {
      _hasError = true;
      snackbarErr(context, "There was an issue finding the store details");
    } else {
      _products = response.productDetails;
      _selectedProduct = _products[0];
      // google does something odd
      _products.removeWhere((element) => element.rawPrice == 0);
      print("Found ${_products.length} products");
    }

    setState(() {
      _initLoading = false;
    });
  }

  Future<bool> _purchase(BuildContext context, DataModel dmodel) async {
    if (_selectedProduct == null) {
      print("Details are null");
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _selectedProduct!,
      applicationUserName: dmodel.user!.userId,
    );

    var resp = await InAppPurchase.instance
        .buyNonConsumable(purchaseParam: purchaseParam);
    print("Response from buy: $resp");
    return resp;
  }
}
