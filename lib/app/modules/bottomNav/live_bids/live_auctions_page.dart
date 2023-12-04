import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';

import '/components/home_page_refresh_effect.dart';

import '../../../../constants/constants_index.dart';
import '../home/controllers/home_controller.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import '/../utils/utils_index.dart';

import '/components/component_index.dart';

class LiveAuctionsPage extends StatefulWidget {
  LiveAuctionsPage({
    super.key,
    required this.onScreenHideButtonPressed,
    required this.hideNavBar,
    required this.menuScreenContext,
  });
  final BuildContext menuScreenContext;
  final bool hideNavBar;
  final Function(bool) onScreenHideButtonPressed;

  @override
  State<LiveAuctionsPage> createState() => _LiveAuctionsPageState();
}

class _LiveAuctionsPageState extends State<LiveAuctionsPage> {
  var controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();
    controller.setLiveBidsScrollController(ScrollController());
    controller.setUpcomingBidsScrollController(ScrollController());
    controller.setClosedBidsScrollController(ScrollController());
    afterBuildCreated(() async {
      controller.getAuctionProductsByType(
          productType: ProductType.live, page: 1, loading: false);
    });
  }

  @override
  void dispose() {
    controller.disposeLiveBidsScrollController();
    controller.disposeUpcomingBidsScrollController();
    controller.disposeClosedBidsScrollController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      // initState: (_) {
      //   controller.setLiveBidsScrollController(ScrollController());
      //   controller.setUpcomingBidsScrollController(ScrollController());
      //   controller.setClosedBidsScrollController(ScrollController());
      //   controller.getAuctionProductsByType(
      //       productType: ProductType.live, page: 1, loading: false);
      // },
      // dispose: (_) {
      //   HomeController.to.disposeLiveBidsScrollController();
      //   HomeController.to.disposeUpcomingBidsScrollController();
      //   HomeController.to.disposeClosedBidsScrollController();
      // },
      builder: (homeCtrl) {
        return Scaffold(
          appBar: AppBar(
            title: displayLarge('Live Auctions', context),
            centerTitle: false,
            backgroundColor: Colors.transparent,
            systemOverlayStyle: getTransaparentAppBarStatusBarStyle(context),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(getHeight(context) * 0.05),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildChips(context, homeCtrl),
              ),
            ),
          ),
          body: _body(context, homeCtrl),
          // floatingActionButton: _floatingTab(homeCtrl),
        );
      },
    );
  }

  Widget _body(BuildContext context, HomeController ctr) {
    return Column(
      children: [
        // _buildChips(context, colorCode, ctr),

        ///indexedstack
        _stackedContainers(ctr),
        // _stacked
      ],
    );
  }

  Container _buildChips(BuildContext context, HomeController ctr) {
    return Container(
      height: getHeight(context) * 0.05,
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 0),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        children: [
          width10(paddingDefault),
          _BidTypeChip(
            label: AutoSizeText(
              'Live',
              maxLines: 1,
              minFontSize: 1,
              style: getTheme(context).textTheme.bodyLarge,
            ),
            selected: ctr.selectedBidType == 0,
            selectedColor:
                getTheme(context).secondaryHeaderColor.withOpacity(0.2),
            // side: BorderSide(color: colorCode),
            onTap: () => ctr.setSelectedBidType(0),
          ),
          width10(),
          _BidTypeChip(
            label: AutoSizeText(
              'Upcoming',
              maxLines: 1,
              minFontSize: 1,
              style: getTheme(context).textTheme.bodyLarge,
            ),
            selected: ctr.selectedBidType == 1,
            selectedColor:
                getTheme(context).secondaryHeaderColor.withOpacity(0.2),
            onTap: () => ctr.setSelectedBidType(1),
            // side: BorderSide(color: colorCode),
          ),
          width10(),
          _BidTypeChip(
            label: AutoSizeText(
              'Closed',
              maxLines: 1,
              minFontSize: 1,
              style: getTheme(context).textTheme.bodyLarge,
            ),
            selected: ctr.selectedBidType == 2,
            selectedColor:
                getTheme(context).secondaryHeaderColor.withOpacity(0.2),
            onTap: () => ctr.setSelectedBidType(2),
            // side: BorderSide(color: colorCode),
          ),
        ],
      ),
    );
  }

  Widget _stackedContainers(HomeController ctr) {
    return Expanded(
      child: IndexedStack(
        index: ctr.selectedBidType,
        children: <Widget>[
          _LiveAuctions(
              onScreenHideButtonPressed: widget.onScreenHideButtonPressed),
          const _UpcomingAuctions(),
          const _ClosedAuctions(),
        ],
      ),
    );
  }
}

