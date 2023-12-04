import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import 'package:get/get.dart';

import '../../../../../database/connect/api_handler.dart';
import '../../../../../utils/utils_index.dart';

class BidController extends GetxController {
  static const tag = 'CategoryController';
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    bids.clear();
    winningBids.clear();
    totalBids = 0;
    totalWinningBids = 0;
    page = 1;
    pageWinningBids = 1;
    super.onClose();
  }

  List<Bid> bids = [];
  int totalBids = 0;
  bool loading = true;
  int page = 1;
  setLoading(bool val) {
    loading = val;
    update();
  }

  Future<void> getBids({
    int pageNo = 1,
    int perPage = 10,
    String products = '',
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        loading = true;
        update();
      }
      page = pageNo;
      Uri uri = Uri.parse(ApiConst.bidHistory);
      uri = uri.replace(queryParameters: {
        'page_no': '$pageNo',
        'per_page': '$perPage',
        if (products.isNotEmpty) 'product': products,
      });
      logger.i('getbids uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.path, method: ApiMethod.GET);
      if (res != null) {
        totalBids = res['total_data'];
        if (pageNo == 1) {
          bids = await _getBidstFromJson(res['bids']);
        } else {
          bids.addAll(await _getBidstFromJson(res['bids']));
        }
      }
    } catch (e) {
      logger.e('getbids error: $e', tag: tag, error: e);
    }
    loading = false;
    update();
  }

  Future<List<Bid>> _getBidstFromJson<T>(dynamic json) async {
    List<Bid> bids = [];

    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => bids = json.map((e) => Bid.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getCategoryListFromJson $T error: ', tag: tag, error: e);
    }
    return bids;
  }

  List<WinnigBid> winningBids = [];
  bool loadingWinnings = true;
  int pageWinningBids = 1;
  int totalWinningBids = 0;

  Future<void> getWinningBids({
    int pageNo = 1,
    int perPage = 10,
  }) async {
    try {
      loadingWinnings = true;
      pageWinningBids = pageNo;
      update();
      Uri uri = Uri.parse(ApiConst.winnigBids);
      uri = uri.replace(
          queryParameters: {'page_no': '$pageNo', 'per_page': '$perPage'});
      logger.i('getWinningBids uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.toString(), method: ApiMethod.GET);
      if (res != null) {
        totalWinningBids = int.tryParse('${res['total_data']}') ?? 0;
        if (pageNo == 1) {
          winningBids = await _getWinnigsListFromJson(res['winners']);
        } else {
          winningBids.addAll(await _getWinnigsListFromJson(res['winners']));
        }
        update();
      }
    } catch (e) {
      logger.e('getWinningBids error: $e', tag: tag, error: e);
    }
    loadingWinnings = false;
    update();
  }

  Future<List<WinnigBid>> _getWinnigsListFromJson(dynamic json) async {
    List<WinnigBid> winnings = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => winnings = json.map((e) => WinnigBid.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getProductListFromJson  error: ', tag: tag, error: e);
    }
    return winnings;
  }
}
