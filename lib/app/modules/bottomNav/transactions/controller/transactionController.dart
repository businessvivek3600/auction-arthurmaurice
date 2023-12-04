import 'package:flutter/material.dart';

import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import 'package:get/get.dart';

import '../../../../../database/connect/api_handler.dart';
import '../../../../../utils/utils_index.dart';

class TransactionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  static const tag = 'TransactionController';
  late TabController tabController;
  @override
  void onInit() {
    tabController = TabController(length: 2, vsync: this);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    deposits.clear();
    // winningDeposits.clear();
    totalDeposits = 0;
    // totalWinningDeposits = 0;
    depositPage = 1;
    // pageWinningDeposits = 1;
    super.onClose();
  }

  List<Deposit> deposits = [];
  int totalDeposits = 0;
  bool loadingDeposits = true;
  int depositPage = 1;
  setLoading(bool val) {
    loadingDeposits = val;
    update();
  }

  Future<void> getDeposits({
    int pageNo = 1,
    int perPage = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        loadingDeposits = true;
        update();
      }
      depositPage = pageNo;
      Uri uri = Uri.parse(ApiConst.getDeposits);
      uri = uri.replace(
          queryParameters: {'page_no': '$pageNo', 'per_page': '$perPage'});
      logger.i('getDeposit uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.path, method: ApiMethod.GET);
      if (res != null) {
        totalDeposits = res['data']['deposit']['total'];
        if (pageNo == 1) {
          deposits = await _getDepositsFromJson(res['data']['deposit']['data']);
        } else {
          deposits.addAll(
              await _getDepositsFromJson(res['data']['deposit']['data']));
        }
      }
    } catch (e) {
      logger.e('getDeposit error: $e', tag: tag, error: e);
    }
    loadingDeposits = false;
    update();
  }

  Future<List<Deposit>> _getDepositsFromJson<T>(dynamic json) async {
    List<Deposit> Deposits = [];

    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => Deposits = json.map((e) => Deposit.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getCategoryListFromJson $T error: ', tag: tag, error: e);
    }
    return Deposits;
  }

  List<Transaction> transactions = [];
  int totalTransactions = 0;
  bool loadingTransactions = true;
  int transactionPage = 1;
  setTransactionLoading(bool val) {
    loadingTransactions = val;
    update();
  }

  Future<void> getTransactions({
    int pageNo = 1,
    int perPage = 10,
    bool refresh = false,
  }) async {
    try {
      if (refresh) setTransactionLoading(true);
      transactionPage = pageNo;
      Uri uri = Uri.parse(ApiConst.getTransactions);
      uri = uri.replace(
          queryParameters: {'page': '$pageNo', 'per_page': '$perPage'});
      logger.i('getTransactions uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.path, method: ApiMethod.GET);
      if (res != null) {
        totalTransactions = res['data']['transactions']['total'];
        if (pageNo == 1) {
          transactions = await _getTransactionsFromJson(
              res['data']['transactions']['data']);
        } else {
          transactions.addAll(await _getTransactionsFromJson(
              res['data']['transactions']['data']));
        }
      }
    } catch (e) {
      logger.e('getTransactions error: $e', tag: tag, error: e);
    }
    loadingTransactions = false;
    update();
  }

  Future<List<Transaction>> _getTransactionsFromJson<T>(dynamic json) async {
    List<Transaction> transactions = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(() =>
            transactions = json.map((e) => Transaction.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getCategoryListFromJson $T error: ', tag: tag, error: e);
    }
    return transactions;
  }
}
