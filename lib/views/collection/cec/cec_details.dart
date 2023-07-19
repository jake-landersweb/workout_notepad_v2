import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';

class CECDetails extends StatefulWidget {
  const CECDetails({super.key});

  @override
  State<CECDetails> createState() => _CECDetailsState();
}

class _CECDetailsState extends State<CECDetails> {
  @override
  Widget build(BuildContext context) {
    var cmodel = context.read<CECModel>();
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                "Lastly, add some details to your collection.",
                style: ttLabel(context),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  child: Field(
                    labelText: "Title",
                    value: cmodel.collection.title,
                    hasClearButton: true,
                    onChanged: (v) {
                      cmodel.collection.title = v;
                      setState(() {
                        cmodel.refresh();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cell(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
                  child: Field(
                    labelText: "Description",
                    value: cmodel.collection.description,
                    isLabeled: false,
                    maxLines: 5,
                    minLines: 5,
                    onChanged: (v) {
                      cmodel.collection.description = v;
                      setState(() {
                        cmodel.refresh();
                      });
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
