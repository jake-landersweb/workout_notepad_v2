// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newrelic_mobile/newrelic_mobile.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';
import 'package:workout_notepad_v2/components/root.dart';
import 'package:workout_notepad_v2/model/env.dart';
import 'package:workout_notepad_v2/utils/tuple.dart';
import 'package:aws_signature_v4/aws_signature_v4.dart';
import 'package:aws_common/aws_common.dart';
import 'package:http/http.dart' as http;

enum AppFileType { video, image, none }

class AppFile {
  File? _file;
  late String _objectId;
  bool _cached = false;
  String _extension = "";

  String get filename => _objectId + _extension;

  // when the file needs to be created
  AppFile.init({required String objectId}) {
    _objectId = objectId;
  }

  // init from an existing file
  AppFile.fromFile({required File file}) {
    _file = file;
    _objectId = path.basenameWithoutExtension(file.path);
    _extension = path.extension(file.path);
  }

  // for creating from an object and extension
  AppFile.fromFilenameSync({required String filename}) {
    var tmp = filename.split(".");
    _extension = ".${tmp.removeLast()}";
    _objectId = tmp.join(".");
  }
  static Future<AppFile> fromFilename({
    required String filename,
  }) async {
    var af = AppFile.fromFilenameSync(filename: filename);
    await af.getCached();
    return af;
  }

  // source from an image downloaded on the internet
  static Future<AppFile?> fromUrl({
    required String objectId,
    required String url,
  }) async {
    try {
      print("fetching image with url: $url");

      // fetch the file from the url
      var response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        print("the response code was not 200");
        return null;
      }

      // source the extension
      String extension = path.extension(Uri.parse(url).pathSegments.last);
      if (!imageExtensions.contains(extension)) {
        if (response.headers.containsKey("content-type")) {
          // use the request headers
          var contentType = response.headers['content-type']!.split("/").last;
          extension = ".$contentType";
          print("contentType: $contentType");
        } else {
          extension = ".jpg";
        }
      }
      print("url extension: $extension");

      final directory = await getTemporaryDirectory();
      var tmpFile = File('${directory.path}/$objectId$extension');
      await tmpFile.writeAsBytes(response.bodyBytes);

      var appFile = AppFile.init(objectId: objectId);
      appFile._extension = extension;
      appFile._file = tmpFile;

      return appFile;
    } catch (e, stack) {
      print(e);
      print(stack);
      return null;
    }
  }

  /// ONLY USE METHOD IF SURE FILE EXISTS
  File? get file {
    return _file;
  }

  void setFile({
    required File file,
  }) async {
    _cached = false;
    _file = file;
    // add extension onto the passed object id
    _extension = path.extension(_file!.path);

    // delete from cache
    await deleteCachedImage(filename);
  }

  Future<File?> getCached() async {
    if (_objectId.isEmpty || _extension.isEmpty) {
      return null;
    }
    if (_file == null || !await _file!.exists() || !_cached) {
      _file = await _getCachedFile(filename);
    }

    return _file;
  }

  Future<void> ejectFromCache() async {
    await deleteCachedImage(filename);
  }

  Future<void> deleteFile() async {
    if (_file == null) {
      print("file doesnt exist");
      return;
    }
    print("Deleting file");
    // create an image provider and evict this file from the cache
    final imageProvider = FileImage(_file!);
    imageProvider.evict();

    // clear from memory
    _file = null;
    _cached = false;
    await deleteCachedImage(filename);
  }

  AppFileType get type {
    if (_file == null) {
      print("The file is null");
      return AppFileType.none;
    }
    if (_objectId.isEmpty) {
      print("The object Id is empty");
      return AppFileType.none;
    }

    if (imageExtensions.contains(_extension)) {
      return AppFileType.image;
    } else if (videoExtensions.contains(_extension)) {
      return AppFileType.video;
    } else {
      return AppFileType.none;
    }
  }

  Future<bool> upload(
    String userId, {
    bool compress = true,
  }) async {
    if (compress) {
      await this.compress();
    }
    if (_file == null || _objectId.isEmpty || _extension.isEmpty) {
      return false;
    }
    return _uploadFile(
      _file!,
      filename,
    );
  }

  Future<bool> compress() async {
    if (type == AppFileType.none) {
      print("[APP FILE] The file is null, or is invalid");
      return false;
    }
    print("[APP FILE] Compressing file ...");
    print(
        "Original size: ${(await _file!.length() / 1024).toStringAsFixed(2)} KB");

    File? tmpFile;
    if (type == AppFileType.image) {
      tmpFile = await _compressImage(_file!);
    } else {
      tmpFile = await _compressVideo(_file!);
    }

    if (tmpFile == null) {
      print("[APP FILE] There was an issue compressing the file.");
      NewrelicMobile.instance.recordError(
        "There was an issue compressing the ${type == AppFileType.video ? 'video' : 'image'}",
        StackTrace.current,
        attributes: {
          "err_code":
              type == AppFileType.video ? 'video_compress' : 'image_compress'
        },
      );
      return false;
    }

    print(
      "Compressed size: ${(await tmpFile.length() / 1024).toStringAsFixed(2)} KB",
    );

    // set the tmp file as the app file
    _file = await tmpFile.copy(_file!.path);

    // delete the tmp file
    var response = await _deleteFile(tmpFile);
    if (!response) {
      print("[APP FILE] There was an issue deleting the file");
    }
    return true;
  }

  Future<bool> deleteAWS() async {
    return await _deleteFileAWS(filename);
  }

  Widget getRenderer() {
    if (type == AppFileType.none) {
      throw "There was an issue getting the renderer";
    }
    switch (type) {
      case AppFileType.video:
        return VideoRenderder(videoFile: file!);
      case AppFileType.image:
        final imageProvider = FileImage(file!);
        return Image(
          image: imageProvider,
          fit: BoxFit.fitHeight,
        );
      case AppFileType.none:
        return Container(); // TODO -- handle
    }
  }
}

