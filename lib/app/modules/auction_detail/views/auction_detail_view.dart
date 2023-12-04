// ignore_for_file: library_private_types_in_public_api

import 'dart:ui';

import 'package:action_tds/app/modules/auction_detail/views/auction_reviews_history.dart';
import 'package:action_tds/components/hero_tag_wdget.dart';
import 'package:action_tds/services/share.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:o3d/o3d.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../../../../utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import '../../../models/auction_app/auction_model.dart';
import '/components/component_index.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../../constants/asset_constants.dart';
import '../controllers/auction_detail_controller.dart';
import 'package:collection/collection.dart';
import 'aution_details_bid_popup_view.dart';
import 'auction_bids_history.dart';

class AuctionDetailView extends StatefulWidget {
  AuctionDetailView({Key? key, this.auctionId, this.path}) : super(key: key);
  final int? auctionId;
  final String? path;

  @override
  State<AuctionDetailView> createState() => _AuctionDetailViewState();
}

class _AuctionDetailViewState extends State<AuctionDetailView> {
  var c = Get.put(AuctionDetailController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (widget.auctionId != null) {
        c.setLoadingAuctionDetail(true);
        c.bidList.clear();
        c.getAuctionById(widget.auctionId!).then((value) => getAllBids());
      } else {
        c.setLoadingAuctionDetail(false);
      }
    });
  }

  getAllBids() async {
    var list = await c.getAllBids();
    // list.sort((a, b) => b.amount.compareTo(a.amount));
    c.bidList = list;
    setState(() {});
    c.addToStream(list, addToast: false);
  }

  @override
  void dispose() {
    c.context = null;
    c.pusher.disconnect();
    c.bidList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.w('args: ${Get.engine} ${widget.auctionId}  ${widget.path}');

    return GetBuilder<AuctionDetailController>(
      dispose: (state) {
        c.auctionProduct = null;
        Get.delete<AuctionDetailController>();
      },
      builder: (acutionDetailController) {
        return Scaffold(
          body: globalContainer(
            child: Stack(
              children: [
                /// addptive icon for back button

                /// body
                _Body(acutionDetailController),
                Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: _AppBar(
                        acutionDetailController: acutionDetailController,
                        path: widget.path ?? '')),
              ],
            ),
          ),
          bottomNavigationBar: acutionDetailController.auctionProduct != null
              ? _BottomNavigationBar(
                  acutionDetailController: acutionDetailController)
              : null,
        );
      },
    );
  }
}

class _BottomNavigationBar extends StatelessWidget {
  const _BottomNavigationBar({Key? key, required this.acutionDetailController})
      : super(key: key);
  final AuctionDetailController acutionDetailController;

