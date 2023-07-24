import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';

enum PickedFileType { video, image }

Future<File?> pickMedia(ImageSource source,
    {required PickedFileType type}) async {
  final picker = ImagePicker();
  XFile? pickedAsset;
  if (type == PickedFileType.video) {
    pickedAsset = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 20),
    );
  } else {
    pickedAsset = await picker.pickImage(
      source: source,
    );
  }

  if (pickedAsset != null) {
    return File(pickedAsset.path);
  } else {
    print("No asset was selected");
  }
  return null;
}

Future<String> saveMedia(File file, String exerciseId) async {
  final pickedExtension = path.extension(file.path);
  final fileName = "$exerciseId$pickedExtension";
  final directory = await getApplicationDocumentsDirectory();
  final savePath = path.join(directory.path, fileName);
  await file.copy(savePath);
  return savePath;
}

Future<void> promptMedia(
  BuildContext context,
  String exerciseId,
  Function(Tuple2<File?, PickedFileType>) onSelected,
) async {
  await showFloatingSheet(
    context: context,
    builder: (builder) {
      return FloatingSheet(
        title: "Select Asset",
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Section(
              "Images",
              child:
                  ContainedList<Tuple4<String, IconData, Color, AsyncCallback>>(
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: EdgeInsets.zero,
                children: [
                  Tuple4(
                    "Capture with camera",
                    Icons.camera_alt_rounded,
                    Colors.green[300]!,
                    () async {
                      Navigator.of(context).pop();
                      var file = await pickMedia(
                        ImageSource.camera,
                        type: PickedFileType.image,
                      );
                      onSelected(Tuple2(file, PickedFileType.image));
                    },
                  ),
                  Tuple4(
                    "Pick from gallery",
                    Icons.image_rounded,
                    Colors.blue[300]!,
                    () async {
                      Navigator.of(context).pop();
                      var file = await pickMedia(
                        ImageSource.gallery,
                        type: PickedFileType.image,
                      );
                      onSelected(Tuple2(file, PickedFileType.image));
                    },
                  ),
                ],
                onChildTap: (context, item, index) async => await item.v4(),
                childBuilder: (context, item, index) {
                  return WrappedButton(
                    title: item.v1,
                    icon: item.v2,
                    iconBg: item.v3,
                  );
                },
              ),
            ),
            Section(
              "Videos",
              child:
                  ContainedList<Tuple4<String, IconData, Color, AsyncCallback>>(
                leadingPadding: 0,
                trailingPadding: 0,
                childPadding: EdgeInsets.zero,
                children: [
                  Tuple4(
                    "Capture with camera",
                    Icons.camera_alt_rounded,
                    Colors.red[300]!,
                    () async {
                      Navigator.of(context).pop();
                      var file = await pickMedia(
                        ImageSource.camera,
                        type: PickedFileType.video,
                      );
                      onSelected(Tuple2(file, PickedFileType.video));
                    },
                  ),
                  Tuple4(
                    "Pick from gallery",
                    Icons.image_rounded,
                    Colors.purple[300]!,
                    () async {
                      Navigator.of(context).pop();
                      var file = await pickMedia(
                        ImageSource.gallery,
                        type: PickedFileType.video,
                      );
                      onSelected(Tuple2(file, PickedFileType.video));
                    },
                  ),
                ],
                onChildTap: (context, item, index) async => await item.v4(),
                childBuilder: (context, item, index) {
                  return WrappedButton(
                    title: item.v1,
                    icon: item.v2,
                    iconBg: item.v3,
                  );
                },
              ),
            ),
          ],
        ),
      );
    },
  );
}
