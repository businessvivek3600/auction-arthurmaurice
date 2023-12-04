// ignore_for_file: must_be_immutable

import 'dart:math';

import 'package:action_tds/components/component_index.dart';

import '/app/models/auction_app/home_banner_model.dart';
import '/app/modules/bottomNav/home/controllers/home_controller.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:slide_countdown/slide_countdown.dart';
import '../../../../../constants/constants_index.dart';

import '../../../../routes/app_pages.dart';

class HomeBannerSlider extends StatelessWidget {
  final CarouselController buttonCarouselController = CarouselController();

  HomeBannerSlider({super.key});
  List<int> colors = List.generate(
      5,
      (index) =>
          int.parse('0xFF${Random().nextInt(0x1000000).toRadixString(16)}'));

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      List<Widget> items = getItems(homeCtrl);
      if (items.isEmpty) {
        return Container();
      }
      return CarouselSlider(
        items: items,
        carouselController: buttonCarouselController,
        options: CarouselOptions(
          autoPlay: true,
          // enlargeCenterPage: true,
          viewportFraction: 1,
          aspectRatio: 2.5,
          initialPage: 2,
        ),
      );
    });
  }

  List<Widget> getItems(HomeController ctr) {
    List<Widget> items = [];
    bool loading = ctr.loadingDashboard;
    (loading ? List.generate(5, (index) => HomeBanner()) : ctr.homeBanners)
        .where((element) => element.type != BannerType.none)
        .forEach((banner) {
      switch (banner.type) {
        case BannerType.product:
          items.add(_HomeBannerProductItem(banner, loading: loading));
          break;
        case BannerType.category:
          items.add(_HomeBannerCategoryItem(banner, loading: loading));
          break;
        case BannerType.offer:
          items.add(_HomeBannerProductItem(banner, loading: loading));
          break;
        case BannerType.notice:
          items.add(_HomeBannerNoticeItem(banner, loading: loading));
          break;
        default:
          items.add(_HomeBannerProductItem(banner, loading: true));
      }
    });

    return items;
  }
}

class _HomeBannerNoticeItem extends StatelessWidget {
  const _HomeBannerNoticeItem(this.banner, {super.key, this.loading = false});
  final HomeBanner? banner;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    String? image = banner?.image;
    String? text = banner?.text;

