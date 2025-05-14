import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/data_model.dart';
import 'package:workout_notepad_v2/utils/color.dart';
import 'package:workout_notepad_v2/views/profile/paywall.dart';

class BlurIfNotSubscription extends StatelessWidget {
  const BlurIfNotSubscription({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = context.read();
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        if (!dmodel.hasValidSubscription())
          Container(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: Container(
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.0)),
              ),
            ),
          ),
        if (!dmodel.hasValidSubscription())
          Clickable(
            onTap: () => showPaywall(context),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.text(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                height: 200,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_rounded,
                          color: AppColors.text(context).withValues(alpha: 0.5),
                          size: 40,
                        ),
                        Text(
                          "Looking for more features?",
                          // style: ttSubTitle(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          child: Text(
                            "Explore Premium",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
