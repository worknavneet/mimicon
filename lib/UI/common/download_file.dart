import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

Future<String> createFileFromString({required String base64}) async {
  final encodedStr = base64;
  Uint8List bytes = base64Decode(encodedStr);

  String newPath = "";

  if (Platform.isIOS) {
    Directory appDocDirectory = await getApplicationSupportDirectory();
    newPath = appDocDirectory.path;
  } else if (Platform.isAndroid) {
    print("print in android !");

    Directory appDocDirectory = await getTemporaryDirectory();
    print("print appDocDirectory ${appDocDirectory} !");

    newPath = appDocDirectory.path;
  }

  final myImagePath = '${newPath.toString()}/mimicon';

  final myDir = Directory(myImagePath);

  bool dirExists = await myDir.exists();

  if (!dirExists) {
    await myDir.create(recursive: true);
    File file = File(
        "${myDir.path}/mimicon-${DateTime.now().millisecondsSinceEpoch}.png");

    await file.writeAsBytes(bytes);
    return file.path;
  } else {
    File file = File(
        "${myDir.path}/mimicon-${DateTime.now().millisecondsSinceEpoch}.png");
    print("print exist Directory ${file.path} !");

    await file.writeAsBytes(bytes);
    await ImageGallerySaver.saveImage(file.readAsBytesSync(),
        quality: 100, name: "${DateTime.now()}.png");
    return file.path;
  }
}