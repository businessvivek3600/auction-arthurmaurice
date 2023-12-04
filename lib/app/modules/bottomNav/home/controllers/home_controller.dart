import 'package:action_tds/app/modules/auth/controllers/auth_controller.dart';
import 'package:action_tds/app/modules/auth/user_model.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:flutter/services.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

import '../../../../../home_widgets_app/home_widget_index.dart';
import '../../../auth/providers/user_provider.dart';
import '../../bid_history/controllers/bidController.dart';
import '../../transactions/controller/transactionController.dart';
import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import '/database/connect/api_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static const tag = 'HomeController';
  static HomeController get to => Get.find();
  bool _hideNavBar = false;
  bool get hideNavBar => _hideNavBar;
  void setHideNavBar(bool value) {
    _hideNavBar = value;
    update();
  }

  late PersistentTabController persistentTabController;
  final count = 0.obs;
  @override
  void onInit() {
    persistentTabController = PersistentTabController(initialIndex: 0);
    super.onInit();
    profileProgressValue = ValueNotifier(0.0);
  }

  @override
  void dispose() {
    profileProgressValue.value = 0.0;
    liveAuctionProductsByType.clear();
    liveAuctionProducts.clear();
    upcomingAuctionProductsByType.clear();
    upcomingAuctionProducts.clear();
    closedAuctionProductsByType.clear();
    closedAuctionProducts.clear();
    trendingAuctionProducts.clear();
    homeBanners.clear();
    categories.clear();
    super.dispose();
  }

  void increment() =>
      Future.wait([Future(() => count.value++)]).then((value) => update());

  ///////home page/////
  late ScrollController _homeScrollController;
  ScrollController get homeScrollController => _homeScrollController;
  void setHomeScrollController(ScrollController controller) {
    _homeScrollController = controller;
    _homeScrollController.addListener(() => _homeScrollListener());
  }

  bool _loadingDashboard = true;
  bool get loadingDashboard => _loadingDashboard;
  void setLoadingDashboard(bool value) {
    _loadingDashboard = value;
    update();
  }

  List<AuctionProduct> liveAuctionProducts = [];
  List<AuctionProduct> upcomingAuctionProducts = [];
  List<AuctionProduct> closedAuctionProducts = [];
  List<AuctionProduct> trendingAuctionProducts = [];
  List<HomeBanner> homeBanners = [];
  List<Category> categories = [];

  Future<void> getDashboard([bool loading = true]) async {
    try {
      if (loading) setLoadingDashboard(true);
      var res =
          await ApiHandler.hitApi(ApiConst.dashboard, method: ApiMethod.GET);
      if (res != null) {
        liveAuctionProducts =
            await _getProductListFromJson(res['live_auction_products']);
        upcomingAuctionProducts =
            await _getProductListFromJson(res['upcoming_auction_products']);
        closedAuctionProducts =
            await _getProductListFromJson(res['closed_auction_products']);
        trendingAuctionProducts =
            await _getProductListFromJson(res['trending_products']);
        categories = await _getCategoryListFromJson(res['categories']);
        homeBanners =
            await _getHomeBannersListFromJson(res['main_home_banner']);
        await _updateUser(res['user']);
        HomeWidgetUpdateService.updateFromDashboardData(
          runnig: int.tryParse(res['total_running_auction'].toString()),
          upcoming: int.tryParse(res['totalUpcomingAuction'].toString()),
          closed: int.tryParse(res['total_closed_auction'].toString()),
        );
        update();
      }
    } catch (e) {
      logger.e('getDashboard error: ', tag: tag, error: e);
    }
    setLoadingDashboard(false);
  }

  Future<void> _updateUser(dynamic json) async {
    try {
      if (json != null && json is Map) {
        await Future.microtask(() => Get.put(AuthController()).setCurrentUser(
            AuctionUser.fromJson(json as Map<String, dynamic>)));
      }
    } catch (e) {
      logger.e('_updateUser error: ', tag: tag, error: e);
    }
  }

  Future<List<AuctionProduct>> _getProductListFromJson(dynamic json) async {
    List<AuctionProduct> products = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(() =>
            products = json.map((e) => AuctionProduct.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getProductListFromJson  error: ', tag: tag, error: e);
    }
    return products;
  }

  Future<List<Category>> _getCategoryListFromJson<T>(dynamic json) async {
    List<Category> categories = [];

    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => categories = json.map((e) => Category.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getCategoryListFromJson $T error: ', tag: tag, error: e);
    }
    return categories;
  }

  Future<List<HomeBanner>> _getHomeBannersListFromJson(dynamic json) async {
    List<HomeBanner> banners = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => banners = json.map((e) => HomeBanner.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getHomeBannersListFromJson error: ', tag: tag, error: e);
    }
    return banners;
  }

  void _homeScrollListener() {
    if (_homeScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!hideNavBar) {
        setHideNavBar(true);
      }
    } else {
      if (hideNavBar) {
        setHideNavBar(false);
      }
    }
  }

  disposeHomeScrollController() {
    _homeScrollController.removeListener(_homeScrollListener);
    _homeScrollController.dispose();
  }

  ////live auctions page/////
  late ScrollController _liveBidsScrollController;
  ScrollController get liveBidsScrollController => _liveBidsScrollController;
  void setLiveBidsScrollController(ScrollController controller) {
    _liveBidsScrollController = controller;
    // _liveBidsScrollController.addListener(() => _liveBidsScrollListener());
  }

  void _liveBidsScrollListener() {
    // print(
    // '_liveBidsScrollListener ${_liveBidsScrollController.position.pixels}');

    if (_liveBidsScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // print('_liveBidsScrollListener reverse');
      // onScreenHideButtonPressed(true);
      if (!hideNavBar) {
        setHideNavBar(true);
      }
    } else {
      // print('_liveBidsScrollListener forward');
      // onScreenHideButtonPressed(false);
      if (hideNavBar) {
        setHideNavBar(false);
      }
    }
  }

  disposeLiveBidsScrollController() {
    // _liveBidsScrollController.removeListener(_liveBidsScrollListener);
    _liveBidsScrollController.dispose();
    print('disposeLiveBidsScrollController completed');
  }

  int _selectedBidType = 0;
  int get selectedBidType => _selectedBidType;
  void setSelectedBidType(int index) {
    _selectedBidType = index;
    update();
    getAuctionProductsByType(
      productType: index == 0
          ? ProductType.live
          : index == 1
              ? ProductType.upcoming
              : ProductType.closed,
      page: 1,
      perPage: 10,
    );
  }

  ///////upcoming bids page/////
  late ScrollController _upcomingBidsScrollController;
  ScrollController get upcomingBidsScrollController =>
      _upcomingBidsScrollController;
  void setUpcomingBidsScrollController(ScrollController controller) {
    _upcomingBidsScrollController = controller;
    // _upcomingBidsScrollController
    //     .addListener(() => _upcomingBidsScrollListener());
  }

  void _upcomingBidsScrollListener() {
    if (_upcomingBidsScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!hideNavBar) {
        setHideNavBar(true);
      }
    } else {
      if (hideNavBar) {
        setHideNavBar(false);
      }
    }
  }

  disposeUpcomingBidsScrollController() {
    // _upcomingBidsScrollController.removeListener(_upcomingBidsScrollListener);
    _upcomingBidsScrollController.dispose();
  }

  /////////closed bids page/////////

  late ScrollController _closedBidsScrollController;
  ScrollController get closedBidsScrollController =>
      _closedBidsScrollController;
  void setClosedBidsScrollController(ScrollController controller) {
    _closedBidsScrollController = controller;
    // _closedBidsScrollController.addListener(() => _closedBidsScrollListener());
  }

  void _closedBidsScrollListener() {
    if (_closedBidsScrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (!hideNavBar) {
        setHideNavBar(true);
      }
    } else {
      if (hideNavBar) {
        setHideNavBar(false);
      }
    }
  }

  disposeClosedBidsScrollController() {
    // _closedBidsScrollController.removeListener(_closedBidsScrollListener);
    _closedBidsScrollController.dispose();
  }

  /// getProducts
  /// [productType] live, upcoming, closed
  List<AuctionProduct> liveAuctionProductsByType = [];
  List<AuctionProduct> upcomingAuctionProductsByType = [];
  List<AuctionProduct> closedAuctionProductsByType = [];
  int totalLiveAuctionProducts = 0;
  int totalUpcomingAuctionProducts = 0;
  int totalClosedAuctionProducts = 0;
  int loadingActionProductsByType = 0;
  setLoadingActionProductsByType(ProductType productType) {
    loadingActionProductsByType = productType == ProductType.live
        ? 0
        : productType == ProductType.upcoming
            ? 1
            : productType == ProductType.closed
                ? 2
                : -1;
    update();
  }

  Map<ProductType, int> productTypePage = {
    ProductType.live: 1,
    ProductType.upcoming: 1,
    ProductType.closed: 1,
  };
  Future<void> getAuctionProductsByType({
    required ProductType productType,
    int page = 1,
    int perPage = 10,
    bool loading = true,
  }) async {
    try {
      var endPoint = productType == ProductType.live
          ? ApiConst.liveAuctionProducts
          : productType == ProductType.upcoming
              ? ApiConst.upcomingAuctionProducts
              : ApiConst.closedAuctionProducts;
      setLoadingActionProductsByType(loading ? productType : ProductType.none);

      var res = await ApiHandler.hitApi(
          '$endPoint?page_no=${productTypePage[productType]}&per_page=$perPage',
          method: ApiMethod.GET);
      if (res != null) {
        if (productType == ProductType.live) {
          var products = await _getProductListFromJson(res['products']);
          totalLiveAuctionProducts =
              int.tryParse(res['total_data'].toString()) ?? 0;
          if (productTypePage[productType] == 1) {
            liveAuctionProductsByType = products;
          } else {
            liveAuctionProductsByType.addAll(products);
          }
        } else if (productType == ProductType.upcoming) {
          var products = await _getProductListFromJson(res['products']);
          totalUpcomingAuctionProducts =
              int.tryParse(res['total_data'].toString()) ?? 0;
          if (productTypePage[productType] == 1) {
            upcomingAuctionProductsByType = products;
          } else {
            upcomingAuctionProductsByType.addAll(products);
          }
        } else if (productType == ProductType.closed) {
          var products = await _getProductListFromJson(res['products']);
          totalClosedAuctionProducts =
              int.tryParse(res['total_data'].toString()) ?? 0;
          if (productTypePage[productType] == 1) {
            closedAuctionProductsByType = products;
          } else {
            closedAuctionProductsByType.addAll(products);
          }
        }
        productTypePage[productType] = page;
        update();
      }
    } catch (e) {
      logger.e('getAuctionProductsByType error: ', tag: tag, error: e);
    }
    loadingActionProductsByType = -1;
    update();
  }