  @override
  Widget build(BuildContext context) {
    AuctionProduct auction = acutionDetailController.auctionProduct!;
    return Container(
      height: (MediaQuery.of(context).viewInsets.bottom > 0
              ? 0.0
              : kBottomNavigationBarHeight) +
          (defaultTargetPlatform == TargetPlatform.iOS ? 20 : 0),
      padding: EdgeInsets.symmetric(horizontal: paddingDefault),
      decoration: BoxDecoration(
          color: getTheme(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(paddingDefault),
              topRight: Radius.circular(paddingDefault)),
          // border: Border.fromBorderSide(color: Colors.white70, width: 2),
          boxShadow: [
            BoxShadow(
              color: getTheme(context).primaryColorDark.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ]),
      child: Row(
        children: [
          ///bid button
          SizedBox(
            width: Get.width * 0.4,
            child: AspectRatio(
              aspectRatio: 4,
              child: TextButton.icon(
                onPressed: () {
                  showCupertinoModalPopup(
                      context: context, builder: (_) => AuctionBidsHistory());
                },
                icon: faIcon(FontAwesomeIcons.gavel,
                    color: getTheme().primaryColor),
                label: AutoSizeText(
                  'Bids (${auction.totalBids.validate()})',
                  minFontSize: 10,
                  // presetFontSizes: [20, 18, 16, 14, 12, 10],
                  style: getTheme().textTheme.displayLarge,
                ),
              ),
            ),
          ),

          ///buy now button
          SizedBox(
            width: Get.width * 0.4,
            child: AspectRatio(
              aspectRatio: 4,
              child: TextButton.icon(
                onPressed: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (_) => AuctionReviewsHistory());
                },
                icon: assetSvg(MySvg.diamond, height: 15, width: 15),
                label: AutoSizeText(
                  'Review (${auction.totalReviews.validate()})',
                  minFontSize: 10,
                  // presetFontSizes: [20, 18, 16, 14, 12, 10],
                  style: getTheme().textTheme.displayLarge,
                ),
              ),
            ),
          ),

          /// all bids icon button
          IconButton(
            onPressed: () {
              // Get.toNamed(Routes.autionDetail);
            },
            icon: Icon(Icons.adaptive.more),
          ),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  _AppBar({this.acutionDetailController, required this.path});
  final AuctionDetailController? acutionDetailController;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: appBarTopMargin(),
      padding: EdgeInsets.symmetric(horizontal: paddingDefault),
      child: Row(
        children: [
          const AppBackButton(onTap: null, filled: true),
          const Spacer(),

          ///share button
          IconButton.filledTonal(
            onPressed: () {
              var slug = (acutionDetailController?.auctionProduct?.name ?? '')
                  .toLowerCase()
                  .split(' ')
                  .join('-');
              AppShare.shareAnAuction(
                'Check out an awesome auction ${getAppPageUrl('$path/$slug')}',
                username: 'cks',
              );
            },
            icon: Icon(Icons.adaptive.share,
                color: getTheme(context).primaryColor),
          ),

          ///favorite button
          IconButton.filledTonal(
            onPressed: () {},
            icon: Icon(Icons.favorite_border_rounded,
                color: getTheme(context).primaryColor),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.acutionDetailController);
  final AuctionDetailController acutionDetailController;

  @override
  Widget build(BuildContext context) {
    return acutionDetailController.loadigAuctionDetail
        ? const Center(child: CircularProgressIndicator.adaptive())
        : ListView(
            padding: EdgeInsets.zero,
            children: [
              /// image slider
              ...acutionDetailController.auctionProduct != null
                  ? [
                      _AutionImagesBannerSlider(acutionDetailController),
                      _buildBody(),
                    ]
                  : [
                      SizedBox(
                          height: Get.height * 0.5,
                          child: const Center(
                              child: CupertinoActivityIndicator())),
                      SizedBox(
                          height: Get.height * 0.5,
                          child: Center(
                              child: Text('There is no auction available',
                                  style: getTheme().textTheme.titleLarge))),
                    ],
              height20(),
            ],
          );
  }

  Builder _buildBody() {
    return Builder(builder: (context) {
      AuctionProduct auction = acutionDetailController.auctionProduct!;
      var amount = formatMoney(auction.price.getDouble());

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingDefault),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// title
            height20(),

            ///timer container
            Column(
              children: [
                height20(),
                _BuildTimerWidget(
                  acutionDetailController: acutionDetailController,
                  auction: auction,
                ),
              ],
            ),

            /// current bid
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                height20(),
                LayoutBuilder(
                  builder: (context, bound) {
                    double productPrice = auction.price.getDouble();
                    double bidPrice = acutionDetailController.bidList.isNotEmpty
                        ? acutionDetailController.bidList
                            .reduce((value, element) =>
                                value.amount > element.amount ? value : element)
                            .amount
                        : 0;
                    bool priceIsHigher = bidPrice > productPrice;
                    return RichText(
                      text: TextSpan(
                        text: amount.output.symbolOnLeft,
                        style: (!priceIsHigher
                            ? getTheme().textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w900, color: Colors.red)
                            : getTheme().textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.grey,
                                  decoration: TextDecoration.lineThrough,
                                  decorationColor: Colors.grey,
                                  decorationThickness: 2,
                                  decorationStyle: TextDecorationStyle.solid,
                                )),
                        children: <TextSpan>[
                          if (priceIsHigher)
                            TextSpan(
                              text:
                                  '  ${formatMoney(bidPrice).output.symbolOnLeft}',
                              style: getTheme().textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.green),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            /// rating view
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        faIcon(FontAwesomeIcons.solidStar,
                            color: Colors.amber, size: paddingDefault),
                        width10(paddingDefault),
                        bodyLargeText(
                            auction.avgRating.toStringAsFixed(1), context),
                      ],
                    ),

                    ///add rating button
                    TextButton.icon(
                      onPressed: () {
                        showCupertinoDialog(
                            context: context,
                            builder: (_) =>
                                _ProductRatingDialog(product: auction));
                      },
                      icon: faIcon(FontAwesomeIcons.circlePlus,
                          color: getTheme().primaryColor),
                      label: AutoSizeText('Add rating',
                          minFontSize: 10,
                          presetFontSizes: const [20, 18, 16, 14, 12, 10],
                          style: getTheme().textTheme.titleLarge?.copyWith(
                              color: getTheme().primaryColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),

            /// seller detail
            if (auction.category != null)
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  height20(),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.transparent,
                        backgroundImage:
                            NetworkImage(auction.category!.icon ?? ''),
                      ),
                      width10(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // capText('Seller', context),
                          titleLargeText(auction.category!.name ?? '', context,
                              fontWeight: FontWeight.bold,
                              color: getTheme().textTheme.displayLarge?.color),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

            /// description
            height20(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  'Description',
                  minFontSize: 10,
                  presetFontSizes: const [20, 18, 16, 14, 12, 10],
                  style: getTheme()
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                height10(),
                descriptionView(auction.longDescription ?? ''),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget descriptionView(String html) => HtmlWidget(
        html,
        buildAsync: true,
        enableCaching: true,
        renderMode: RenderMode.column,
        onTapUrl: (link) async {
          Uri uri = Uri.parse(link);
          if (await canLaunchUrl(uri)) {
            launchUrl(uri);
          } else {
            Get.snackbar('Error', 'Cannot launch url');
          }
          return true;
        },
        textStyle: getTheme().textTheme.bodyLarge,
      );
}

class _ProductRatingDialog extends StatefulWidget {
  _ProductRatingDialog({
    super.key,
    required this.product,
  });
  final AuctionProduct product;
  @override
  State<_ProductRatingDialog> createState() => _ProductRatingDialogState();
}

class _ProductRatingDialogState extends State<_ProductRatingDialog> {
  final ValueNotifier<double> _rating = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _submitting = ValueNotifier<bool>(false);
  final reviewController = TextEditingController();
  var controller = Get.put(AuctionDetailController());

  @override
  void initState() {
    super.initState();
    afterBuildCreated(() {
      _rating.value = widget.product.userReview?.rating ?? 0.0;
      reviewController.text = widget.product.userReview?.description ?? '';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 20,
      backgroundColor: getTheme(context).scaffoldBackgroundColor,
      shadowColor:
          getTheme(context).textTheme.titleLarge?.color?.withOpacity(0.5),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(paddingDefault)),
      child: LayoutBuilder(
        builder: (context, bound) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// header
              Container(
                constraints: BoxConstraints(
                    minHeight: getHeight() * 0.08, maxWidth: double.infinity),
                padding: EdgeInsets.symmetric(horizontal: paddingDefault),
                child: Center(
                  child: bodyLargeText('Your opinion matters to us', context,
                      fontWeight: FontWeight.bold),
                ),
              ),

              /// rating bar
              Container(
                color: getTheme(context).primaryColorDark.withOpacity(0.1),
                padding: EdgeInsets.all(paddingDefault),
                child: Column(
                  children: [
                    height20(bound.maxHeight * 0.005),

                    /// rating bar
                    RatingBar.builder(
                      initialRating: _rating.value,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      glow: false,
                      itemSize: bound.maxWidth * 0.15,
                      itemBuilder: (context, i) {
                        late Widget child;
                        switch (i) {
                          case 0:
                            child = const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.amber);
                          case 1:
                            child = const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.amber);
                          case 2:
                            child = const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.amber);
                          case 3:
                            child = const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.amber);
                          case 4:
                            child = const FaIcon(FontAwesomeIcons.solidStar,
                                color: Colors.amber);
                        }
                        return child;
                      },
                      onRatingUpdate: (rating) => _rating.value = rating,
                    ),

                    /// text area
                    height20(bound.maxHeight * 0.015),
                    TextField(
                      controller: reviewController,
                      maxLines: 5,
                      style: getTheme(context).textTheme.bodyLarge,
                      onEditingComplete: _onEditingComplete,
                      onSubmitted: (val) => _onSubmitted(),
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        fillColor: getTheme(context).scaffoldBackgroundColor,
                        hintText: 'Write your review here',
                        enabledBorder: _getInputBorder(context),
                        focusedBorder: _getInputBorder(context, focused: true),
                        border: _getInputBorder(context),
                      ),
                    ),

                    /// submit button
                    height20(bound.maxHeight * 0.01),
                    ValueListenableBuilder(
                        valueListenable: _submitting,
                        builder: (context, val, _) {
                          return ElevatedButton.icon(
                            onPressed: val ? null : () => _onSubmitted(),
                            label: const AutoSizeText(
                              'Submit',
                              minFontSize: 10,
                              presetFontSizes: [20, 18, 16, 14, 12, 10],
                              // style: getTheme().textTheme.displayLarge,
                            ),
                            icon: val
                                ? const CupertinoActivityIndicator()
                                : Container(),
                          );
                        }),
                  ],
                ),
              ),

              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: AutoSizeText(
                  'Maybe later',
                  minFontSize: 10,
                  // presetFontSizes: const [20, 18, 16, 14, 12, 10],
                  style: getTheme().textTheme.bodySmall?.copyWith(
                      color: getTheme().primaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onEditingComplete() {
    0.1.delay().then((value) => primaryFocus?.unfocus());
  }

  void _onSubmitted() async {
    0.1.delay().then((value) => primaryFocus?.unfocus());
    if (_submitting.value) return;
    _submitting.value = true;
    await controller
        .rateProduct(_rating.value, desc: reviewController.text)
        .then((value) {
      _submitting.value = false;
      if (value) {
        Get.back();
        toast('Thank you for your review');
      }
    });
  }

  OutlineInputBorder _getInputBorder(BuildContext context,
      {bool focused = false}) {
    return OutlineInputBorder(
      borderSide: BorderSide(
        color: getTheme(context).primaryColorDark.withOpacity(0.1),
      ),
      borderRadius: BorderRadius.circular(paddingDefault),
    );
  }
}

class _BuildTimerWidget extends StatelessWidget {
  const _BuildTimerWidget({
    required this.acutionDetailController,
    required this.auction,
  });
  final AuctionDetailController acutionDetailController;
  final AuctionProduct auction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: paddingDefault, vertical: paddingDefault),
      decoration: BoxDecoration(
        border: Border.all(
            color: getTheme(context).primaryColorDark.withOpacity(0.1),
            width: 1),
        color: getTheme(context).primaryColorDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(paddingDefault),
      ),
      child: LayoutBuilder(builder: (context, bound) {
        final (started, ended, duration, endDate) = auction
            .isStartedButNotCompleted(auction.startDate, auction.endDate);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AutoSizeText(
                    started && !ended
                        ? 'Auction ends in'
                        : ended
                            ? 'Auction ended ${endDate ?? ''}'
                            : 'Auction starts in',
                    maxLines: 1,
                    minFontSize: 15,
                    maxFontSize: 20,
                  ),
                ),
              ],
            ),
            if (!ended)
              Column(
                children: [
                  height10(),
                  Row(
                    children: [
                      if (duration != null)
                        SlideCountdown(
                          decoration: BoxDecoration(
                            color: started && !ended
                                ? const Color.fromARGB(255, 251, 1, 1)
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: duration,
                          shouldShowDays: (d) => true,
                          shouldShowHours: (d) => true,
                          shouldShowMinutes: (d) => true,
                          shouldShowSeconds: (d) => true,
                          textStyle: getTheme()
                              .textTheme
                              .titleMedium!
                              .copyWith(color: Colors.white.withOpacity(0.8)),
                          separator: ':',
                          separatorType: SeparatorType.symbol,
                          onChanged: (value) {},
                          onDone: () {
                            acutionDetailController.getAuctionById(auction.id!);
                          },
                        ),
                      /*
                    RichText(
                      text: TextSpan(
                        text: '00',
                        style: getTheme()
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        children: const <TextSpan>[
                          TextSpan(text: 'h:'),
                        ],
                      ),
                    ),
                    width10(),
                    RichText(
                      text: TextSpan(
                        text: '00',
                        style: getTheme()
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        children: const <TextSpan>[
                          TextSpan(text: 'm:'),
                        ],
                      ),
                    ),
                    width10(),
                    RichText(
                      text: TextSpan(
                        text: '00',
                        style: getTheme()
                            .textTheme
                            .titleMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.8)),
                        children: const <TextSpan>[
                          TextSpan(text: 's'),
                        ],
                      ),
                    ),
                   
                   */
                      const Spacer(),

                      ///place a bid button
                      if (started && !ended)
                        SizedBox(
                          width: bound.maxWidth * 0.4,
                          child: AspectRatio(
                            aspectRatio: 4,
                            child: ElevatedButton(
                              onPressed: () {
                                // Get.toNamed(Routes.autionDetail);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  enableDrag: true,
                                  // barrierColor: Colors.white.withOpacity(0.05),
                                  builder: (context) {
                                    return AutionDetailsBidPopupView();
                                  },
                                );
                              },
                              child: const AutoSizeText(
                                'Place a bid',
                                minFontSize: 10,
                                // presetFontSizes: [20, 18, 16, 14, 12, 10],
                                // style: getTheme().textTheme.displayLarge,
                              ),
                            ),
                          ),
                        ),

                      /*
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: paddingDefault,
                              vertical: paddingDefault),
                          decoration: BoxDecoration(
                              color:
                                  getTheme().scaffoldBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Text(
                                '00',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              height5(),
                              const Text(
                                'Days'
                              ),
                            ],
                          ),
                        ),
                        width10(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: paddingDefault,
                              vertical: paddingDefault),
                          decoration: BoxDecoration(
                              color:
                                  getTheme().scaffoldBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Text(
                                '00',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              height5(),
                              const Text(
                                'Hours'
                              ),
                            ],
                          ),
                        ),
                        width10(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: paddingDefault,
                              vertical: paddingDefault),
                          decoration: BoxDecoration(
                              color:
                                  getTheme().scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(10)
                              // border: Border.all(color: Colors.white),
                              ),
                          child: Column(
                            children: [
                              const Text(
                                '00',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              height5(),
                              const Text(
                                'Minutes'
                              ),
                            ],
                          ),
                        ),
                        width10(),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: paddingDefault,
                              vertical: paddingDefault),
                          decoration: BoxDecoration(
                              color:
                                  getTheme().scaffoldBackgroundColor,
                              borderRadius:
                                  BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              const Text(
                                '00',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold),
                              ),
                              height5(),
                              const Text(
                                'Seconds'
                              ),
                            ],
                          ),
                        ),
                     */
                    ],
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}

class _AutionImagesBannerSlider extends StatefulWidget {
  const _AutionImagesBannerSlider(this.acutionDetailController);
  final AuctionDetailController acutionDetailController;

  @override
  State<_AutionImagesBannerSlider> createState() =>
      _AutionImagesBannerSliderState();
}

class _AutionImagesBannerSliderState extends State<_AutionImagesBannerSlider> {
  late CarouselController buttonCarouselController;
  List<String> images = [];

  String? previewPath;

  @override
  void initState() {
    super.initState();
    buttonCarouselController = CarouselController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setStatusBarStyle(context);
    logger.e('didChangeDependencies');
    var product = widget.acutionDetailController.auctionProduct;
    if (product != null && product.image != null && product.image!.isNotEmpty) {
      images.add(product.image!);
    }
    if (product != null && product.images.isNotEmpty) {
      var otherImages = product.images;
      if (otherImages.contains(product.image)) {
        otherImages.remove(product.image);
      }
      images.addAll(otherImages);
    }
    if (images.isNotEmpty) {
      previewPath = widget.acutionDetailController.auctionProduct!.image;
      logger.e('previewPath: $previewPath');
    }
    setState(() {});
    logger.e('didChangeDependencies 2 $images');
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildProductGraphicUI({required String path}) {
    bool is3d = path.endsWith('.glb') || path.endsWith('.gltf');
    if (is3d) {
      return O3D(
        src: path,
        autoPlay: true,
        autoRotate: true,
        withCredentials: false,
        alt: 'A 3D model of an astronaut',
        disableZoom: false,
        cameraControls: true,
        autoRotateDelay: 5,
      );
    }
    return InteractiveViewer(
        child: buildCachedImageWithLoading(path, fit: BoxFit.contain));
  }

  @override
  Widget build(BuildContext context) {
    bool loading = widget.acutionDetailController.loadigAuctionDetail;
    AuctionProduct? auction = widget.acutionDetailController.auctionProduct;
    String? image;
    if (auction != null && auction.images.isNotEmpty) {
      image = auction.images.first;
    }
    return SizedBox(
      height: Get.height * 0.5,
      child: Stack(
        children: [
          SafeArea(
            child: SizedBox(
              height: Get.height * 0.5,
              child: loading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : image != null &&
                          image.isNotEmpty &&
                          previewPath != null &&
                          previewPath.validate().isImage
                      ? buildCachedImageWithLoading(
                          previewPath ?? '',
                          fit: BoxFit.cover,
                          placeholder: MyPng.watchPlaceholder,
                          placeholderAlignment: Alignment.topLeft,
                        )
                      : const SizedBox(),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: paddingDefault),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 25, sigmaY: 25, tileMode: TileMode.mirror),
                child: loading
                    ? const Center(child: CupertinoActivityIndicator())
                    : Builder(builder: (context) {
                        var product =
                            widget.acutionDetailController.auctionProduct!;
                        return Column(
                          children: [
                            ///product image
                            Expanded(
                              child: SafeArea(
                                child: previewPath == null
                                    ? Container()
                                    : Center(
                                        child: _buildProductGraphicUI(
                                            path: previewPath ?? '')),
                              ),
                            ),
                            height10(getHeight(context) * 0.01),

                            ///images list
                            SizedBox(
                              height: getHeight(context) * 0.09,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  if (product.hasModel! &&
                                      product.modelLink!.isNotEmpty) ...[
                                    Builder(builder: (context) {
                                      // var path = 'assets/models/Astronaut.glb';
                                      var path = product.modelLink;
                                      bool isSelected = previewPath == path;
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            previewPath = path;
                                          });
                                        },
                                        child: Container(
                                            height: 50,
                                            width: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white10,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      paddingDefault / 2),
                                              border: Border.all(
                                                  color: isSelected
                                                      ? getTheme(context)
                                                          .primaryColor
                                                      : Colors.grey),
                                            ),
                                            child: Center(
                                              child: AutoSizeText(
                                                '3D',
                                                style: getTheme(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.bold),
                                              ),
                                            )),
                                      );
                                    }),
                                    width10(),
                                  ],
                                  if (images.isNotEmpty)
                                    ...images.mapIndexed((i, e) {
                                      var item = images[i];
                                      bool isSelected = previewPath == item;
                                      return GestureDetector(
                                        onTap: isSelected
                                            ? null
                                            : () async {
                                                setState(
                                                    () => previewPath = null);
                                                0.5.delay(() => setState(
                                                    () => previewPath = item));
                                              },
                                        child: Container(
                                          margin: EdgeInsetsDirectional.only(
                                              end: paddingDefault),
                                          decoration: BoxDecoration(
                                            color: Colors.white10,
                                            borderRadius: BorderRadius.circular(
                                                paddingDefault / 2),
                                            border: Border.all(
                                              color: isSelected
                                                  ? getTheme(context)
                                                      .primaryColor
                                                  : Colors.grey,
                                            ),
                                          ),
                                          child: buildCachedImageWithLoading(
                                            item,
                                            loadingMode:
                                                ImageLoadingMode.shimmer,
                                            w: 50,
                                            h: 50,
                                            fit: BoxFit.cover,
                                            borderRadius: paddingDefault / 2.5,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            )
                          ],
                        );
                      }),

                /*
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, bound) {
                          return Stack(
                            children: [
                              Row(
                                children: [
                                  loading
                                      ? const Center(
                                          child: CircularProgressIndicator
                                              .adaptive())
                                      : image != null && image.isNotEmpty
                                          ? Center(
                                              child:
                                                  buildCachedImageWithLoading(
                                                image,
                                                fit: BoxFit.contain,
                                                borderRadius: 10,
                                                w: bound.maxWidth * 0.6,
                                                placeholder:
                                                    MyPng.watchPlaceholder,
                                              ),
                                            )
                                          : Expanded(
                                              child:
                                                  buildCachedImageWithLoading(
                                                'image',
                                                fit: BoxFit.contain,
                                                borderRadius: 10,
                                                placeholder:
                                                    MyPng.watchPlaceholder,
                                              ),
                                            ),
                                ],
                              ),
                              if (auction != null)
                                Builder(builder: (context) {
                                  return Positioned(
                                    top: kToolbarHeight,
                                    right: 0,
                                    bottom: 0,
                                    width: bound.maxWidth * 0.4,
                                    child: Container(
                                      // color: Colors.teal,
                                      child: ListView(
                                        padding: EdgeInsets.zero,
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.end,
                                        // mainAxisAlignment:
                                        //     MainAxisAlignment.spaceAround,
                                        children: [
                                          displayMedium(
                                            auction.name ?? '',
                                            context,
                                            textAlign: TextAlign.end,
                                            maxLines: 100,
                                            overflow: TextOverflow.ellipsis,
                                          ),

                                          ///some text here like details
                                          // titleLargeText(
                                          //   auction.description ?? '',
                                          //   context,
                                          //   textAlign: TextAlign.end,
                                          // ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            ],
                          );
                        },
                      ),
                    )
                  
                  */
              ),
            ),
          ),
          // height10(),
          // CarouselIndicator(count: child.length, index: _current),
        ],
      ),
    );
  }
}

class _Slider extends StatelessWidget {
  const _Slider(
      {super.key,
      required this.controller,
      required this.child,
      required this.onCarouselChange});
  final CarouselController controller;
  final List<Widget> child;
  final Function(int) onCarouselChange;

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: child,
      carouselController: controller,
      options: CarouselOptions(
        height: Get.height * 0.3,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 2.0,
        initialPage: 2,
        onPageChanged: (index, reason) {
          onCarouselChange(index);
        },
      ),
    );
  }
}

// /// image slider
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key}) : super(key: key);

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   //Generate a list of widgets. You can use another way
//   List<Widget> widgets = List.generate(
//     10,
//     (index) => ClipRRect(
//       borderRadius: const BorderRadius.all(
//         Radius.circular(5.0),
//       ),
//       child: Image.network(
//         'https://source.unsplash.com/random/200x200/?wristwatch,$index', //Images stored in assets folder
//         fit: BoxFit.fill,
//       ),
//     ),
//   );

//   @override
//   Widget build(BuildContext context) {
//     var screenWidth = 600;
//     var screenHeight = 500;
//     return SizedBox(
//       height: min(screenWidth / 3.3 * (16 / 9), screenHeight * .9),
//       child: OverlappedCarousel(
//         widgets: widgets, //List of widgets
//         currentIndex: 2,
//         onClicked: (index) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text("You clicked at $index"),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

class OverlappedCarousel extends StatefulWidget {
  final List<Widget> widgets;
  final Function(int) onClicked;
  final int? currentIndex;

  const OverlappedCarousel(
      {super.key,
      required this.widgets,
      required this.onClicked,
      this.currentIndex});

  @override
  _OverlappedCarouselState createState() => _OverlappedCarouselState();
}

class _OverlappedCarouselState extends State<OverlappedCarousel> {
  double currentIndex = 2;

  @override
  void initState() {
    if (widget.currentIndex != null) {
      currentIndex = widget.currentIndex!.toDouble();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                var indx = currentIndex - details.delta.dx * 0.02;
                if (indx >= 1 && indx <= widget.widgets.length - 3) {
                  currentIndex = indx;
                }
              });
            },
            onPanEnd: (details) {
              setState(() {
                currentIndex = currentIndex.ceil().toDouble();
              });
            },
            child: OverlappedCarouselCardItems(
              cards: List.generate(
                widget.widgets.length,
                (index) => CardModel(id: index, child: widget.widgets[index]),
              ),
              centerIndex: currentIndex,
              maxWidth: constraints.maxWidth,
              maxHeight: constraints.maxHeight,
              onClicked: widget.onClicked,
            ),
          );
        },
      ),
    );
  }
}

