import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_detail.dart';
import 'package:workout_notepad_v2/views/collection/collection_progress_bar.dart';

class CollectionCell extends StatelessWidget {
  const CollectionCell({
    super.key,
    required this.collection,
  });
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return Clickable(
      onTap: () {
        navigate(
          context: context,
          builder: (context) => CollectionDetail(collection: collection),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cell(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      collection.title,
                      style: ttSubTitle(context),
                    ),
                  ),
                ],
              ),
              CollectionProgressBar(collection: collection),
            ],
          ),
        ),
      ),
    );
  }
}
