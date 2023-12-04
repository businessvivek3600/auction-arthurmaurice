import 'dart:async';
import 'dart:convert';

import 'package:great_list_view/great_list_view.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';

import '/app/models/auction_app/auction_model.dart';
import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../constants/constants_index.dart';
import '../../../../database/connect/api_handler.dart';
import '../../../../utils/utils_index.dart';
import '../../../../components/component_index.dart';

class AuctionDetailController extends GetxController {
  static const tag = 'AuctionDetailController';
  final String _apiKey = '7a318b3eb2fe935c548c';
  final String _cluster = 'ap2';
  final String _channelName = 'bid-channel';
  String _log = 'output:\n';
  PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  List<BidRecord> bidList = [];
  final TextEditingController bidAmountcontroller = TextEditingController();
  final controller = AnimatedListController();

  setHighestBid(double value) {
    bidAmountcontroller.text = value.toStringAsFixed(0);
    update();
  }

  void onConnectPressed() async {
    try {
      ///init pusher
      await pusher.init(
        apiKey: _apiKey,
        cluster: _cluster,
        onConnectionStateChange: onConnectionStateChange,
        onError: onError,
        onSubscriptionSucceeded: onSubscriptionSucceeded,
        onEvent: onEvent,
        onSubscriptionError: onSubscriptionError,
        onDecryptionFailure: onDecryptionFailure,
        onMemberAdded: onMemberAdded,
        onMemberRemoved: onMemberRemoved,
        onSubscriptionCount: onSubscriptionCount,
        // authEndpoint: "<Your Authendpoint Url>",
        // onAuthorizer: onAuthorizer
      );
      await pusher.subscribe(channelName: _channelName);
      await pusher.connect();
    } catch (e) {
      logger.e('onConnectPressed error: ', tag: tag, error: e);
    }
  }

  void onConnectionStateChange(dynamic currentState, dynamic previousState) {
    log("Connection: $currentState");
  }

  void onError(String message, int? code, dynamic e) {
    log("onError: $message code: $code exception: $e");
  }

  void onEvent(PusherEvent event) {
    bool listen = ('product-${auctionProduct!.id}') == event.eventName;
    if (listen) {
      try {
        var user = jsonDecode(event.data)['user'];
        var data = user != null ? BidRecord.fromJson(user) : null;
        logger.i('onEvent: ${event.data}');
        addToStream(data);
      } catch (e) {
        logger.e('onEvent error: ', tag: tag, error: e);
      }
    }
  }

  void onSubscriptionSucceeded(String channelName, dynamic data) {
    log("onSubscriptionSucceeded: $channelName data: $data");
    final me = pusher.getChannel(channelName)?.me;
    log("Me: $me");
  }

  void onSubscriptionError(String message, dynamic e) {
    log("onSubscriptionError: $message Exception: $e");
  }

  void onDecryptionFailure(String event, String reason) {
    log("onDecryptionFailure: $event reason: $reason");
  }

  void onMemberAdded(String channelName, PusherMember member) {
    log("onMemberAdded: $channelName user: $member");
  }

  void onMemberRemoved(String channelName, PusherMember member) {
    log("onMemberRemoved: $channelName user: $member");
  }

  void onSubscriptionCount(String channelName, int subscriptionCount) {
    log("onSubscriptionCount: $channelName subscriptionCount: $subscriptionCount");
  }

  dynamic onAuthorizer(String channelName, String socketId, dynamic options) {
    return {
      "auth": "foo:bar",
      "channel_data": '{"user_id": 1}',
      "shared_secret": "foobar"
    };
  }

  void log(String text) {
    logger.i("LOG: $text");
    _log += "$text\n";
  }

  Timer? timer;

  @override
  void onClose() {
    super.onClose();
    timer?.cancel();
  }

  @override
  void dispose() {
    super.dispose();
    timer?.cancel();
  }

  bool loadigAuctionDetail = true;
  bool get loadingAuctionDetail => loadigAuctionDetail;
  void setLoadingAuctionDetail(bool value) {
    loadigAuctionDetail = value;
    update();
  }

  AuctionProduct? auctionProduct;
  Future<void> getAuctionById(int id) async {
    try {
      var res = await ApiHandler.hitApi('${ApiConst.auction}/$id',
          method: ApiMethod.POST);
      if (res != null) {
        auctionProduct = await _getProductListFromJson(res['product']);
        update();
      }
    } catch (e) {
      logger.e('getAuctionById error: ', tag: tag, error: e);
    }
    setLoadingAuctionDetail(false);
  }