class OverlappedCarouselCardItems extends StatelessWidget {
  final List<CardModel> cards;
  final Function(int) onClicked;
  final double centerIndex;
  final double maxHeight;
  final double maxWidth;

  const OverlappedCarouselCardItems({
    super.key,
    required this.cards,
    required this.centerIndex,
    required this.maxHeight,
    required this.maxWidth,
    required this.onClicked,
  });

  double getCardPosition(int index) {
    final double center = maxWidth / 2;
    final double centerWidgetWidth = maxWidth / 4;
    final double basePosition = center - centerWidgetWidth / 2 - 12;
    final distance = centerIndex - index;

    final double nearWidgetWidth = centerWidgetWidth / 5 * 4;
    final double farWidgetWidth = centerWidgetWidth / 5 * 3;

    if (distance == 0) {
      return basePosition;
    } else if (distance.abs() > 0.0 && distance.abs() <= 1.0) {
      if (distance > 0) {
        return basePosition - nearWidgetWidth * distance.abs();
      } else {
        return basePosition + centerWidgetWidth * distance.abs();
      }
    } else if (distance.abs() >= 1.0 && distance.abs() <= 2.0) {
      if (distance > 0) {
        return (basePosition - nearWidgetWidth) -
            farWidgetWidth * (distance.abs() - 1);
      } else {
        return (basePosition + centerWidgetWidth + nearWidgetWidth) +
            farWidgetWidth * (distance.abs() - 2) -
            (nearWidgetWidth - farWidgetWidth) *
                ((distance - distance.floor()));
      }
    } else {
      if (distance > 0) {
        return (basePosition - nearWidgetWidth) -
            farWidgetWidth * (distance.abs() - 1);
      } else {
        return (basePosition + centerWidgetWidth + nearWidgetWidth) +
            farWidgetWidth * (distance.abs() - 2);
      }
    }
  }

