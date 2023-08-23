import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/views/profile/subscriptions.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELRaw extends StatelessWidget {
  const ELRaw({super.key});

  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    var dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: elmodel.logs.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: index < elmodel.logs.length - 1 ? 8 : 0),
              child: ELCell(log: elmodel.logs[index]),
            );
          },
        ),
        if (dmodel.user!.subscriptionType == SubscriptionType.none)
          Column(
            children: [
              Text(
                "Looking for more of your data?",
                style: ttLabel(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              WrappedButton(
                title: "Explore Premium",
                icon: Icons.star,
                iconBg: Colors.amber[700],
                onTap: () {
                  cupertinoSheet(
                    context: context,
                    builder: (context) => const Subscriptions(),
                  );
                },
              ),
            ],
          ),
        const SizedBox(height: 50),
      ],
    );
  }
}