Future<File?> pickMedia(
  ImageSource source, {
  required AppFileType type,
}) async {
  final picker = ImagePicker();
  XFile? pickedAsset;
  if (type == AppFileType.video) {
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

// Future<String> saveMedia(File file, String exerciseId) async {
//   final pickedExtension = path.extension(file.path);
//   final fileName = "$exerciseId$pickedExtension";
//   final directory = await getApplicationDocumentsDirectory();
//   final savePath = path.join(directory.path, fileName);
//   await file.copy(savePath);
//   return savePath;
// }

Future<void> promptMedia({
  required BuildContext context,
  required Function(File?) onSelected,
  bool allowsVideo = true,
}) async {
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
                        type: AppFileType.image,
                      );
                      onSelected(file);
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
                        type: AppFileType.image,
                      );
                      onSelected(file);
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
            if (allowsVideo)
              Section(
                "Videos",
                child: ContainedList<
                    Tuple4<String, IconData, Color, AsyncCallback>>(
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
                          type: AppFileType.video,
                        );
                        onSelected(file);
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
                          type: AppFileType.video,
                        );
                        onSelected(file);
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

/// Generates a signed download url for an object in s3
Future<String> _getPresignedUrl(String objectKey) async {
  var signer = _getAwsSigner();
  final scope = AWSCredentialScope(
    region: "us-west-2",
    service: AWSService.s3,
  );
  final serviceConfiguration = S3ServiceConfiguration();

  final request = AWSHttpRequest(
    method: AWSHttpMethod.get,
    uri: Uri.https(AWS_S3_BUCKET, objectKey),
  );

  final signedRequest = await signer.presign(
    request,
    credentialScope: scope,
    serviceConfiguration: serviceConfiguration,
    expiresIn: const Duration(seconds: 10),
  );

  return signedRequest.toString();
}

/// Retrieves a file from cache. If it does not find an object,
/// it downloads from s3. If the file does not exist in s3,
/// an exception will be raised
Future<File?> _getCachedFile(String objectKey) async {
  print("fetching file from cache with id: $objectKey");
  // Construct the file path under the cache directory
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File file = File('$tempPath/$objectKey');

  // if (await file.exists()) {
  //   print("exists, deleting.");
  //   await file.delete();
  // }

  if (await file.exists()) {
    print("file exists in cache");
    // If the file exists in cache, return it
    return file;
  } else {
    print("file does not exist in cache");
    // If the file doesn't exist in cache, try to download it
    try {
      // Assuming a function getSignedUrl exists that can generate signed URL
      String signedUrl = await _getPresignedUrl(objectKey);

      // Download the file from the signedUrl
      var response = await http.get(Uri.parse(signedUrl));

      if (response.statusCode == 200) {
        print("successfully fetched file from the internet");
        // If server returns an OK response, write the file to cache
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        print("The server response was not 200: '${response.statusCode}'");
        return null;
      }
    } catch (e) {
      // If there's an error (like no internet), return null
      print('Failed to download file: $e');
      return null;
    }
  }
}

Future<void> deleteCachedImage(String objectId) async {
  // if file with object exists in cache, delete it
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  File f = File('$tempPath/$objectId');

  if (await f.exists()) {
    print("A file with this key exists in cache, deleting it.");
    await f.delete();
  }
}

Future<bool> _uploadFile(
  File file,
  String filename,
) async {
  try {
    final fileStream = file.openRead();
    final uploadRequest = AWSStreamedHttpRequest.put(
      Uri.https(AWS_S3_BUCKET, filename),
      body: fileStream,
      headers: {
        AWSHeaders.host: AWS_S3_BUCKET,
        AWSHeaders.contentType: 'text-plain',
      },
    );

    var signer = _getAwsSigner();
    final scope = AWSCredentialScope(
      region: "us-west-2",
      service: AWSService.s3,
    );
    final serviceConfiguration = S3ServiceConfiguration();

    final signedUploadRequest = await signer.sign(
      uploadRequest,
      credentialScope: scope,
      serviceConfiguration: serviceConfiguration,
    );

    final uploadResponse = await signedUploadRequest.send().response;
    if (uploadResponse.statusCode != 200) {
      throw Exception("There was an issue uploading the asset");
    }

    return true;
  } catch (e) {
    NewrelicMobile.instance.recordError(
      e,
      StackTrace.current,
      attributes: {"err_code": "media_upload"},
    );
    print(e);
    return false;
  }
}

Future<bool> _deleteFileAWS(String objectId) async {
  try {
    final uploadRequest = AWSStreamedHttpRequest.delete(
      Uri.https(AWS_S3_BUCKET, objectId),
    );

    var signer = _getAwsSigner();
    final scope = AWSCredentialScope(
      region: "us-west-2",
      service: AWSService.s3,
    );
    final serviceConfiguration = S3ServiceConfiguration();

    final signedUploadRequest = await signer.sign(
      uploadRequest,
      credentialScope: scope,
      serviceConfiguration: serviceConfiguration,
    );

    final uploadResponse = await signedUploadRequest.send().response;
    if (uploadResponse.statusCode != 204) {
      throw Exception(
        "There was an issue uploading the asset. Status: ${uploadResponse.statusCode}",
      );
    }
    return true;
  } catch (e) {
    // NewrelicMobile.instance.recordError(
    //   e,
    //   StackTrace.current,
    //   attributes: {"err_code": "image_delete"},
    // );
    print(e);
    return false;
  }
}

Future<File?> _compressImage(File file) async {
  final filePath = file.absolute.path;

  // Get filename without extension
  String filename = path.basename(filePath);

  // Get temporary directory
  Directory tempDir = await getTemporaryDirectory();

  // Create output file path in the temp directory with the same filename
  String outputPath = path.join(tempDir.path, '$filename.jpg');

  final compressedImage = await FlutterImageCompress.compressAndGetFile(
    filePath,
    outputPath,
    minWidth: 300,
    minHeight: 400,
    quality: 75,
  );

  if (compressedImage == null) {
    return null;
  }

  return File(compressedImage.path);
}

Future<File?> _compressVideo(File file) async {
  var mediaInfo = await VideoCompress.compressVideo(
    file.path,
    quality: VideoQuality.MediumQuality,
    deleteOrigin: false, // It's false by default
  );
  if (mediaInfo == null || mediaInfo.file == null) {
    return null;
  }
  return mediaInfo.file!;
}

Future<bool> _deleteFile(File file) async {
  try {
    if (await file.exists()) {
      await file.delete();
      print('File deleted successfully');
      return true;
    } else {
      print("The file does not exist.");
      return false;
    }
  } catch (e) {
    print('Failed to delete file: $e');
    NewrelicMobile.instance.recordError(
      "There was an issue deleting the file",
      StackTrace.current,
      attributes: {"err_code": "file_tmp_delete"},
    );
    return false;
  }
}

AWSSigV4Signer _getAwsSigner() {
  return const AWSSigV4Signer(
    credentialsProvider: AWSCredentialsProvider(
      AWSCredentials(
        AWS_ACCESS_KEY,
        AWS_SECRET_ACCESS_KEY,
      ),
    ),
  );
}

final List<String> imageExtensions = [
  '.jpg',
  '.jpeg',
  '.png',
  '.gif',
  '.bmp',
  '.webp',
  '.ico',
  '.cur',
  '.tiff',
  '.tif',
  '.ind',
  '.indd',
  '.indt',
  '.ai',
  '.heic',
  '.heif',
  '.svg',
  '.raw'
];

final List<String> videoExtensions = [
  '.mp4',
  '.m4v',
  '.mkv',
  '.webm',
  '.flv',
  '.vob',
  '.ogv',
  '.ogg',
  '.drc',
  '.gifv',
  '.mng',
  '.avi',
  '.mov',
  '.qt',
  '.wmv',
  '.yuv',
  '.rm',
  '.rmvb',
  '.asf',
  '.amv',
  '.mpg',
  '.mp2',
  '.mpeg',
  '.mpe',
  '.mpv',
  '.svi',
  '.3gp',
  '.3g2',
  '.mxf',
  '.roq',
  '.nsv',
  '.flv',
  '.f4v',
  '.f4p',
  '.f4a',
  '.f4b'
];
