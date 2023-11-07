import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/main.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class SubscriptionLoading extends StatefulWidget {
  const SubscriptionLoading({super.key});

  @override
  State<SubscriptionLoading> createState() => _SubscriptionLoadingState();
}

class _SubscriptionLoadingState extends State<SubscriptionLoading> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "",
      children: [
        const SizedBox(height: 16),
        _content(context, dmodel),
      ],
    );
  }

  Widget _content(BuildContext context, DataModel dmodel) {
    switch (dmodel.paymentLoadStatus) {
      case PaymentLoadStatus.loading:
        return _loading(context);
      case PaymentLoadStatus.none:
      case PaymentLoadStatus.complete:
        return _complete(context);
      case PaymentLoadStatus.paymentError:
      case PaymentLoadStatus.verifyError:
      case PaymentLoadStatus.error:
        return _error(context, dmodel);
    }
  }

  Widget _loading(BuildContext context) {
    return _generic(
      context,
      LoadingIndicator(
        color: Theme.of(context).colorScheme.primary,
        scaleFactor: 2,
      ),
      Text(
        "Processing Your Payment",
        style: ttLabel(context),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _error(BuildContext context, DataModel dmodel) {
    return _generic(
      context,
      Icon(Icons.error, color: Colors.red[400], size: 75),
      Column(
        children: [
          Text(
            _errorMessage(dmodel),
            textAlign: TextAlign.center,
            style: ttLabel(context),
          ),
          const SizedBox(height: 16),
          if (dmodel.paymentLoadStatus == PaymentLoadStatus.verifyError)
            Column(
              children: [
                WrappedButton(
                  title: "Contact Support",
                  center: true,
                  type: WrappedButtonType.main,
                  onTap: () {
                    launchSupportPage(context, dmodel.user!, "Premium Issue");
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          WrappedButton(
            title: "Return",
            center: true,
            type: WrappedButtonType.standard,
            onTap: () {
              dmodel.paymentLoadStatus = PaymentLoadStatus.none;
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  Widget _complete(BuildContext context) {
    return _generic(
      context,
      Icon(
        Icons.check_circle_outline_rounded,
        color: Theme.of(context).colorScheme.primary,
        size: 75,
      ),
      Column(
        children: [
          Text(
            "Successfully subscribed to premium!",
            style: ttLabel(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          WrappedButton(
            title: "Complete Your Purchase",
            center: true,
            type: WrappedButtonType.main,
            onTap: () {
              RestartWidget.restartApp(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _generic(BuildContext context, Widget content, Widget label) {
    return Column(
      children: [
        SizedBox(
          height: 75,
          child: Center(
            child: content,
          ),
        ),
        const SizedBox(height: 16),
        label
      ],
    );
  }

  String _errorMessage(DataModel dmodel) {
    switch (dmodel.paymentLoadStatus) {
      case PaymentLoadStatus.paymentError:
        return "There was an issue with your payment method";
      case PaymentLoadStatus.verifyError:
        return "There was an issue verifying your purchase";
      default:
        return "There was an issue processing the purchase";
    }
  }
}