class _ClosedAuctions extends StatelessWidget {
  const _ClosedAuctions({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(initState: (_) {
      // HomeController.to.setClosedBidsScrollController(ScrollController());
    }, dispose: (_) {
      // HomeController.to.disposeClosedBidsScrollController();
    }, builder: (ctr) {
      bool loading = ctr.loadingActionProductsByType == 2;
      return LoadMoreContainer(
          finishWhen: ctr.closedAuctionProductsByType.length >=
              ctr.totalClosedAuctionProducts,
          onLoadMore: () async {
            await HomeController.to.getAuctionProductsByType(
                productType: ProductType.closed,
                page:
                    HomeController.to.productTypePage[ProductType.closed]! + 1,
                loading: false);
          },
          onRefresh: () async {
            await HomeController.to.getAuctionProductsByType(
                productType: ProductType.closed, page: 1);
          },
          builder: (scroll, status) {
            int total = loading ? 15 : ctr.closedAuctionProductsByType.length;
            if ((!loading && ctr.closedAuctionProductsByType.isEmpty)) {
              return _emptyAuctionHistory(
                  scroll, context, 'No Closed Auctions');
            }
            return DefaultRefreshEffect(
              loading: loading,
              child: MasonryGridView.count(
                controller: ctr.closedBidsScrollController,
                padding: EdgeInsets.all(paddingDefault),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: total + 2,
                itemBuilder: (context, index) {
                  bool isLast = index == total || index == total + 1;
                  final height = isLast
                      ? kBottomNavigationBarHeight.toInt()
                      : (10 - (index % 3)) * 30;

                  return !isLast
                      ? AuctionProductCard(
                          height: height,
                          index: index,
                          loading: loading,
                          product: loading
                              ? null
                              : ctr.closedAuctionProductsByType[index],
                        )
                      : Container(height: height.toDouble());
                },
              ),
            );
          });
    });
  }
}

class _UpcomingAuctions extends StatelessWidget {
  const _UpcomingAuctions({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(initState: (_) {
      // HomeController.to.setUpcomingBidsScrollController(ScrollController());
    }, dispose: (_) {
      // HomeController.to.disposeUpcomingBidsScrollController();
    }, builder: (ctr) {
      bool loading = ctr.loadingActionProductsByType == 1;
      return LoadMoreContainer(
          finishWhen: ctr.upcomingAuctionProductsByType.length >=
              ctr.totalUpcomingAuctionProducts,
          onLoadMore: () async {
            await HomeController.to.getAuctionProductsByType(
                productType: ProductType.upcoming,
                page: HomeController.to.productTypePage[ProductType.upcoming]! +
                    1,
                loading: false);
          },
          onRefresh: () async {
            await HomeController.to.getAuctionProductsByType(
                productType: ProductType.upcoming, page: 1);
          },
          builder: (scroll, status) {
            int total = loading ? 15 : ctr.upcomingAuctionProductsByType.length;
            if ((!loading && ctr.upcomingAuctionProductsByType.isEmpty)) {
              return _emptyAuctionHistory(
                  scroll, context, 'No Upcoming Auctions');
            }
            return DefaultRefreshEffect(
              loading: loading,
              child: MasonryGridView.count(
                controller: ctr.upcomingBidsScrollController,
                padding: EdgeInsets.all(paddingDefault),
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                itemCount: total + 2,
                itemBuilder: (context, index) {
                  bool isLast = index == total || index == total + 1;
                  final height = isLast
                      ? kBottomNavigationBarHeight.toInt()
                      : (10 - (index % 3)) * 30;

                  return !isLast
                      ? AuctionProductCard(
                          height: height,
                          index: index,
                          loading: loading,
                          product: loading
                              ? null
                              : ctr.upcomingAuctionProductsByType[index],
                        )
                      : Container(height: height.toDouble());
                },
              ),
            );
          });
    });
  }
}

class _LiveAuctions extends StatelessWidget {
  const _LiveAuctions({super.key, required this.onScreenHideButtonPressed});
  final Function(bool) onScreenHideButtonPressed;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        // HomeController.to.setLiveBidsScrollController(ScrollController());
      },
      // dispose: (_) {
      //   HomeController.to.disposeLiveBidsScrollController();
      // },
      builder: (ctr) {
        bool loading = ctr.loadingActionProductsByType == 0;
        return LoadMoreContainer(
            finishWhen: ctr.liveAuctionProductsByType.length >=
                ctr.totalLiveAuctionProducts,
            onLoadMore: () async {
              await HomeController.to.getAuctionProductsByType(
                  productType: ProductType.live,
                  page:
                      HomeController.to.productTypePage[ProductType.live]! + 1,
                  loading: false);
            },
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
              await HomeController.to.getAuctionProductsByType(
                  productType: ProductType.live, page: 1);
            },
            builder: (scroll, status) {
              int total = loading ? 15 : ctr.liveAuctionProductsByType.length;
              if ((!loading && ctr.liveAuctionProductsByType.isEmpty)) {
                return _emptyAuctionHistory(
                    scroll, context, 'No Live Auctions');
              }
              return DefaultRefreshEffect(
                loading: loading,
                child: MasonryGridView.count(
                  controller: ctr.liveBidsScrollController,
                  padding: EdgeInsets.all(paddingDefault),
                  physics: const AlwaysScrollableScrollPhysics(),
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: total + 2,
                  itemBuilder: (context, index) {
                    bool isLast = index == total || index == total + 1;
                    final height = isLast
                        ? kBottomNavigationBarHeight.toInt()
                        : (10 - (index % 3)) * 30;

                    return !isLast
                        ? AuctionProductCard(
                            height: height,
                            index: index,
                            loading: loading,
                            product: loading
                                ? null
                                : ctr.liveAuctionProductsByType[index],
                          )
                        : Container(height: height.toDouble());
                  },
                ),
              );
            });
      },
    );
  }
}

class _BidTypeChip extends StatelessWidget {
  const _BidTypeChip({
    super.key,
    required this.label,
    this.selectedColor,
    this.side,
    this.height = 40,
    this.selected = false,
    this.onTap,
  });
  final Widget label;
  final Color? selectedColor;
  final BorderSide? side;
  final double height;
  final bool selected;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!() : null,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: selected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.fromBorderSide(side ?? BorderSide.none),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Center(child: label),
        ),
      ),
    );
  }
}

SingleChildScrollView _emptyAuctionHistory(
    ScrollController scroll, BuildContext context, String desc) {
  return SingleChildScrollView(
    controller: scroll,
    child: SizedBox(
      height: Get.height,
      child: Column(
        children: [
          height10(getHeight() * 0.1),
          assetLottie(MyLottie.auction),
          height10(spaceDefault * 3),
          Center(
              child: AutoSizeText(
            desc,
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
