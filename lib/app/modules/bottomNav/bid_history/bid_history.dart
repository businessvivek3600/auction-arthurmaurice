import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '/app/models/auction_app/auction_model_index.dart';
import '/app/modules/bottomNav/bid_history/controllers/bidController.dart';
import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../../components/component_index.dart';
import '../../../routes/app_pages.dart';

class UserBidHistory extends StatefulWidget {
  const UserBidHistory({super.key});

  @override
  State<UserBidHistory> createState() => _UserBidHistoryState();
}

class _UserBidHistoryState extends State<UserBidHistory> {
  var controller = Get.put(BidController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getBids(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BidController>(
      initState: (state) {},
      dispose: (_) {
        Get.delete<BidController>();
      },
      builder: (categoryCtrl) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            systemOverlayStyle: getTransaparentAppBarStatusBarStyle(context),
            title: displayLarge('Bid History', context),
            centerTitle: false,
          ),
          body: _BuildCategoriesList(categoryCtrl),
        );
      },
    );
  }
}

class _BuildCategoriesList extends StatelessWidget {
  const _BuildCategoriesList(this.controller);
  final BidController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.loading;
    logger.f('loading: $loading ${controller.bids.length}');
    return LoadMoreContainer(
        finishWhen: controller.bids.length >= controller.totalBids,
        onLoadMore: () async {
          await controller.getBids(pageNo: controller.page + 1);
        },
        onRefresh: () async {
          await controller.getBids(pageNo: 1, refresh: true);
        },
        builder: (scroll, status) {
          int total = loading ? 15 : controller.bids.length;
          if ((!loading && controller.bids.isEmpty)) {
            return _emptyBidHistory(scroll, context);
          }
          return ListView.builder(
            controller: scroll,
            padding: EdgeInsets.all(paddingDefault),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: total + 2,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              bool isLast = index == total || index == total + 1;
              final height =
                  Get.height * 0.15 > 120.0 ? Get.height * 0.15 : 120.0;
              return !isLast
                  ? _LargeBidCard(
                      // height: height,
                      bid: loading ? null : controller.bids[index],
                      loading: loading,
                    )
                  : Container(
                      height: height.toDouble(),
                      margin: EdgeInsets.only(bottom: paddingDefault));
            },
          );
        });
  }

  SingleChildScrollView _emptyBidHistory(
      ScrollController scroll, BuildContext context) {
    return SingleChildScrollView(
      controller: scroll,
      child: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            height10(getHeight() * 0.1),
            assetLottie(MyLottie.bid),
            height10(spaceDefault * 3),
            Center(
                child: AutoSizeText(
              'No bid history found',
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

class _LargeBidCard extends StatelessWidget {
  const _LargeBidCard({
    this.height,
    this.bid,
    this.width,
    required this.loading,
  });

  final double? height;
  final double? width;
  final Bid? bid;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    String? image = loading ? '' : bid?.product?.image.validate();
    double avgRating = loading ? 0.0 : bid?.product?.avgRating ?? 0.0;
    int totalBids = loading ? 0 : bid?.product?.totalBids ?? 0;
    return GestureDetector(
      onTap: loading || bid?.product?.id == null
          ? null
          : () {
              context.push('${Routes.auctionDetail}/${bid!.product!.id}');
            },
      child: DefaultRefreshEffect(
        loading: loading,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(paddingDefault),
          child: LayoutBuilder(builder: (context, bound) {
            return Container(
              height: height,
              width: width ?? bound.maxWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: getTheme(context).primaryColorDark,
              ),
              padding: EdgeInsets.all(paddingDefault),
              margin: EdgeInsets.only(bottom: paddingDefault),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ///product image
                  Expanded(
                    flex: 1,
                    child: Stack(
                      children: [
                        buildCachedImageWithLoading(image ?? '',
                            fit: BoxFit.cover,
                            borderRadius: 10,
                            placeholder: MyPng.watchPlaceholder),

                        ///avg rating
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: getTheme(context).primaryColor,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  topRight: Radius.circular(10)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.star,
                                      color: Colors.amber,
                                      size: getTheme()
                                          .textTheme
                                          .bodyLarge
                                          ?.fontSize),
                                  width5(),
                                  AutoSizeText(
                                    avgRating.toStringAsFixed(1),
                                    style: getTheme()
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  width10(spaceDefault),

                  ///product details
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          bid?.product?.name ??
                              'Product name not found in bid history',
                          style: getTheme(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                          maxLines: 2,
                          minFontSize: 15,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),

                        ///timer and bid amount
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AutoSizeText(
                              (bid != null && bid!.amount != null)
                                  ? formatMoney(bid!.amount.getDouble())
                                      .output
                                      .symbolOnLeft
                                  : '\$ 0.00',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (!loading)
                              Expanded(child: _buildTimerColumn(bid!.product!))
                          ],
                        ),

                        ///updated time
                        height5(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ///bid count
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                faIcon(FontAwesomeIcons.gavel,
                                    size: getTheme()
                                            .textTheme
                                            .bodyLarge
                                            ?.fontSize ??
                                        16),
                                width5(),
                                AutoSizeText(
                                  totalBids.toString(),
                                  style: getTheme()
                                      .textTheme
                                      .bodySmall!
                                      .copyWith(color: Colors.white),
                                ),
                              ],
                            ),

                            ///build updated time
                            AutoSizeText(
                              MyDateUtils.formatDateAsToday(
                                  bid?.updatedAt ?? bid?.createdAt ?? '',
                                  'dd MMM yyyy hh:mm a'),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
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

  _buildTimerColumn(AuctionProduct auction) {
    final (started, ended, duration, endDate) =
        auction.isStartedButNotCompleted(auction.startDate, auction.endDate);
    Color color = started && !ended
        ? Colors.redAccent
        : !started && !ended
            ? Colors.white.withOpacity(0.8)
            : Colors.white.withOpacity(0.8);
    return
        // if (started && !ended)  and duration != null
        duration != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _timer(color, duration, started && !ended),
                ],
              )
            : AutoSizeText('Ended $endDate',
                style: getTheme().textTheme.bodySmall!.copyWith(color: color),
                textAlign: TextAlign.end);
  }

  SlideCountdown _timer(Color color, Duration duration, bool isLive) {
    return SlideCountdown(
      decoration: BoxDecoration(
          color: isLive
              ? const Color.fromARGB(255, 251, 1, 1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(paddingDefault * 0.5)),
      style: getTheme().textTheme.bodySmall!.copyWith(color: Colors.white),
      duration: duration,
      durationTitle: DurationTitle.idShort(),
      shouldShowDays: (d) => true,
      shouldShowHours: (d) => true,
      shouldShowMinutes: (d) => true,
      shouldShowSeconds: (d) => true,
      textStyle: getTheme()
          .textTheme
          .bodySmall!
          .copyWith(color: Colors.white.withOpacity(0.8)),
      separator: ':',
      separatorType: SeparatorType.symbol,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      onChanged: (value) {
        // print(value);
      },
      onDone: () {},
    );
  }
}
