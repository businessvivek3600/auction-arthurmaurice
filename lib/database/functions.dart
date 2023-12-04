import 'dart:io';

import 'package:action_tds/utils/utils_index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;
import 'package:xml/xml.dart' as xml;

import 'app_update/upgrader.dart';

exitTheApp() async {
  if (Platform.isAndroid) {
    SystemNavigator.pop();
  } else if (Platform.isIOS) {
    exit(0);
  } else {
    print('App exit failed!');
  }
}

Future<CroppedFile?> cropImage(String path) async {
  var context = Get.context!;
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 100,
    uiSettings: [
      AndroidUiSettings(
          toolbarTitle: 'Resize your image',
          toolbarColor: getTheme(context).primaryColor,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
      IOSUiSettings(
        title: 'Resize your image',
        showActivitySheetOnDone: false,
        showCancelConfirmationDialog: true,
        cancelButtonTitle: 'Cancel',
        doneButtonTitle: 'Update Profile',
        hidesNavigationBar: true,
        resetAspectRatioEnabled: true,
        aspectRatioPickerButtonHidden: true,
        aspectRatioLockEnabled: true,
        aspectRatioLockDimensionSwapEnabled: true,
      ),
      WebUiSettings(
        context: context,
        presentStyle: CropperPresentStyle.dialog,
        boundary: const CroppieBoundary(
          width: 520,
          height: 520,
        ),
        viewPort:
            const CroppieViewPort(width: 480, height: 480, type: 'circle'),
        enableExif: true,
        enableZoom: true,
        showZoomer: true,
      ),
    ],
  );
  return croppedFile;
}

///save image to local
Future<String> downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response respose = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(respose.bodyBytes);
  return filePath;
}

///xml
Future<Map<String, String>> loadStringXml(String path) async {
  String xmlString = await rootBundle.loadString(path);
  Map<String, String> stringMap = parseStringXml(xmlString);
  return stringMap;
}

Map<String, String> parseStringXml(String xmlString) {
  var document = xml.XmlDocument.parse(xmlString);
  var stringNodes = document.findAllElements('string').toList();

  Map<String, String> stringMap = {};
  logger.i('parseStringXml stringNodes: $stringNodes');
  for (var node in stringNodes) {
    var name = node.getAttribute('name');
    var value = node.innerText;
    if (name != null) {
      stringMap[name] = value.validate();
    }
  }

  return stringMap;
}

// working update
checkForUpdate(BuildContext context) async {
  Upgrader upgrader = Upgrader(
    debugLogging: true,
    showIgnore: false,
    showLater: false,
    debugDisplayAlways: false,
    // shouldPopScope: () => false,
    dialogStyle: Platform.isIOS
        ? UpgradeDialogStyle.cupertino
        : UpgradeDialogStyle.material,
    willDisplayUpgrade: (
        {String? appStoreVersion,
        required bool display,
        String? installedVersion,
        String? minAppVersion}) async {
      logger.i(
          'appStoreVersion: $appStoreVersion display: $display '
          'installedVersion: $installedVersion minAppVersion: $minAppVersion',
          tag: 'checkForUpdate');
    },
    backgroundColor: getTheme(context).scaffoldBackgroundColor,
    borderRadius: 10,
    textColor: Platform.isIOS ? Colors.black : Colors.white,
  );
  try {
    await upgrader
        .initialize()
        .then((value) => upgrader.checkVersion(context: context));
  } catch (e) {
    logger.e('upgrader.initialize()',
        error: e, stackTrace: StackTrace.current, tag: 'checkForUpdate');
  }
}
