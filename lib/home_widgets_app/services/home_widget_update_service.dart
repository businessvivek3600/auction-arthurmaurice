import 'package:firebase_messaging/firebase_messaging.dart';

import '../../utils/my_logger.dart';
import '../home_widget_index.dart';

class HomeWidgetUpdateService {
  static const String tag = 'ManualHomeWidgetUpdateService';
  static final HomeWidgetSetup _homeWidgetServices = HomeWidgetSetup.instance;

  static Future<void> fromNotifiaction(RemoteMessage message) async {
    try {
      final Map<String, dynamic> data = message.data;

      _homeWidgetServices.sendAndUpdate(
        runnig: int.tryParse(data['runningAuctionCount'].toString()),
        upcomming: int.tryParse(data['upcomingAuctionCount'].toString()),
        closed: int.tryParse(data['closedAuctionCount'].toString()),
        promotionImage: data['promotionImage'],
      );
    } catch (e) {
      logger.e('fromNotifiaction error:', error: e, tag: tag);
    }
  }

  static Future<void> updateFromDashboardData({
    int? runnig,
    int? upcoming,
    int? closed,
    String? promotionImage,
  }) async {
    try {
      _homeWidgetServices.sendAndUpdate(
          runnig: runnig,
          upcomming: upcoming,
          closed: closed,
          promotionImage: promotionImage);
    } catch (e) {
      logger.e('updateFromDashboardData error:', error: e, tag: tag);
    }
  }
}