    return GestureDetector(
      onTap: loading
          ? null
          : () {
              launchThUrl(banner?.action);
            },
      child: DefaultRefreshEffect(
        loading: loading,
        child: LayoutBuilder(
          builder: (context, bound) {
            return Stack(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(0))),

                ///content here
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          // image: image != null && image.isNotEmpty
                          //     ? DecorationImage(
                          //         image: NetworkImage(image), fit: BoxFit.cover)
                          //     : null,
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            buildCachedImageWithLoading(
                              image ?? '',
                              w: bound.maxWidth.toDouble(),
                              fit: BoxFit.cover,
                            ),
                            Positioned(
                              top: paddingDefault,
                              left: paddingDefault,
                              right: paddingDefault,
                              bottom: paddingDefault,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // bodyMedText('Title'),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: bound.maxWidth * 0.5),
                                    child: Wrap(
                                      children: [
                                        AutoSizeText(
                                          text ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: getTheme(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                height: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeBannerCategoryItem extends StatelessWidget {
  const _HomeBannerCategoryItem(this.banner, {super.key, this.loading = false});
  final HomeBanner? banner;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    var category = banner?.category;
    String? image = category?.icon;
    String? text = banner?.text;
    return GestureDetector(
      onTap: loading
          ? null
          : () {
              context.push('${Routes.category}/${category?.id ?? '0'}');
            },
      child: DefaultRefreshEffect(
        loading: loading,
        child: LayoutBuilder(
          builder: (context, bound) {
            return Stack(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10))),

                ///content here
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(paddingDefault),
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(paddingDefault),
                        decoration: const BoxDecoration(color: Colors.white30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // bodyMedText('Title'),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: bound.maxWidth * 0.5),
                                    child: Wrap(
                                      children: [
                                        AutoSizeText(
                                          text ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: getTheme(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                height: 1.1,
                                              ),
                                        ),

                                        ///name
                                        AutoSizeText(
                                          category?.name ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.fade,
                                          style: getTheme(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                height: 1.1,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ],
                        )),
                  ),
                ),

                ///add image here
                if (image != null && image.isNotEmpty)
                  Positioned(
                    bottom: bound.maxHeight * 0.2,
                    top: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: bound.maxWidth * 0.4,
                        constraints:
                            BoxConstraints(maxWidth: bound.maxWidth * 0.4),
                        child: buildCachedImageWithLoading(
                          category?.icon ?? '',
                          w: bound.maxWidth.toDouble(),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HomeBannerProductItem extends StatelessWidget {
  const _HomeBannerProductItem(this.banner, {Key? key, this.loading = false})
      : super(key: key);
  final HomeBanner? banner;
  final bool loading;
  @override
  Widget build(BuildContext context) {
    var product = banner?.product;
    String? image = product?.images?.first;
    String? text = banner?.text;
    Color? bgColor = getColor(banner?.bgColor);
    var (started, ended, duration, endDate) = (false, false, null, null);
    Color color = Colors.white.withOpacity(0.8);
    if (!loading && product != null) {
      (started, ended, duration, endDate) =
          product.isStartedButNotCompleted(product.startDate, product.endDate);
      color = started && !ended
          ? Colors.redAccent
          : !started && !ended
              ? Colors.black.withOpacity(0.8)
              : Colors.white.withOpacity(0.8);
    }
    return DefaultRefreshEffect(
      loading: loading,
      child: LayoutBuilder(
        builder: (context, bound) {
          return Stack(
            children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  decoration:
                      BoxDecoration(borderRadius: BorderRadius.circular(0))),

              ///content here
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(paddingDefault),
                      decoration:
                          BoxDecoration(color: bgColor ?? Colors.white30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // bodyMedText('Title'),
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth: bound.maxWidth * 0.5),
                                    child: AutoSizeText(
                                      text ?? '',
                                      maxLines: 10,
                                      overflow: TextOverflow.fade,
                                      style: getTheme(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            height: 1.1,
                                          ),
                                    ),
                                  ),
                                ),
                                if (product != null)
                                  Builder(builder: (context) {
                                    return duration != null
                                        ? _timer(color, duration)
                                        : AutoSizeText(
                                            'Auction ended $endDate',
                                            style: getTheme(context)
                                                .textTheme
                                                .bodySmall!
                                                .copyWith(color: color),
                                          );
                                  }),
                              ],
                            ),
                          ),
                          height5(),
                          if (!loading && started && !ended)
                            SizedBox(
                              height: bound.maxHeight * 0.2,
                              child: AspectRatio(
                                aspectRatio: 4,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Get.toNamed(Routes.auctionDetail);
                                    context.push(
                                        '${Routes.auctionDetail}/${product?.id ?? '0'}');
                                  },
                                  child: AutoSizeText('Place a bid',
                                      minFontSize: 10,
                                      // presetFontSizes: [20, 18, 16, 14, 12, 10],
                                      style: getTheme(context)
                                          .textTheme
                                          .displayLarge
                                          ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                ),
                              ),
                            )
                        ],
                      )),
                ),
              ),

              ///add image here
              if (image != null && image.isNotEmpty)
                Positioned(
                  // bottom: bound.maxHeight * 0.2,
                  bottom: 0,
                  top: 0,
                  right: 0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: bound.maxWidth * 0.4,
                      constraints:
                          BoxConstraints(maxWidth: bound.maxWidth * 0.4),
                      child: buildCachedImageWithLoading(
                        product?.images.first ?? '',
                        w: bound.maxWidth.toDouble(),
                        placeholder: MyPng.watchPlaceholder,
                        borderRadius: 10,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  SlideCountdown _timer(Color color, Duration duration) {
    return SlideCountdown(
      decoration: BoxDecoration(
        color: getTheme().textTheme.displayLarge?.color?.withOpacity(1),
        borderRadius: BorderRadius.circular(paddingDefault / 2),
        // border: Border.all(color: Colors.white70, width: 2),
      ),
      style: getTheme().textTheme.bodySmall!.copyWith(color: color),
      separatorStyle: getTheme()
          .textTheme
          .bodySmall!
          .copyWith(color: color.withOpacity(0.8)),
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
      onChanged: (value) {
        // print(value);
      },
      onDone: () {},
    );
  }
}
