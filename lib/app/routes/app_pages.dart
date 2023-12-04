import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_services.dart';
import '../../services/errorLogScreen.dart';
import '../../utils/utils_index.dart';
import '../middleware/auth_middleware.dart';
import '../modules/appTour/bindings/app_tour_binding.dart';
import '../modules/appTour/views/app_tour_view.dart';
import '../modules/auction_detail/bindings/auction_detail_binding.dart';
import '../modules/auction_detail/views/auction_detail_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/auth/views/forgot_password.dart';
import '../modules/auth/views/onboarding_view.dart';
import '../modules/auth/views/splash_view.dart';
import '../modules/category/view/all_categories.dart';
import '../modules/category/view/category_details.dart';
import '../modules/bottomNav/home/bindings/home_binding.dart';
import '../modules/bottomNav/home_view.dart';
import '../modules/page_not_found.dart';
import '../modules/product/bindings/product_binding.dart';
import '../modules/product/views/product_view.dart';
import '../modules/bottomNav/account_view/account_view.dart';
import '../../app/modules/settings/setting_index.dart';

part 'app_routes.dart';

///getx route
class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Paths.splash, page: () => const SplashView()),
    GetPage(
      name: Paths.intro,
      page: () => const OnboardingView(),
      middlewares: [EnsureNotAuthMiddleware()],
    ),

    // auth required routes
    GetPage(
      name: Paths.home,
      page: () => const HomeView(),
      middlewares: [
        EnsureAuthMiddleware(),
      ],
      binding: HomeBinding(),
      children: [
        ///product
        GetPage(
          name: Paths.product,
          page: () => const ProductView(),
          binding: ProductBinding(),
        ),

        ///auction
        GetPage(
          name: Paths.autionDetail,
          page: () => AuctionDetailView(),
          binding: AuctionDetailBinding(),
          children: [
            GetPage(
              name: '${Paths.autionDetail}/:id',
              page: () => AuctionDetailView(),
              binding: AuctionDetailBinding(),
            ),
          ],
        ),

        ///profile-settings
        GetPage(
          name: Paths.profileSettings,
          page: () => UserProfileSetting(),
        ),
      ],
    ),

    ///auth
    GetPage(
      name: Paths.auth,
      page: () => AuthView(),
      binding: AuthBinding(),
      middlewares: [EnsureNotAuthMiddleware()],
    ),

    ///app tour
    GetPage(
      name: Paths.appRoute,
      page: () => const AppTourView(),
      binding: AppTourBinding(),
    ),
  ];
}

/// convert above code to go_router navigation

// import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

///go_router route
final goRouter = GoRouter(
  navigatorKey: Get.key,
  initialLocation: Routes.splash,
  routes: [
    GoRoute(
      path: Routes.splash,
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: Routes.intro,
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: Routes.home,
      pageBuilder: (context, state) =>
          animatedRoute2(state, (state) => const HomeView()),
      redirect: (context, state) {
        if (!AuthService.instance.isLoggedIn) {
          return Routes.auth;
        }
        return null;
      },
      routes: [
        GoRoute(
            path: Paths.product,
            pageBuilder: (context, state) =>
                animatedRoute2(state, (state) => const ProductView())),
        GoRoute(
          path: Paths.account,
          pageBuilder: (context, state) =>
              animatedRoute2(state, (state) => AccountView()),
        ),

        ///auction
        GoRoute(
          path: '${Paths.autionDetail}/:id',
          pageBuilder: (context, state) => animatedRoute2(state, (state) {
            int? actionId = int.tryParse(state.pathParameters['id'] ?? '');
            return AuctionDetailView(
                auctionId: actionId, path: state.matchedLocation);
          }),
        ),
        GoRoute(
          path: '${Paths.autionDetail}/:id/:slug',
          redirect: (context, state) {
            final id = state.pathParameters['id'];
            return '${Routes.auctionDetail}/$id';
          },
        ),

        ///category
        GoRoute(
            path: Paths.category,
            pageBuilder: (context, state) =>
                animatedRoute2(state, (state) => CategoriesPage()),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (context, state) => animatedRoute2(state, (state) {
                  final id = state.pathParameters['id'];
                  return CategoryByIdPage(id: id);
                }),
              ),
              GoRoute(
                path: ':id/:slug',
                redirect: (context, state) {
                  final id = state.pathParameters['id'];
                  return '${Routes.category}/$id';
                },
              ),
            ]),

        ///profile-settings
        GoRoute(
          path: Paths.profileSettings,
          pageBuilder: (context, state) =>
              animatedRoute2(state, (state) => UserProfileSetting()),
        ),

        ///update profile
        GoRoute(
          path: Paths.updateProfile,
          pageBuilder: (context, state) =>
              animatedRoute2(state, (state) => const UpdateProfile()),
        ),

        ///change password
        GoRoute(
          name: Paths.changePassword,
          path: Paths.changePassword,
          pageBuilder: (context, state) =>
              animatedRoute2(state, (state) => const ChangePassword()),
        ),
      ],
    ),

    ///register
    GoRoute(
      path: '/register/:id',
      redirect: (context, state) {
        var id = state.pathParameters['id'];
        return '${Routes.auth}?reference=$id';
      },
    ),

    ///auth
    GoRoute(
      path: Routes.auth,
      builder: (context, state) {
        final then = state.uri.queryParameters['then'];
        final reference = state.uri.queryParameters['reference'];
        logger.i('then: $then reference: $reference');
        return AuthView(then: then, referer: reference);
      },
      redirect: (context, state) {
        if (AuthService.instance.isLoggedIn) {
          return Routes.home;
        }
        return null;
      },
    ),

    ///forgot password
    GoRoute(
      name: Paths.forgotPassword,
      path: Routes.forgotPassword,
      pageBuilder: (context, state) =>
          animatedRoute2(state, (state) => const ForgotPassword()),
    ),

    ///404
    GoRoute(
      path: '/404',
      builder: (context, state) => PageNotFound(state: state),
    ),

    ///error log list screen
    GoRoute(
      path: Routes.errorLogListScreen,
      name: Paths.errorLogListScreen,
      pageBuilder: (context, state) => animatedRoute2(
          state,
          (state) => ErrorLogListScreen(
              rootEntity:
                  state.extra != null ? state.extra as Directory : null)),
    ),

    ///error log screen
    GoRoute(
      path: Routes.errorLogScreen,
      name: Paths.errorLogScreen,
      pageBuilder: (context, state) => animatedRoute2(state, (state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        final path = extra['path'] as String?;
        return ErrorLogScreen(path: path);
      }),
    ),
  ],
  onException: (_, GoRouterState state, GoRouter router) =>
      router.push('/404', extra: state.uri.toString()),
  redirect: guardRoute,
  // errorBuilder: (context, state) => PageNotFound(state: state)
);

