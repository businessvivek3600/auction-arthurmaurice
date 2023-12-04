import 'package:action_tds/app/modules/bottomNav/transactions/controller/transactionController.dart';

import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/component_index.dart';
import '../../../../../components/home_page_refresh_effect.dart';

class DepositeHistory extends StatefulWidget {
  DepositeHistory({super.key});

  @override
  State<DepositeHistory> createState() => _DepositeHistoryState();
}

class _DepositeHistoryState extends State<DepositeHistory> {
  var controller = Get.put(TransactionController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getDeposits(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionController>(
      initState: (state) {},
      dispose: (_) {
        Get.delete<TransactionController>();
      },
      builder: (categoryCtrl) {
        return _BuildDepositsList(categoryCtrl);
      },
    );
  }
}

class _BuildDepositsList extends StatelessWidget {
  const _BuildDepositsList(this.controller, {super.key});
  final TransactionController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.loadingDeposits;
    return LoadMoreContainer(
        finishWhen: controller.deposits.length >= controller.totalDeposits,
        onLoadMore: () async {
          await controller.getDeposits(pageNo: controller.depositPage + 1);
        },
        onRefresh: () async {
          await controller.getDeposits(pageNo: 1, refresh: true);
        },
        builder: (scroll, status) {
          int total = loading ? 15 : controller.deposits.length;

          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: (!loading && controller.deposits.isEmpty)
                  ? _emptyDepositHistory(scroll, context)
                  : ListView.builder(
                      controller: scroll,
                      padding: EdgeInsets.all(paddingDefault),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: total + 2,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        bool isLast = index == total || index == total + 1;
                        final height = getHeight(context) * 0.15 > 120.0
                            ? getHeight(context) * 0.15
                            : 120.0;
                        return !isLast
                            ? _LargeDepositeCard(
                                // height: height,
                                deposit:
                                    loading ? null : controller.deposits[index],
                                loading: loading,
                              )
                            : Container(
                                height: height.toDouble(),
                                margin:
                                    EdgeInsets.only(bottom: paddingDefault));
                      },
                    ));
        });
  }

  SingleChildScrollView _emptyDepositHistory(
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
              'No Deposits Found',
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

class _LargeDepositeCard extends StatefulWidget {
  const _LargeDepositeCard({
    super.key,
    this.height,
    this.deposit,
    this.width,
    required this.loading,
  });

  final double? height;
  final double? width;
  final Deposit? deposit;
  final bool loading;

  @override
  State<_LargeDepositeCard> createState() => _LargeDepositeCardState();
}

class _LargeDepositeCardState extends State<_LargeDepositeCard> {
  bool expand = false;
  @override
  Widget build(BuildContext context) {
    String? image = widget.loading ? '' : widget.deposit?.gateway?.image;
    bool expanded = widget.loading ? false : expand;

    return GestureDetector(
      onTap: widget.loading
          ? null
          : () {
              setState(() {
                expand = !expand;
              });
              // Get.toNamed('${Routes.auctionDetail}/${deposit!.product!.id}');
              // context.push('${Routes.auctionDetail}/${deposit!.product!.id}');
            },
      child: DefaultRefreshEffect(
        loading: widget.loading,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(paddingDefault),
          child: LayoutBuilder(builder: (context, bound) {
            return Container(
              height: widget.height,
              width: widget.width ?? bound.maxWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: getTheme(context).primaryColorDark,
              ),
              padding: EdgeInsets.all(paddingDefault),
              margin: EdgeInsets.only(bottom: paddingDefault),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCachedImageWithLoading(
                        image ?? '',
                        fit: BoxFit.cover,
                        borderRadius: paddingDefault,
                        placeholder: MyPng.watchPlaceholder,
                        h: getHeight(context) * 0.05,
                        w: getHeight(context) * 0.05,
                      ),
                      width10(spaceDefault),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    (widget.deposit?.gateway?.alias ??
                                            '-----------------')
                                        .capitalize!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 10,
                                    minFontSize: 10,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                ),

                                ///dropdown icon with animation rotation
                                if (widget.deposit != null)
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    transform:
                                        Matrix4.rotationZ(expanded ? 3.14 : 0),
                                    transformAlignment: Alignment.center,
                                    child: const Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                            AutoSizeText(
                              (widget.deposit != null &&
                                      widget.deposit!.finalAmo != null)
                                  ? formatMoney(widget.deposit!.finalAmo!)
                                      .output
                                      .symbolOnLeft
                                  : '\$ 0.00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ///build updated time
                                AutoSizeText(
                                  MyDateUtils.formatDateAsToday(
                                      widget.deposit?.updatedAt ??
                                          widget.deposit?.createdAt ??
                                          '',
                                      'dd MMM yyyy hh:mm a'),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                ),
                              ],
                            ),

                            ///expanded then
                          ],
                        ),
                      ),

                      ///expanded then
                    ],
                  ),

                  ///expanded then
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: expanded ? null : 0,
                    child: Column(
                      children: [
                        ///build amount
                        Row(
                          children: [
                            const Expanded(
                              child: AutoSizeText(
                                'Amount',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            AutoSizeText(
                              (widget.deposit != null &&
                                      widget.deposit!.amount != null)
                                  ? formatMoney(widget.deposit!.amount!)
                                      .output
                                      .symbolOnLeft
                                  : '\$ 0.00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        ///build charge
                        Row(
                          children: [
                            Expanded(
                              child: AutoSizeText(
                                'Charge (${widget.deposit?.rate.toString().getDouble()}%)',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            AutoSizeText(
                              (widget.deposit != null &&
                                      widget.deposit!.charge != null)
                                  ? formatMoney(widget.deposit!.charge!)
                                      .output
                                      .symbolOnLeft
                                  : '\$ 0.00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        ///build transaction id
                        Row(
                          children: [
                            const Expanded(
                              child: AutoSizeText(
                                'Transaction ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.start,
                              ),
                            ),
                            AutoSizeText(
                              widget.deposit?.trx ?? '',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),

                        /// build detials
                        if (widget.deposit?.detail != null &&
                            widget.deposit!.detail!.isNotEmpty)
                          Row(
                            children: [
                              const Expanded(
                                child: AutoSizeText(
                                  'Details',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  minFontSize: 10,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                              AutoSizeText(
                                widget.deposit?.detail ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 2,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
