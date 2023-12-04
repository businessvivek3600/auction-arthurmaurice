import 'package:action_tds/app/modules/bottomNav/transactions/controller/transactionController.dart';
import 'package:timelines/timelines.dart';

import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/component_index.dart';
import '../../../../../components/home_page_refresh_effect.dart';

class TransactionHistory extends StatefulWidget {
  TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  var controller = Get.put(TransactionController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getTransactions(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      dispose: (_) {
        Get.delete<TransactionController>();
      },
      builder: (categoryCtrl) {
        return _BuildTransactionsList(categoryCtrl);
      },
    );
  }
}

class _BuildTransactionsList extends StatelessWidget {
  const _BuildTransactionsList(this.controller, {super.key});
  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.loadingTransactions;
    logger.f('loading: $loading ${controller.transactions.length}');
    return LoadMoreContainer(
        finishWhen:
            controller.transactions.length >= controller.totalTransactions,
        onLoadMore: () async {
          await Future.delayed(const Duration(seconds: 5));
          await controller.getTransactions(
              pageNo: controller.transactionPage + 1);
        },
        onRefresh: () async {
          await controller.getTransactions(pageNo: 1, refresh: true);
        },
        builder: (scroll, status) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 1000),
            transitionBuilder: (child, animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: (!loading && controller.transactions.isEmpty)
                ? _emptyTransactionHistory(scroll, context)
                : ListView(
                    controller: scroll,
                    children: [
                      _MyIncomeActivityHistoryList(
                          transactions: controller.transactions,
                          loading: loading),
                    ],
                  ),
          );
        });
  }

  SingleChildScrollView _emptyTransactionHistory(
      ScrollController scroll, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.all(paddingDefault),
      controller: scroll,
      child: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            height10(getHeight() * 0.1),
            assetLottie(MyLottie.bankTransaction, width: 300),
            height10(spaceDefault * 3),
            Center(
                child: AutoSizeText(
              'No Transaction History Found',
              style: getTheme(context).textTheme.titleLarge,
              maxLines: 2,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            )),
          ],
        ),
      ),
    );
  }
}

class _MyIncomeActivityHistoryList extends StatelessWidget {
  const _MyIncomeActivityHistoryList(
      {Key? key, required this.transactions, required this.loading})
      : super(key: key);

  final List<Transaction> transactions;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    int total = loading ? 15 : transactions.length;

    return DefaultTextStyle(
      style: const TextStyle(color: Color(0xff9b9b9b), fontSize: 12.5),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: DefaultRefreshEffect(
          loading: loading,
          child: FixedTimeline.tileBuilder(
            mainAxisSize: MainAxisSize.min,
            theme: TimelineThemeData(
              nodePosition: 0,
              // color: const Color(0xff989898),
              indicatorTheme: const IndicatorThemeData(position: 0, size: 20.0),
              // connectorTheme: const ConnectorThemeData(thickness: 2.5),
            ),
            builder: TimelineTileBuilder.connected(
              connectionDirection: ConnectionDirection.before,
              itemCount: total,
              contentsBuilder: (_, index) {
                Transaction? activity = loading ? null : transactions[index];
                return _transactionTile(activity, context, index, loading);
              },
              indicatorBuilder: (_, index) {
                return OutlinedDotIndicator(
                  color: getTheme(context).primaryColorDark,
                  child: const Icon(Icons.check, size: 12.0),
                );
                // }
              },
              connectorBuilder: (_, index, ___) {
                return SolidLineConnector(
                  color: getTheme(context).primaryColorDark.withOpacity(0.5),
                  thickness: 1,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Padding _transactionTile(
      Transaction? transaction, BuildContext context, int index, bool loading) {
    Color? color = transaction?.trxType == '+' ? Colors.green : Colors.red;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: bodyLargeText(
                  MyDateUtils.formatDateAsToday(
                      transaction?.createdAt ?? transaction?.updatedAt ?? '',
                      'dd MMM yyyy hh:mm a'),
                  context,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.start,
                ),
              ),
              bodyMedText(
                formatMoney(transaction?.amount ?? 0).output.symbolOnLeft,
                context,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(color: color),
              ),
            ],
          ),
          height5(),
          capText(
              transaction?.details ??
                  (loading
                      ? 'Bid to Lorem Ipsum. "Neque porro quisquam est qui dolorem Integer mattis, erat eget dapibus pulvinar, lacus quam mattis'
                      : ''),
              context),
          height5(),
          if (transaction != null) _buildDetails(transaction, context),
          if (index < transactions.length - 1) height20(),
        ],
      ),
    );
  }

  Widget _buildDetails(Transaction transaction, BuildContext context) {
    return Column(
      children: [
        if (transaction.charge != null &&
            transaction.charge.toString().getDouble() > 0)
          Row(
            children: [
              capText(
                'Charge',
                context,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              capText(
                formatMoney(transaction.charge ?? 0, fractionDigits: 2)
                    .output
                    .symbolOnLeft,
                context,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),

        /// transaction id
        if (transaction.trx != null)
          Row(
            children: [
              capText(
                'Transaction ID',
                context,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
              capText(
                transaction.trx ?? '',
                context,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
      ],
    );
  }
}