////////// account page  //////////////
  late ValueNotifier<double> profileProgressValue;

  int _selectedNavTab = 0;
  void onNavBarTap(int value) async {
    var authCtrl = Get.put(AuthController());
    var transCtrl = Get.put(TransactionController());
    var bidCtrl = Get.put(BidController());
    var userProvider = await UserProvider.instance;
    switch (value) {
      case 0:
        if (_selectedNavTab != value) {}

        break;
      case 1:
        if (_selectedNavTab != value) {
          setSelectedBidType(0);
        }
        setStatusBar(1);

        break;
      case 2:
        if (_selectedNavTab != value) {
          bidCtrl.getBids(refresh: true);
        }
        setStatusBar(2);
        break;
      case 3:
        if (_selectedNavTab != value) {
          var index = transCtrl.tabController.index;
          index == 0
              ? transCtrl.getTransactions(refresh: true)
              : transCtrl.getDeposits(refresh: true);
        }
        setStatusBar(3);
        break;
      case 4:
        if (_selectedNavTab != value) {
          userProvider.getUser();
          bidCtrl.getWinningBids();
        }
        setStatusBar(4);
        break;
      default:
        break;
    }
    _selectedNavTab = value;
  }

  setStatusBar(int val) {
    if (val == 0) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          statusBarColor: Colors.green,
          statusBarIconBrightness: getTheme().brightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          statusBarBrightness: getTheme().brightness == Brightness.light
              ? Brightness.light
              : Brightness.dark,
        ),
      );
    }
  }
}
