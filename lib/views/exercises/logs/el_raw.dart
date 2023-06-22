import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/views/root.dart';

class ELRaw extends StatelessWidget {
  const ELRaw({super.key});

  @override
  Widget build(BuildContext context) {
    var elmodel = Provider.of<ELModel>(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: elmodel.logs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: index < elmodel.logs.length - 1 ? 8 : 0),
          child: ELCell(log: elmodel.logs[index]),
        );
      },
    );
  }
}
