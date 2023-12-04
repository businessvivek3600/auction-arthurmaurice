import 'package:action_tds/components/component_index.dart';
import 'package:action_tds/components/hero_tag_wdget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '/app/models/auction_app/auction_model.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:slide_countdown/slide_countdown.dart';

import '../app/routes/app_pages.dart';
import '../constants/constants_index.dart';

class AuctionProductCard extends StatelessWidget {
  const AuctionProductCard(
      {super.key,
      required this.index,
      required this.height,
      this.loading = true,
      this.product});
  final int index;
  final int height;
  final bool loading;
  final AuctionProduct? product;

  @override
  Widget build(BuildContext context) {
    String amount =
        formatMoney((product?.price ?? '0.0').getDouble()).output.symbolOnLeft;
    return LayoutBuilder(builder: (context, bound) {
      String? image = product?.image.validate();
      return GestureDetector(
        onTap: loading
            ? null
            : () {
                if (product != null) {
                  context.push('${Routes.auctionDetail}/${product!.id}');
                }
              },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(paddingDefault),
          child: Container(
            height: height.toDouble(),
            decoration: BoxDecoration(
              border: Border.all(
                  color: getTheme(context).primaryColorDark.withOpacity(0.1),
                  width: 1),
              color: getTheme(context).primaryColorDark.withOpacity(0.3),
              borderRadius: BorderRadius.circular(paddingDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ///image
                Expanded(
                  child: buildCachedImageWithLoading(
                    image ?? '',
                    // w: bound.maxWidth.toDouble(),
                    h: height.toDouble(),
                    fit: BoxFit.fitWidth,
                    placeholder: MyPng.watchPlaceholder,
                    loadingMode: ImageLoadingMode.shimmer,
                    borderRadius: 0,
                  ),
                ),
                _details(bound, context, amount),

                // ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Container _details(
      BoxConstraints bound, BuildContext context, String amount) {
    return Container(
      width: bound.maxWidth.toDouble(),
      color: getTheme(context).primaryColorDark.withOpacity(1),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///icon
          AutoSizeText(
            amount,
            style:
                getTheme().textTheme.bodySmall!.copyWith(color: Colors.white),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///avg rating
              Row(
                children: [
                  Icon(Icons.star,
                      color: Colors.amber,
                      size: getTheme().textTheme.bodyLarge?.fontSize),
                  width5(),
                  AutoSizeText(
                    (product?.avgRating ?? 0.0).toStringAsFixed(1),
                    style: getTheme()
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),

              ///bid count
              Row(
                children: [
                  faIcon(FontAwesomeIcons.gavel,
                      size: getTheme().textTheme.bodyLarge?.fontSize ?? 16),
                  width5(),
                  AutoSizeText(
                    (product?.totalBids ?? 0).toString(),
                    style: getTheme()
                        .textTheme
                        .bodySmall!
                        .copyWith(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),

          ///time left
          if (product != null) _BuildTimerWidget(auction: product!),
        ],
      ),
    );
  }
}

class _BuildTimerWidget extends StatelessWidget {
  const _BuildTimerWidget({
    required this.auction,
  });
  final AuctionProduct auction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
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
              ? _timer(color, duration, started && !ended)
              : AutoSizeText('Auction ended $endDate',
                  style:
                      getTheme().textTheme.bodySmall!.copyWith(color: color));
    });
  }

  Widget _timer(Color color, Duration duration, bool isLive) {
    return Padding(
      padding: EdgeInsets.only(top: paddingDefault * 0.2),
      child: SlideCountdown(
        decoration: BoxDecoration(
          color: isLive
              ? const Color.fromARGB(255, 251, 1, 1)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(paddingDefault * 0.5),
          // border: Border.all(color: Colors.white70, width: 2),
        ),
        style: getTheme().textTheme.bodySmall!.copyWith(color: Colors.white),
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
      ),
    );
  }
}