  double getCardWidth(int index) {
    final double distance = (centerIndex - index).abs();
    final double centerWidgetWidth = maxWidth / 2;
    final double nearWidgetWidth = centerWidgetWidth / 5 * 4.5;
    final double farWidgetWidth = centerWidgetWidth / 5 * 3.5;

    if (distance >= 0.0 && distance < 1.0) {
      return centerWidgetWidth -
          (centerWidgetWidth - nearWidgetWidth) * (distance - distance.floor());
    } else if (distance >= 1.0 && distance < 2.0) {
      return nearWidgetWidth -
          (nearWidgetWidth - farWidgetWidth) * (distance - distance.floor());
    } else {
      return farWidgetWidth;
    }
  }

  Matrix4 getTransform(int index) {
    final distance = centerIndex - index;

    var transform = Matrix4.identity()
      ..setEntry(3, 2, 0.007)
      ..rotateY(-0.25 * distance)
      ..scale(1.25, 1.25, 1.25);
    if (index == centerIndex) transform.scale(1.05, 1.05, 1.05);
    return transform;
  }

  Widget _buildItem(CardModel item) {
    final int index = item.id;
    final width = getCardWidth(index);
    final height = maxHeight - 20 * (centerIndex - index).abs();
    final position = getCardPosition(index);
    final verticalPadding = width * 0.05 * (centerIndex - index).abs();

    return Positioned(
      left: position,
      child: Transform(
        transform: getTransform(index),
        alignment: FractionalOffset.center,
        child: Container(
          width: width.toDouble(),
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          height: height > 0 ? height : 0,
          child: item.child,
        ),
      ),
    );
  }