  Future<AuctionProduct?> _getProductListFromJson(dynamic json) async {
    AuctionProduct? product;
    try {
      if (json != null && json is Map<String, dynamic>) {
        product = AuctionProduct.fromJson(json);
      }
    } catch (e) {
      logger.e('_getProductListFromJson  error: ', tag: tag, error: e);
    }
    return product;
  }

  runBidsToastTimer(BidRecord data) {
    try {
      var amount =
          formatMoney(data.amount, fractionDigits: 2).output.symbolOnLeft;
      var toast = MyToastModel(null, ToastType.success,
          child: Container(
            decoration: BoxDecoration(
                color: getTheme(context).primaryColor.darken(60),
                borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                capText(data.name, context!, color: Colors.white),
                width10(),
                capText(amount, context!, color: Colors.white),
                // width5(),
                // assetSvg(MySvg.diamond, width: 10, height: 10)
              ],
            ),
          ));
      if (context!.mounted) {
        context!.showToast<MyToastModel>(toast);
      }
    } catch (e) {
      logger.e('Error showToast: $e');
    }
  }

  ///add to stream
  void addToStream(dynamic data, {bool addToast = true}) {
    List<BidRecord> oldList = bidList.map((e) => e).toList();
    logger.i('oldList: ${oldList.map((e) => e.name).toList()}');
    int oldIndex = -1;

    ///if bid is null then get all bids
    if (data != null && data is List<BidRecord>) {
      data.sort((a, b) => b.amount.compareTo(a.amount));
      bidList = data;
      update();
      setHighestBid(data.isEmpty
          ? (auctionProduct!.price.getDouble() + 1)
          : (data.first.amount + 1));
      if (addToast) runBidsToastTimer(data.first);
    }

    ///if bid is already in list then update it
    else if (data != null && data is BidRecord) {
      ///if bid is already in list then update it
      if (bidList.any((element) => element.name == data.name)) {
        var bid = bidList.firstWhere((element) => element.name == data.name);
        bid.amount = data.amount;
        bidList.remove(bid);
        bidList.add(bid);
      } else {
        bidList.add(data);
      }
      bidList.sort((a, b) => b.amount.compareTo(a.amount));
      update();
      setHighestBid(data.amount + 1);
      if (addToast) runBidsToastTimer(data);
    }

    ///maniuplate list ui according to new data
    if (context != null) {
      try {
        if (bidList.length > 1) {
          var newHighestBid = bidList.first;
          logger.i(
              'newHighestBid: ${newHighestBid.name} ${oldList.map((e) => e.name).toList()}');

          if (oldList.any((element) => element.name == newHighestBid.name)) {
            oldIndex = oldList
                .indexWhere((element) => element.name == newHighestBid.name);

            logger.i('oldIndex: $oldIndex');
            if (oldIndex == 0) {
              controller.notifyChangedRange(
                  0, 1, (context, index, data) => Container(color: redDark));
            }
            controller.notifyMovedRange(oldIndex, 1, 0);
            logger.i('moved to : 0');
          } else {
            controller.notifyInsertedRange(0, 1);
            logger.i('inserted at : 0');
          }
        }

        ///else notifiy modification
        else {
          logger.i('modifing at : 0');
          controller.notifyChangedRange(
              0, 1, (context, index, data) => Container(color: redDark));
        }
      } catch (e) {
        logger.e('addToStream  reorder error: ', tag: tag, error: e);
      }
    }
    logger.i('bidList: ${bidList.length}');
  }

  BuildContext? context;

  ///place a bid
  Future<Map<String, dynamic>?> placeABid(double amount) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.placeBid,
          body: {'product_id': auctionProduct!.id, 'amount': amount},
          method: ApiMethod.POST);
      return res;
    } catch (e) {
      logger.e('Place a bid error', tag: tag, error: e);
    }
    return null;
  }

  ///bid list for live
  Future<List<BidRecord>> getAllBids() async {
    try {
      var res = await ApiHandler.hitApi(
          '${ApiConst.productBids}?product_id=${auctionProduct!.id}',
          method: ApiMethod.GET);
      return res != null
          ? (res['bids'] as List)
              .map((e) {
                var data = {
                  'bid_amount': e['amount'],
                  'username': e['user']['username'],
                  'profile_image': e['user']['image']
                };
                return BidRecord.fromJson(data);
              })
              .toList()
              .reversed
              .toList()
          : [];
    } catch (e) {
      logger.e('getAllBids error: ', tag: tag, error: e);
    }
    return [];
  }

  ///bid list with pagination
  List<BidRecord> bidListWithPagination = [];
  int bidPage = 1;
  bool bidLoading = false;
  int bidTotal = 0;
  Future<List<BidRecord>> getBidListWithPagination({
    int pageNo = 1,
    int perPage = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        bidLoading = true;
        update();
      }
      bidPage = pageNo;
      Uri uri = Uri.parse(ApiConst.productBids);
      uri = uri.replace(queryParameters: {
        'page_no': '$pageNo',
        'per_page': '$perPage',
        'product_id': '${auctionProduct!.id}'
      });
      logger.i('getBidListWithPagination uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.toString(), method: ApiMethod.GET);
      if (res != null && res['status'] == true) {
        bidTotal = res['total_data'] ?? 0;
        if (pageNo == 1) {
          bidListWithPagination = await _getBidListFromJson(res['bids']);
        } else {
          bidListWithPagination.addAll(await _getBidListFromJson(res['bids']));
        }
      }
      bidLoading = false;
      update();
      return bidListWithPagination;
    } catch (e) {
      logger.e('getBidListWithPagination error: ', tag: tag, error: e);
    }
    bidLoading = false;
    update();
    return [];
  }

  ///get all reviews for product
  List<AuctionReview> reviews = [];
  int reviewPage = 1;
  bool reviewLoading = false;
  int reviewTotal = 0;

  Future<List<AuctionReview>> getAllReviews({
    int pageNo = 1,
    int perPage = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        reviewLoading = true;
        update();
      }
      reviewPage = pageNo;
      Uri uri = Uri.parse(ApiConst.productAllRatings);
      uri = uri.replace(queryParameters: {
        'page_no': '$pageNo',
        'per_page': '$perPage',
        'product_id': '${auctionProduct!.id}'
      });
      logger.i('getAllReviews uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.toString(), method: ApiMethod.GET);
      if (res != null && res['status'] == true) {
        reviewTotal = res['total_data'] ?? 0;
        if (pageNo == 1) {
          reviews = await _getReviewsFromJson(res['ratings']);
        } else {
          reviews.addAll(await _getReviewsFromJson(res['ratings']));
        }
      }
      reviewLoading = false;
      update();
      return reviews;
    } catch (e) {
      logger.e('getAllReviews error: ', tag: tag, error: e);
    }
    reviewLoading = false;
    update();
    return [];
  }

  ///get all reviews from json
  Future<List<AuctionReview>> _getReviewsFromJson<T>(dynamic json) async {
    List<AuctionReview> reviews = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(() =>
            reviews = json.map((e) => AuctionReview.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getReviewsFromJson $T error: ', tag: tag, error: e);
    }
    return reviews;
  }

  ///get all bids from json
  Future<List<BidRecord>> _getBidListFromJson<T>(dynamic json) async {
    List<BidRecord> bids = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(() => bids = json.map((e) {
              var data = {
                'bid_amount': e['amount'],
                'username': e['user']['username'],
                'profile_image': e['user']['image'],
                'created_at': e['created_at'],
                'updated_at': e['updated_at'],
              };
              return BidRecord.fromJson(data);
            }).toList());
      }
    } catch (e) {
      logger.e('_getBidListFromJson $T error: ', tag: tag, error: e);
    }
    return bids;
  }

  /// rate product
  Future<bool> rateProduct(double rating, {String? desc}) async {
    try {
      var res = await ApiHandler.hitApi(ApiConst.rateProduct,
          body: {
            'product_id': auctionProduct!.id,
            'rating': rating,
            'description': desc
          },
          method: ApiMethod.POST);
      bool success = res != null && res['status'] == true;
      if (success) {
        auctionProduct!.avgRating =
            double.tryParse((res['avg_rating'] ?? '0.0').toString()) ?? 0.0;
        if (res['last_review'] != null) {
          auctionProduct!.userReview =
              AuctionReview.fromJson(res['last_review']);
        }
        update();
      }
      return success;
    } catch (e) {
      logger.e('rateProduct error: ', tag: tag, error: e);
    }
    return false;
  }
}

class BidRecord {
  double amount;
  String name;
  String profilePic;
  DateTime? createdAt;
  DateTime? updatedAt;
  BidRecord(
      {required this.amount, required this.name, required this.profilePic});

  BidRecord.fromJson(Map<String, dynamic> json)
      : amount = (json['bid_amount'] ?? 0.0).toString().getDouble(),
        name = json['username'] ?? '',
        profilePic = json['profile_image'] ?? '',
        createdAt = json['created_at'] != null
            ? DateTime.tryParse(json['created_at'])
            : null,
        updatedAt = json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'])
            : null;

  Map<String, dynamic> toJson() => {
        'bid_amount': amount,
        'username': name,
        'profile_image': profilePic,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };
}
