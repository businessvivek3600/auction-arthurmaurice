import 'package:action_tds/database/database_index.dart';

import '../utils/utils_index.dart';

class AppConst {
  static const tag = 'AppConst';
  static String appName = "Auction App";
  static const String appVersion = "1.0.0";
  static const String packageName = "com.arthurmaurice.flutter_app";
  static const String appStoreId = "auction/1234567890";
  static String appDescription = "Flutter App Description";
  static const String appIcon = "assets/images/logo-no-background.png";

  ///api
  static const String baseUrl = "https://arthurmaurice.com/api/";
  static const String siteUrl = "https://arthurmaurice.com";
  static const String apiVersion = "v1";

  static String currencySymbol = '';

  static Future<void> readStringsXml() async {
    // Specify the path to strings.xml
    String xmlPath = 'android/app/src/main/res/values/strings.xml';

    try {
      var data = await loadStringXml(xmlPath);
      logger.i('readStringsXml data: $data', tag: tag);
      for (var item in data.entries.toList()) {
        switch (item.key) {
          case 'app_name':
            appName = item.value;
            break;
          case 'app_description':
            appDescription = item.value;
            break;
          case 'currency_symbol':
            currencySymbol = item.value;
            break;
          default:
            break;
        }
      }
    } catch (e) {
      logger.w('readStringsXml Error ', error: e, tag: tag);
    }
  }
}
