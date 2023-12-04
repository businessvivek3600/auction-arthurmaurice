import 'package:action_tds/constants/constants_index.dart';
import 'package:share_plus/share_plus.dart';

class AppShare {
  static String playStoreLink =
      "https://play.google.com/store/apps/details?id=${AppConst.packageName}}";
  static String appstoreLink =
      "https://apps.apple.com/us/app/${AppConst.appStoreId}";
  static String appShareText =
      "Download this app from\n   Playstore: $playStoreLink\n\n   Appstore: $appstoreLink";
  static String appShareSubject =
      "Auction App: Your ultimate destination for luxury goods";

  static getRefferalLink(String? username) =>
      username != null && username.isNotEmpty
          ? "Click on my refferal link ${AppConst.siteUrl}/register/$username"
          : '';

  static Future<void> shareApp(String? username) async {
    String text =
        "$appShareText\n\n\n   Join me on ${AppConst.appName} ${getRefferalLink(username)}";
    await Share.share(text, subject: appShareSubject);
  }

  static Future<void> shareAnAuction(String pathText,
      {String? username}) async {
    String text =
        "$pathText \n   ${getRefferalLink(username)}\n\n\n    $appShareText  ";
    await Share.share(text, subject: appShareSubject);
  }

  static Future<void> shareAnAuctionWithImage(String imagePath) async {
    // await Share.shareFiles([imagePath], text: appLink, subject: appShareSubject);
  }

  static Future<void> refferAFriend(String? username) async {
    String text =
        "Join me on ${AppConst.appName} ${getRefferalLink(username)}\n\n\n   $appShareText";
    await Share.share(text, subject: appShareSubject);
  }
}