  List<Widget> _sortedStackWidgets(List<CardModel> widgets) {
    for (int i = 0; i < widgets.length; i++) {
      if (widgets[i].id == centerIndex) {
        widgets[i].zIndex = widgets.length.toDouble();
      } else if (widgets[i].id < centerIndex) {
        widgets[i].zIndex = widgets[i].id.toDouble();
      } else {
        widgets[i].zIndex =
            widgets.length.toDouble() - widgets[i].id.toDouble();
      }
    }
    widgets.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return widgets.map((e) {
      double distance = (centerIndex - e.id).abs();
      if (distance >= 0 && distance <= 3) {
        return _buildItem(e);
      } else {
        return Container();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        alignment: AlignmentDirectional.center,
        clipBehavior: Clip.none,
        children: _sortedStackWidgets(cards),
      ),
    );
  }
}

class CardModel {
  final int id;
  double zIndex;
  final Widget? child;

  CardModel({required this.id, this.zIndex = 0.0, this.child});
}

/*
class HtmlPreviewPage extends StatefulWidget {
  const HtmlPreviewPage(
      {Key? key,
      required this.title,
      required this.message,
      required this.file_url})
      : super(key: key);

  final String title;
  final String message;
  final String file_url;

  @override
  HtmlPreviewPageState createState() => HtmlPreviewPageState();
}

final staticAnchorKey = GlobalKey();
String _parseHtmlString(String htmlString) {
  // var text = html.Element.span()..appendHtml(htmlString);
  var document = parse(htmlString
//       '''
// <body>
//   <h2>Header 1</h2>
//   <p>Text.</p>
//   <h2>Header 2</h2>
//   More text.
//   <br/>
// </body>'''
      );

  // outerHtml output
  print('outer html:');
  print(document.outerHtml);

  print('');

  // visitor output
  print('html visitor:');
  // _Visitor().visit(document);
  return document.outerHtml;
}

String removeTableTags(String htmlString) {
  RegExp tableRegExp = RegExp(r'<\/?table[^>]*>', multiLine: true);
  return htmlString.replaceAll(tableRegExp, '');
}

class HtmlPreviewPageState extends State<HtmlPreviewPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
    //     overlays: [SystemUiOverlay.bottom]);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.message);
    return Scaffold(
      // backgroundColor: Color(0xFF082E8F),
      backgroundColor: const Color(0xFFEBEEF6),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25))),
        title: bodyMedText(widget.title, context,
            color: Colors.white, useGradient: true),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 10),
              child: Html(
                data: removeTableTags(widget.message),
                extensions: [
                  TagExtension(
                      tagsToExtend: {"flutter"}, child: const FlutterLogo()),
                ],
                style: {
                  "p.fancy": Style(
                      textAlign: TextAlign.center,
                      padding: HtmlPaddings.all(10),
                      backgroundColor: Colors.grey,
                      margin: Margins(
                          left: Margin(50, Unit.px), right: Margin.auto()),
                      width: Width(300, Unit.px),
                      fontWeight: FontWeight.bold),
                  "table": Style(
                    backgroundColor:
                        const Color.fromARGB(0x50, 0xe5, 0x15, 0x15),
                  ),
                  "tr": Style(
                    border:
                        const Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  "th": Style(
                      padding: HtmlPaddings.all(6),
                      backgroundColor: Colors.grey),
                  "td": Style(
                      padding: HtmlPaddings.all(6),
                      alignment: Alignment.topLeft),
                  'h2': Style(
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      color: Colors.pink),
                  'h5': Style(
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                      color: Colors.pink),
                },
                onLinkTap: (str, map, ele) async {
                  print('link ${str},\n${map}, \n${ele}');
                  await launchTheLink(str ?? '');
                },
                onAnchorTap: (str, map, ele) async {
                  print('${str},\n${map}, \n${ele}');
                  await launchTheLink(str ?? '');
                },
                onCssParseError: (err, list) {
                  print('css err ${err}  ${list.map((e) => e.message)}');
                },
              ),
            ),
          ),
          if (widget.file_url != '')
            Container(
              // margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10), color: Colors.white),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.link,
                      size: 13, color: Colors.black, weight: 2),
                  Expanded(
                      child: bodyLargeText('Attachment (1)', context,
                          color: Colors.black)),
                  TextButton(
                      onPressed: () => launchTheLink(widget.file_url),
                      child: bodyLargeText('View', context,
                          color: CupertinoColors.link))
                ],
              ),
            )
        ],
      ),
    );
  }
}

*/