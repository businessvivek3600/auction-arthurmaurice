// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import '../database/init_get_storages.dart';
import '/utils/my_logger.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '/constants/asset_constants.dart';

import '../utils/picture_utils.dart';

ValueNotifier<bool> devicePreviewEnabled = ValueNotifier<bool>(false);

class DevicePreviewService {
  DevicePreviewService._();
  static DevicePreviewService get instance => DevicePreviewService._();

  final GetStorage _box = GetStorage(LocalStorage.appBox);
  static const _storageKey = 'device_preview';

  Future<void> init() async {
    // log('DevicePreview: init');
    try {
      var val = _box.read(_storageKey) ?? kDebugMode;
      devicePreviewEnabled.value = val;
      // log('DevicePreview: $_isEnable');
    } catch (e) {
      log('DevicePreview: $e');
    }
    // await Future.delayed(const Duration(milliseconds: 2000)).then((value) => log('DevicePreview: check now-> $_isEnable'));
  }

  TargetPlatform get platform => DevicePreview.platform(Get.context!);

  Future<void> toggle(BuildContext context) async {
    await _box.write(_storageKey, !devicePreviewEnabled.value);
    devicePreviewEnabled.value = !devicePreviewEnabled.value;
    // var currentPlatform = DevicePreview.platform(context);
    // if (currentPlatform == TargetPlatform.iOS) {
    //   showCupertinoDialog(
    //       context: context,
    //       builder: (_) => dialog(currentPlatform == TargetPlatform.iOS));
    // } else {
    //   showDialog(
    //       context: context,
    //       builder: (_) => dialog(currentPlatform == TargetPlatform.iOS));
    // }
  }

  Widget dialog(bool iOS) {
    var title = iOS ? 'Restart your app' : 'Restart your app';
    var content = iOS
        ? 'Restart your app to apply the changes'
        : 'Restart your app to apply the changes';
    var action = iOS ? 'Restart' : 'Restart';
    return iOS
        ? CupertinoAlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              CupertinoDialogAction(
                child: Text(action),
                onPressed: () {
                  exit(0);
                },
              ),
            ],
          )
        : AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                child: Text(action),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
  }
}

class EnableDevicePreview extends StatelessWidget {
  const EnableDevicePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: devicePreviewEnabled,
        builder: (context, value, child) {
          return SwitchListTile(
            controlAffinity: ListTileControlAffinity.platform,
            activeThumbImage: assetImageProvider(MyPng.fire),
            title: const Text('Enable Device Preview'),
            subtitle: const Text('Toggle to enable/disable device preview'),
            value: value,
            dense: true,
            dragStartBehavior: DragStartBehavior.start,
            thumbIcon: MaterialStateProperty.resolveWith<Icon?>((states) {
              if (states.contains(MaterialState.selected)) {
                return null;
              } else {
                return const Icon(Icons.change_circle_rounded,
                    color: Colors.pinkAccent);
              }
            }),
            onChanged: (value) {
              DevicePreviewService.instance.toggle(context);
            },
          );
        });
  }
}

class CaptureScreenShot extends StatefulWidget {
  const CaptureScreenShot(
      {super.key, required this.captureKey, this.onCapture});
  final GlobalKey captureKey;
  final Function(Image? image)? onCapture;

  @override
  State<CaptureScreenShot> createState() => _CaptureScreenShotState();
}

class _CaptureScreenShotState extends State<CaptureScreenShot> {
  Future<Image?> capturePng(GlobalKey key) async {
    RenderObject? boundary = key.currentContext?.findRenderObject();
    RenderRepaintBoundary? repaintBoundary =
        (boundary is RenderRepaintBoundary) ? boundary : null;
    ui.Image image = await repaintBoundary!.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData != null
        ? Image.memory(byteData.buffer.asUint8List())
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      titleAlignment: ListTileTitleAlignment.center,
      title: const Text('Capture Screen Shot'),
      subtitle: const Text('Capture Screen Shot'),
      trailing: IconButton(
        icon: const Icon(CupertinoIcons.camera),
        onPressed: () async {
          var image = await capturePng(widget.captureKey);
          logger.i('image captured $image');
          if (image != null && widget.onCapture != null) {
            widget.onCapture!(image);
          }
        },
      ),
    );
  }
}
