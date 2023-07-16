import 'package:flutter/material.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/data/collection.dart';
import 'package:workout_notepad_v2/text_themes.dart';
import 'package:workout_notepad_v2/utils/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_detail.dart';
import 'package:workout_notepad_v2/views/collection/collection_progress_bar.dart';

class CollectionCell extends StatefulWidget {
  const CollectionCell({
    super.key,
    required this.collection,
  });
  final Collection collection;

  @override
  State<CollectionCell> createState() => _CollectionCellState();
}

class _CollectionCellState extends State<CollectionCell> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                    widget.collection.title,
                    style: ttSubTitle(context),
                  ),
                ),
              ],
            ),
            CollectionProgressBar(collection: widget.collection),
            if (widget.collection.nextItem != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(2.0),
                        child: Icon(
                          Icons.today_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.collection.nextItem!.workout!.title),
                          Text(
                            widget.collection.nextItem!.dateStr,
                            style: TextStyle(
                              color: AppColors.subtext(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Container()),
                Expanded(
                  child: WrappedButton(
                    title: "Details",
                    bg: AppColors.cell(context)[600],
                    center: true,
                    onTap: () {
                      navigate(
                        context: context,
                        builder: (context) => CollectionDetail(
                          collection: widget.collection,
                          onStateChange: () => setState(() {}),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
