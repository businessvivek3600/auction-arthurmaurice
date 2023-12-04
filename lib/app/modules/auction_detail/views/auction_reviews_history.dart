import 'package:action_tds/app/models/auction_app/auction_model_index.dart';
import 'package:action_tds/app/modules/auction_detail/controllers/auction_detail_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '/constants/constants_index.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../components/component_index.dart';

class AuctionReviewsHistory extends StatefulWidget {
  const AuctionReviewsHistory({super.key});

  @override
  State<AuctionReviewsHistory> createState() => _AuctionReviewsHistoryState();
}

class _AuctionReviewsHistoryState extends State<AuctionReviewsHistory> {
  var controller = Get.put(AuctionDetailController());
  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      controller.getAllReviews(refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomBottomsheet(
      topMargin: getHeight(context) * 0.2,
      builder: (bound) => GetBuilder<AuctionDetailController>(
        builder: (auctCtrl) {
          return _BuildReviewsList(auctCtrl);
        },
      ),
    );
  }
}

class _BuildReviewsList extends StatelessWidget {
  const _BuildReviewsList(this.controller);
  final AuctionDetailController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.reviewLoading;
    return LoadMoreContainer(
        finishWhen: controller.reviews.length >= controller.reviewTotal,
        onLoadMore: () async {
          await controller.getAllReviews(pageNo: controller.reviewPage + 1);
        },
        onRefresh: () async {
          await controller.getAllReviews(pageNo: 1, refresh: true);
        },
        builder: (scroll, status) {
          int total = loading ? 15 : controller.reviews.length;

          return AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: (!loading && controller.reviews.isEmpty)
                  ? _emptyReviewsHistory(scroll, context)
                  : ListView.separated(
                      controller: scroll,
                      padding: EdgeInsets.all(paddingDefault),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: total,
                      scrollDirection: Axis.vertical,
                      itemBuilder: (context, index) {
                        return _LargeReviewCard(
                          // height: height,
                          review: loading ? null : controller.reviews[index],
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

  SingleChildScrollView _emptyReviewsHistory(
      ScrollController scroll, BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.all(paddingDefault),
      controller: scroll,
      child: SizedBox(
        height: Get.height,
        child: Column(
          children: [
            height10(getHeight() * 0.1),
            assetLottie(MyLottie.reviews, width: 300),
            height10(spaceDefault * 3),
            Center(
                child: AutoSizeText(
              'Reviews will be appear here',
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

class _LargeReviewCard extends StatefulWidget {
  const _LargeReviewCard({
    this.height,
    this.review,
    this.width,
    required this.loading,
  });

  final double? height;
  final double? width;
  final AuctionReview? review;
  final bool loading;

  @override
  State<_LargeReviewCard> createState() => _LargeReviewCardState();
}

class _LargeReviewCardState extends State<_LargeReviewCard> {
  @override
  Widget build(BuildContext context) {
    String? image = widget.review?.profilePic.validate() ?? '';
    String? name = widget.review?.username.validate() ?? 'Dummy User Name ';

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///image and name ,rating , time
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///image
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            getTheme(context).primaryColorDark.withOpacity(0.2),
                      ),
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
                              image,
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
                            name,
                            style: getTheme(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 10,
                            minFontSize: 10,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ///rating
                              RatingBar.builder(
                                initialRating: widget.review?.rating ?? 0.0,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                glow: false,
                                ignoreGestures: true,
                                itemSize: bound.maxWidth * 0.04,
                                itemBuilder: (context, i) {
                                  late Widget child;
                                  switch (i) {
                                    case 0:
                                      child = const FaIcon(
                                          FontAwesomeIcons.solidStar,
                                          color: Colors.amber);
                                    case 1:
                                      child = const FaIcon(
                                          FontAwesomeIcons.solidStar,
                                          color: Colors.amber);
                                    case 2:
                                      child = const FaIcon(
                                          FontAwesomeIcons.solidStar,
                                          color: Colors.amber);
                                    case 3:
                                      child = const FaIcon(
                                          FontAwesomeIcons.solidStar,
                                          color: Colors.amber);
                                    case 4:
                                      child = const FaIcon(
                                          FontAwesomeIcons.solidStar,
                                          color: Colors.amber);
                                  }
                                  return child;
                                },
                                onRatingUpdate: (double value) {},
                              ),

                              width10(spaceDefault),

                              ///time
                              AutoSizeText(
                                MyDateUtils.getTimeDifference(
                                    widget.review?.updatedAt ??
                                        widget.review?.createdAt ??
                                        ''),
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

                ///description
                height10(spaceDefault),
                AutoSizeText(
                  (widget.review?.description ??
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation')
                      .capitalize!,
                  style: getTheme(context).textTheme.bodySmall,
                  maxLines: 10,
                  minFontSize: 10,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
