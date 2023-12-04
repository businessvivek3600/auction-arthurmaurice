part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const splash = Paths.splash;
  static const intro = Paths.intro;
  static const home = Paths.home;
  static const auth = Paths.auth;
  static const forgotPassword = '/${Paths.forgotPassword}';
  static const appTour = Paths.appRoute;

  static const pageNotFound = Paths.pageNotFound;
  static String loginThen(String afterSuccessfulLogin) =>
      '$auth?then=${Uri.encodeQueryComponent(afterSuccessfulLogin)}';

  ///sub routes
  static const product = '${Paths.home}${Paths.product}';
  static const account = '${Paths.home}${Paths.account}';
  static const category = '${Paths.home}${Paths.category}';
  static const auctionDetail = '${Paths.home}${Paths.autionDetail}';
  static const profileSettings = '${Paths.home}${Paths.profileSettings}';
  static const updateProfile = '${Paths.home}${Paths.updateProfile}';
  static const changePassword = '${Paths.home}${Paths.changePassword}';
  static const errorLogScreen = '${Paths.home}${Paths.errorLogScreen}';
  static const errorLogListScreen = '${Paths.home}${Paths.errorLogListScreen}';

  ///test routes
  static const DASHBOARD = Paths.DASHBOARD;
  static const ECOM_DASHBOARD = Paths.ECOM_DASHBOARD;
  static const CART = Paths.CART;
}

abstract class Paths {
  Paths._();
  static const splash = '/splash';
  static const intro = '/intro';
  static const home = '/';
  static const auth = '/login';
  static const forgotPassword = 'forgotPassword';
  static const appRoute = '/app-tour';

  ///page not found
  static const pageNotFound = '/404';

  ///sub routes
  static const product = 'product';
  static const autionDetail = 'auction';
  static const category = 'category';
  static const profileSettings = 'profile-settings';
  static const updateProfile = 'update-profile';
  static const changePassword = 'changePassword';
  static const errorLogScreen = 'error-log-screen';
  static const errorLogListScreen = 'error-log-list-screen';

  ///test routes
  static const DASHBOARD = 'dashboard';
  static const account = 'account';
  static const CART = 'cart';
  static const ECOM_DASHBOARD = 'ecom-dashboard';
}
