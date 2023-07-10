import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/views/collection/cec/root.dart';

class CollectionHome extends StatefulWidget {
  const CollectionHome({super.key});

  @override
  State<CollectionHome> createState() => _CollectionHomeState();
}

class _CollectionHomeState extends State<CollectionHome> {
  @override
  Widget build(BuildContext context) {
    return HeaderBar(
      title: "Collections",
      isLarge: true,
      trailing: [
        AddButton(
          onTap: () {
            showMaterialModalBottomSheet(
              context: context,
              enableDrag: false,
              builder: (context) => const CECollection(),
            );
          },
        )
      ],
      children: [],
    );
  }
}
