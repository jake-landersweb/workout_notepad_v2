import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/logger.dart';
import 'package:workout_notepad_v2/main.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';

class PromoCode {
  final int id;
  final String code;
  final int durationSec;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromoCode({
    required this.id,
    required this.code,
    required this.durationSec,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a MyObject from a JSON map.
  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as int,
      code: json['code'] as String,
      durationSec: json['durationSec'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Creates a list of MyObject from a JSON list.
  static List<PromoCode> listFromJson(List<dynamic> list) {
    return list
        .map((item) => PromoCode.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  String formatDuration() {
    int totalSeconds = durationSec;
    if (totalSeconds < 0) {
      return "0 seconds";
    }
    if (totalSeconds == 0) {
      return "0 seconds";
    }

    const int secondsInMinute = 60;
    const int secondsInHour = secondsInMinute * 60;
    const int secondsInDay = secondsInHour * 24;
    const int secondsInWeek = secondsInDay * 7;
    // Approximate month length
    const int secondsInMonth = secondsInDay * 30;

    if (totalSeconds >= secondsInMonth) {
      int months = totalSeconds ~/ secondsInMonth;
      return "$months month${months == 1 ? '' : 's'}";
    } else if (totalSeconds >= secondsInWeek) {
      int weeks = totalSeconds ~/ secondsInWeek;
      return "$weeks week${weeks == 1 ? '' : 's'}";
    } else if (totalSeconds >= secondsInDay) {
      int days = totalSeconds ~/ secondsInDay;
      return "$days day${days == 1 ? '' : 's'}";
    } else if (totalSeconds >= secondsInHour) {
      int hours = totalSeconds ~/ secondsInHour;
      return "$hours hour${hours == 1 ? '' : 's'}";
    } else if (totalSeconds >= secondsInMinute) {
      int minutes = totalSeconds ~/ secondsInMinute;
      return "$minutes minute${minutes == 1 ? '' : 's'}";
    } else {
      return "$totalSeconds second${totalSeconds == 1 ? '' : 's'}";
    }
  }
}

class ViewPromoCodeV2 extends StatefulWidget {
  const ViewPromoCodeV2({
    super.key,
    required this.scrollableArea,
    this.scrollController,
  });
  final ScrollController? scrollController;
  final GlobalKey scrollableArea;

  @override
  State<ViewPromoCodeV2> createState() => _ViewPromoCodeV2State();
}

class _ViewPromoCodeV2State extends State<ViewPromoCodeV2> {
  late TextEditingController _controller;
  bool _isLoadingSearch = false;
  bool _isLoadingApply = false;
  PromoCode? _pc;

  @override
  void initState() {
    _controller = TextEditingController();
    logger.raw("pc init");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = context.watch<DataModel>();

    return HeaderBar.sheet(
      title: "Promo Code",
      scrollController: widget.scrollController,
      scrollKey: widget.scrollableArea,
      children: [
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cell(context),
            border: Border.all(color: AppColors.border(context), width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.fromLTRB(16, 0, 8, 0),
          child: Field(
            labelText: "code",
            charLimit: 30,
            showCharacters: true,
            showBackground: true,
            controller: _controller,
            onChanged: (v) {},
          ),
        ),
        const SizedBox(height: 16),
        WrappedButton(
          title: "Search",
          isLoading: _isLoadingSearch,
          borderColor: AppColors.border(context),
          type: WrappedButtonType.standard,
          center: true,
          onTap: () => _search(context, dmodel, _controller.text),
        ),
        const SizedBox(height: 32),
        if (_pc != null) _promoCodeView(context, _pc!),
      ],
    );
  }

  Widget _promoCodeView(BuildContext context, PromoCode pc) {
    var dmodel = context.watch<DataModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              "Code: ${pc.code.toUpperCase()}",
              style: ttTitle(context),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Clickable(
                onTap: () {
                  _setClipboardData(context, pc.code);
                },
                child: Icon(
                  Icons.copy_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.schedule_outlined,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Text("Valid Duration: ${pc.formatDuration()}",
                style: ttLabel(context)),
          ],
        ),
        const SizedBox(height: 16),
        Clickable(
          onTap: () {
            setState(() {
              _pc = null;
            });
          },
          child: Text(
            "Clear",
            style: ttcaption(context),
          ),
        ),
        const SizedBox(height: 32),
        WrappedButton(
          title: "Apply",
          type: WrappedButtonType.main,
          center: true,
          isLoading: _isLoadingApply,
          onTap: () {
            _apply(context, dmodel, pc.code);
          },
        )
      ],
    );
  }

  Future<void> _search(
    BuildContext context,
    DataModel dmodel,
    String searchText,
  ) async {
    if (searchText.isEmpty) {
      snackbarErr(context, "The code cannot be empty");
      return;
    }
    try {
      setState(() {
        _isLoadingSearch = true;
      });

      var resp =
          await dmodel.purchaseClient.fetch("/v2/promocodes/$searchText");

      if (resp.statusCode != 200) {
        logger.warn("failed to find the promo code",
            {"promoCode": searchText, "statusCode": resp.statusCode});
        snackbarErr(context, resp.body);
        return;
      }

      // parse into object
      setState(() {
        _pc = PromoCode.fromJson(jsonDecode(resp.body));
      });
    } catch (e) {
      snackbarErr(
          context, "There was an unknown error searching for the promo code");
    } finally {
      setState(() {
        _isLoadingSearch = false;
      });
    }
  }

  Future<void> _apply(
    BuildContext context,
    DataModel dmodel,
    String code,
  ) async {
    try {
      setState(() {
        _isLoadingApply = true;
      });

      var resp = await dmodel.purchaseClient
          .fetch("/v2/users/${dmodel.user!.userId}/setPromoCode/$code");

      if (resp.statusCode != 200) {
        logger.warn("failed to apply the promo code",
            {"promoCode": code, "statusCode": resp.statusCode});
        snackbarErr(context, resp.body);
        return;
      }

      snackbarStatus(context,
          "Successfully set promo code: '$code'. Restarting the application ...");
      await Future.delayed(const Duration(seconds: 2));
      RestartWidget.restartApp(context);
    } catch (_) {
      snackbarErr(
          context, "There was an unknown error applying this promo code");
    } finally {
      setState(() {
        _isLoadingApply = false;
      });
    }
  }

  Future<void> _setClipboardData(BuildContext context, String data) async {
    try {
      await Clipboard.setData(ClipboardData(text: data));
      snackbarStatus(context, "Successfully copied code");
    } catch (_) {
      snackbarErr(context, "Failed to copy code");
    }
  }
}