// import 'package:flutter/material.dart';
Future<String?> guardRoute(BuildContext context, GoRouterState state) async {
  String path = state.matchedLocation;
  // final (loggedIn, user) = await StreamAuthScope.of(context).isSignedIn();
  bool isLoggedIn = AuthService.instance.isLoggedIn;
  logger.i('guardRoute path: $path  $isLoggedIn ');
  // root pages
  if (path == Routes.splash) {
    return null;
  }
  if (authRoutes.any((element) => path.startsWith(element))) {
    return !isLoggedIn ? null : Routes.home;
  } else if (authenticatedRoutes.any((element) => path.startsWith(element)) &&
      !isLoggedIn) {
    String? ref = state.uri.queryParameters['reference'];
    var newPath =
        '${Routes.auth}?then=${Uri.encodeQueryComponent(path)}&reference=${ref ?? ''}';
    logger.i('guardRoute newPath: $newPath');
    return Routes.loginThen(path);
  } else {
    return path;
  }
}

List<String> authRoutes = [
  Routes.intro,
  Routes.auth,
  '/register',
  Routes.forgotPassword,
];

List<String> authenticatedRoutes = [
  Routes.home,
  Routes.product,
  Routes.auctionDetail,
  Routes.account,
  Routes.DASHBOARD,
  Routes.CART,
  Routes.ECOM_DASHBOARD,
];

///
// ignore_for_file: constant_pattern_never_matches_value_type

CustomTransitionPage animatedRoute(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    barrierDismissible: true,
    barrierColor: Colors.black38,
    opaque: false,
    transitionDuration: const Duration(milliseconds: 500),
    reverseTransitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation, Widget child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

Page animatedRoute2(
    GoRouterState state, Widget Function(GoRouterState state) child,
    {RouteTransition? transition}) {
  logger.i('animatedRoute2',
      error:
          'queryParameters are ${state.uri.queryParameters}  is anim-> ${state.uri.queryParameters['anim']}',
      tag: 'My Router');

  if ((Platform.isAndroid || Platform.isIOS) &&
      state.uri.queryParameters['anim'] == null) {
    return CupertinoPage(
      child: child(state),
      key: state.pageKey,
      title: state.matchedLocation.split('-').last.capitalizeFirst,
      arguments: state.extra,
    );
  }

  RouteTransition pageTransition = transition ??
      RouteTransition.values.firstWhere((element) =>
          element.name ==
          (state.uri.queryParameters['anim'] ?? RouteTransition.fomRight.name));
  return CustomTransitionPage(
      key: state.pageKey,
      child: child(state),
      barrierDismissible: true,
      barrierColor: Colors.black38,
      arguments: state.extra,
      // opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (pageTransition) {
          case RouteTransition.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fromTop:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, -1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fromBottom:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fomRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.topLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.topRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, -1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.bottomLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.bottomRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case RouteTransition.scale:
            return FadeTransition(
              opacity: Tween<double>(begin: 0.6, end: 1.0).animate(animation),
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.0, end: 1.0).animate(animation),
                child: child,
              ),
            );
          default:
            return FadeTransition(
              opacity: Tween<double>(begin: .5, end: 1.0).animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
        }
      });
}

enum RouteTransition {
  slide,
  fromTop,
  fromBottom,
  fomRight,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  fade,
  scale,
  fromLeft,
}

goToAuctionDetail(String? auctionId, {String? path}) {
  if (auctionId != null) {
    goRouter.push('${Routes.auctionDetail}/$auctionId', extra: {'path': path});
  }
}
