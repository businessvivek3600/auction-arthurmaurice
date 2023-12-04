import 'dart:io';

import 'package:action_tds/database/functions.dart';
import 'package:action_tds/utils/utils_index.dart';

import '../home_widget_index.dart';
import '/utils/my_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

enum HomeWidgetType { dashboard, notification }

enum HomeWidgetData {
  title,
  message,
  runningAuctionCount,
  upcomingAuctionCount,
  closedAuctionCount,
  lastUpdatedTime,
  promotionImage,
}

class HomeWidgetSetup {
  static const String tag = 'HomeWidgetSetup';

  /// Private constructor
  HomeWidgetSetup._privateConstructor();

  /// Singleton instance
  static final HomeWidgetSetup instance = HomeWidgetSetup._privateConstructor();
  void init(backgroundCallback) {
    HomeWidget.setAppGroupId('YOUR_GROUP_ID');
    HomeWidget.registerBackgroundCallback(backgroundCallback);
  }

  void didChangeDependencies() {
    _checkForWidgetLaunch();
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  Future<dynamic> sendData({
    String? title,
    String? message,
    Widget? renderWidget,
    String renderKey = 'dashIcon',
    Size? logicalSize,
    int? runnig,
    int? upcoming,
    int? closed,
    String? promotionImage,
  }) async {
    logger.i('sending data to widget promotionImage $promotionImage', tag: tag);
    String? _promotionImage;
    File? _promotionImageFile;
    try {
      if (promotionImage != null) {
        _promotionImage =
            await downloadAndSaveFile(promotionImage, 'promotionImage');
        _promotionImageFile = File(_promotionImage);
        logger.i(
            'promotionImage downloaded ${_promotionImageFile.path} ${_promotionImageFile.existsSync()} ${_promotionImageFile.lengthSync()}',
            tag: tag);
      }
    } catch (e) {
      logger.e('Error downloading promotionImage', error: e, tag: tag);
    }
    try {
      return Future.wait([
        /// title
        if (title != null)
          HomeWidget.saveWidgetData<String>(HomeWidgetData.title.name, title),

        /// message
        if (message != null)
          HomeWidget.saveWidgetData<String>(
              HomeWidgetData.message.name, message),

        /// save data for dashboard
        /// runnig
        if (runnig != null)
          HomeWidget.saveWidgetData<int>(
              HomeWidgetData.runningAuctionCount.name, runnig),

        /// upcoming
        if (upcoming != null)
          HomeWidget.saveWidgetData<int>(
              HomeWidgetData.upcomingAuctionCount.name, upcoming),

        /// closed
        if (closed != null)
          HomeWidget.saveWidgetData<int>(
              HomeWidgetData.closedAuctionCount.name, closed),

        if (renderWidget != null)
          HomeWidget.renderFlutterWidget(renderWidget,
              logicalSize: logicalSize ?? const Size(200, 200), key: renderKey),

        /// lastUpdatedTime
        HomeWidget.saveWidgetData<String>(HomeWidgetData.lastUpdatedTime.name,
            MyDateUtils.formatDate(DateTime.now(), 'dd MMM yyyy hh:mm a')),

        /// promotionImage
        if (_promotionImageFile != null)
          HomeWidget.saveWidgetData<String>(
              HomeWidgetData.promotionImage.name, _promotionImageFile.path),
      ]).then((value) {
        logger.f(' data sent to widget successfully! $value');
        return value;
      });
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
    return null;
  }

  Future<bool?> updateWidget() async {
    try {
      return HomeWidget.updateWidget(
              name: auctiodetailsWidgetProviderName,
              iOSName: 'HomeWidgetExample')
          .then((value) {
        logger.i(' widget updated $value');
        return value;
      });
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
    return null;
  }

  Future<void> sendAndUpdate({
    Widget? renderWidget,
    String? title,
    String? message,
    Size? logicalSize,
    String? renderKey,
    int? runnig,
    int? upcomming,
    int? closed,
    String? promotionImage,
  }) async {
    try {
      await sendData(
        renderWidget: renderWidget,
        title: title,
        message: message,
        renderKey: renderKey ?? 'dashIcon',
        logicalSize: logicalSize,
        runnig: runnig,
        upcoming: upcomming,
        closed: closed,
        promotionImage: promotionImage,
      );
    } catch (e) {
      logger.e('Error sending data to home widget ', error: e);
    }
    await updateWidget();
  }

  Future<List<dynamic>> _loadData() async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('title',
            defaultValue: 'Default Title'),
        HomeWidget.getWidgetData<String>('message',
            defaultValue: 'Default Message'),
      ]).then((value) {
        logger.i(' data loaded from widget $value');
        return value;
      });
    } on PlatformException catch (exception) {
      debugPrint('Error Getting Data. $exception');
    }
    return [];
  }

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      showDialog(
          context: Get.context!,
          builder: (buildContext) => AlertDialog(
                title: const Text('App started from HomeScreenWidget'),
                content: Text('Here is the URI: $uri'),
              ));
    }
  }

  void _startBackgroundUpdate() {
    Workmanager().registerPeriodicTask('1', 'widgetBackgroundUpdate',
        frequency: const Duration(minutes: 15));
  }

  void _stopBackgroundUpdate() {
    Workmanager().cancelByUniqueName('1');
  }
}
