// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:provider/provider.dart';

import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class PromoCodeSearch extends StatefulWidget {
  const PromoCodeSearch({
    super.key,
    required this.onFound,
  });
  final void Function(ProductDetails details) onFound;

  @override
  State<PromoCodeSearch> createState() => _PromoCodeSearchState();
}

class _PromoCodeSearchState extends State<PromoCodeSearch> {
  bool _isLoading = false;
  String _promoCode = "";
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "",
      trailing: const [CancelButton()],
      children: [
        Section(
          "Promo Code",
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cell(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Field(
                labelText: "Code",
                autocorrect: false,
                onChanged: (v) {
                  setState(() {
                    _promoCode = v;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        WrappedButton(
          title: "Search",
          type: WrappedButtonType.main,
          center: true,
          isLoading: _isLoading,
          onTap: () {
            _search(context, dmodel);
          },
        ),
      ],
    );
  }

  Future<void> _search(BuildContext context, DataModel dmodel) async {
    if (_promoCode.isEmpty) {
      snackbarErr(context, "The promo code cannot be empty");
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      var response = await dmodel.client.fetch("/promoCode/$_promoCode");
      if (response.statusCode == 404) {
        snackbarErr(context, "Promo code not found!");
      } else if (response.statusCode != 200) {
        snackbarErr(context, "There was an issue searching for promo codes");
        throw "there was an issue searching for promo codes";
      } else {
        // check if the found promo code is valid on the store
        var body = jsonDecode(response.body);
        var productId = body['body']['product'];
        final ProductDetailsResponse resp = await InAppPurchase.instance
            .queryProductDetails(<String>{productId});
        if (resp.error != null || resp.productDetails.isEmpty) {
          snackbarErr(context, "Promo code not found!");
        } else {
          widget.onFound(resp.productDetails[0]);
          dmodel.currentPromoCode = body['body']['promo_code'];
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      print(e);
      NewrelicMobile.instance.recordError(
        e,
        StackTrace.current,
        attributes: {"err_code": "promo_code_search"},
      );
    }
    setState(() {
      _isLoading = false;
    });
  }
}
