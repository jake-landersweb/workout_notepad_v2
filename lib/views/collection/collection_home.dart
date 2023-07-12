import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';
import 'package:workout_notepad_v2/views/collection/collection_cell.dart';

class CollectionHome extends StatefulWidget {
  const CollectionHome({super.key});

  @override
  State<CollectionHome> createState() => _CollectionHomeState();
}

class _CollectionHomeState extends State<CollectionHome> {
  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return HeaderBar(
      title: "Collections",
      isLarge: true,
      trailing: [
        AddButton(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              enableDrag: false,
              builder: (context) => CECollection(
                onCreate: (collection) => dmodel.refreshCollections(),
              ),
            );
          },
        )
      ],
      children: [
        const SizedBox(height: 16),
        for (var i in dmodel.collections)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: CollectionCell(collection: i),
          ),
      ],
    );
  }
}
