import 'package:action_tds/app/modules/auction_detail/controllers/auction_detail_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/component_index.dart';

class AuctionBidsHistory extends StatefulWidget {
  const AuctionBidsHistory({super.key});

  @override
  State<AuctionBidsHistory> createState() => _AuctionBidsHistoryState();
}

class _AuctionBidsHistoryState extends State<AuctionBidsHistory> {
  var controller = Get.put(AuctionDetailController());
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      controller.getBidListWithPagination(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      topMargin: getHeight(context) * 0.2,
      builder: (bound) => GetBuilder<AuctionDetailController>(
        builder: (auctCtrl) {
          return _BuildBidsList(auctCtrl);
        },
      ),
    );
  }
}

class _BuildBidsList extends StatelessWidget {
  const _BuildBidsList(this.controller);
  final AuctionDetailController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.bidLoading;
    return LoadMoreContainer(
        finishWhen:
            controller.bidListWithPagination.length >= controller.bidTotal,
        onLoadMore: () async {
          await controller.getBidListWithPagination(
              pageNo: controller.bidPage + 1);
        },
        onRefresh: () async {
          await controller.getBidListWithPagination(pageNo: 1, refresh: true);
        },
        builder: (scroll, status) {
          int total = loading ? 15 : controller.bidListWithPagination.length;

          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: (!loading && controller.bidListWithPagination.isEmpty)
                  ? _emptyBidHistory(scroll, context)
                  : ListView.separated(
                      controller: scroll,
                      padding: EdgeInsets.all(paddingDefault),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: total,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return _LargeBidCard(
                          // height: height,
                          bid: loading
                              ? null
                              : controller.bidListWithPagination[index],
                          loading: loading,
                        );
                      },
                      separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: getTheme(context)
                              .primaryColorDark
                              .withOpacity(0.2)),
                    ));
        });
  }

  SingleChildScrollView _emptyBidHistory(
      ScrollController scroll, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.all(paddingDefault),
      controller: scroll,
      child: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            height10(getHeight() * 0.1),
            assetLottie(MyLottie.bidSearching, width: 300),
            height10(spaceDefault * 3),
            Center(
                child: AutoSizeText(
              'Bids record will appear here',
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

class _LargeBidCard extends StatefulWidget {
  const _LargeBidCard({
    this.height,
    this.bid,
    required this.loading,
    this.width,
  });

  final double? height;
  final double? width;
  final BidRecord? bid;
  final bool loading;

  @override
  State<_LargeBidCard> createState() => _LargeBidCardState();
}

class _LargeBidCardState extends State<_LargeBidCard> {
  @override
  Widget build(BuildContext context) {
    String? image = widget.loading ? '' : widget.bid?.profilePic.validate();

    return DefaultRefreshEffect(
      loading: widget.loading,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(paddingDefault),
        child: LayoutBuilder(builder: (context, bound) {
          return Container(
            height: widget.height,
            width: widget.width ?? bound.maxWidth,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(paddingDefault),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          getTheme(context).primaryColorDark.withOpacity(0.2)),
                  padding: EdgeInsets.all(paddingDefault * 0.5),
                  child: image.isEmptyOrNull
                      ? widget.loading
                          ? SizedBox(
                              height: getHeight(context) * 0.03,
                              width: getHeight(context) * 0.03,
                            )
                          : assetImages(
                              MyPng.dummyUser,
                              height: getHeight(context) * 0.03,
                              width: getHeight(context) * 0.03,
                            )
                      : buildCachedImageWithLoading(
                          image!,
                          fit: BoxFit.contain,
                          borderRadius: paddingDefault,
                          placeholder: MyPng.watchPlaceholder,
                          h: getHeight(context) * 0.03,
                          w: getHeight(context) * 0.03,
                        ),
                ),
                width10(spaceDefault),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        (widget.bid?.name ?? '-----------------').capitalize!,
                        style: getTheme(context).textTheme.bodyLarge,
                        maxLines: 10,
                        minFontSize: 10,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.start,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            (widget.bid != null)
                                ? formatMoney(widget.bid!.amount)
                                    .output
                                    .symbolOnLeft
                                : '\$ 0.00',
                            style: getTheme(context).textTheme.bodySmall,
                            maxLines: 2,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                          ),

                          ///time
                          AutoSizeText(
                            MyDateUtils.formatDateAsToday(
                                widget.bid?.updatedAt ??
                                    widget.bid?.createdAt ??
                                    '',
                                'dd MMM yyyy hh:mm a'),
                            style: getTheme(context).textTheme.bodySmall,
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
          );
        }),
      ),
    );
  }
}
