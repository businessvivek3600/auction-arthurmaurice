import 'dart:io';

import 'package:action_tds/app/models/auction_app/auction_model_index.dart';
import 'package:action_tds/app/modules/bottomNav/bid_history/controllers/bidController.dart';
import 'package:action_tds/app/modules/bottomNav/home/controllers/home_controller.dart';
import 'package:action_tds/components/home_page_refresh_effect.dart';
import 'package:action_tds/constants/asset_constants.dart';
import 'package:action_tds/database/database_index.dart';
import 'package:action_tds/services/share.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:popover/popover.dart';
import '../../../routes/app_pages.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/providers/user_provider.dart';
import '../../auth/user_model.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import '/components/component_index.dart';

class AccountView extends StatelessWidget {
  AccountView({Key? key}) : super(key: key);
  var controller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: controller,
        initState: (state) {
          _calculateProfileProgres(controller, context);
        },
        didChangeDependencies: (state) {},
        builder: (homeCtrl) {
          return GetBuilder<AuthController>(
              init: AuthController(),
              initState: (_) {},
              builder: (authCtrl) {
                var user = authCtrl.getUser<AuctionUser>();
                return Scaffold(
                  body: globalContainer(
                    child: Column(
                      children: [
                        ///appbar
                        _Appbar(context, authController: authCtrl),

                        /// body
                        Expanded(
                          child: LayoutBuilder(builder: (context, bound) {
                            return ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                height20(),

                                ///profile image
                                _ProfileImage(
                                    homeCtrl: homeCtrl,
                                    bound: bound,
                                    authCtrl: authCtrl),

                                ///name
                                height20(),
                                Center(
                                    child: titleLargeText(
                                        user?.fullName ?? '', context)),

                                ///bids info
                                _BidInfo(authCtrl: authCtrl, bound: bound),

                                ///Activites
                                _buildUserBalanceHistory(context, authCtrl),

                                ///user info
                                _UserInfo(authCtrl: authCtrl, bound: bound),

                                ///bid history
                                _BidHistory(
                                  homeCtrl: homeCtrl,
                                  authCtrl: authCtrl,
                                  bound: bound,
                                ),

                                ///height
                                height20(100),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                );
              });
        });
  }

  Column _buildUserBalanceHistory(
      BuildContext context, AuthController authCtrl) {
    double? balance = authCtrl.getUser<AuctionUser>()?.totalBalance;
    double? deposit = authCtrl.getUser<AuctionUser>()?.totalDeposit;
    double? bidAmount = authCtrl.getUser<AuctionUser>()?.totalBidAmount;
    int? transactions = authCtrl.getUser<AuctionUser>()?.totalTransactions;
    int? bids = authCtrl.getUser<AuctionUser>()?.bidCount;

    return Column(
      children: [
        height20(),
        Card(
          elevation: 1,
          shadowColor: Colors.black.withOpacity(0.0),
          color: getTheme(context).primaryColorDark.withOpacity(0.05),
          margin: EdgeInsetsDirectional.symmetric(horizontal: paddingDefault),
          child: Padding(
            padding: EdgeInsets.all(paddingDefault),
            child: Column(
              children: [
                Row(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AutoSizeText(
                          'Balance',
                          style: TextStyle(
                            color: getTheme(context)
                                .textTheme
                                .displaySmall
                                ?.color
                                ?.withOpacity(0.5),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        width5(),
                        GestureDetector(
                          onTap: () => showCupertinoModalPopup(
                              context: context,
                              builder: (_) => CustomBottomsheet(
                                  topMargin: getHeight(context) * 0.7,
                                  builder: (bound) =>
                                      _balanceDescription(context, bound))),
                          child: faIcon(FontAwesomeIcons.circleInfo,
                              color: getTheme(context)
                                  .textTheme
                                  .displaySmall!
                                  .color!
                                  .withOpacity(0.5)),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AutoSizeText(
                        formatMoney(balance.validate()).output.symbolOnLeft,
                        style: TextStyle(
                          color: getTheme(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withOpacity(0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                /// boxs for total deposit, transaction, total bids, total bid amount
                height20(paddingDefault),
                SizedBox(
                  height: getHeight() * 0.2,
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: [
                      _ActivityBox(
                        title: 'Total Deposit',
                        value: deposit.validate(),
                        color: Colors.green,
                        icon: MyPng.deposit,
                      ),
                      _ActivityBox(
                        title: 'Total Transaction',
                        value: transactions.validate(),
                        color: Colors.blue,
                        icon: MyPng.transaction,
                      ),
                      _ActivityBox(
                        title: 'Total Bids',
                        value: bids.validate(),
                        color: Colors.red,
                        icon: MyPng.bid,
                      ),
                      _ActivityBox(
                        title: 'Total Bid Amount',
                        value: bidAmount.validate(),
                        color: Colors.orange,
                        icon: MyPng.bidAmount,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _calculateProfileProgres(
      HomeController controller, BuildContext context) async {
    controller.profileProgressValue.value = 0;
    await Future.delayed(const Duration(milliseconds: 5000), () {
      controller.profileProgressValue.value += 20;
    });
    await Future.delayed(const Duration(milliseconds: 5000), () {
      controller.profileProgressValue.value += 20;
    });
    await Future.delayed(const Duration(milliseconds: 5500), () {
      controller.profileProgressValue.value += 20;
    });
    await Future.delayed(const Duration(milliseconds: 5000), () {
      controller.profileProgressValue.value += 20;
    });
    await Future.delayed(const Duration(milliseconds: 5500), () {
      controller.profileProgressValue.value += 10;
    });
  }

  Widget _balanceDescription(BuildContext context, BoxConstraints bound) {
    return Container(
      padding: EdgeInsets.all(paddingDefault),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            formatMoney(234567567).output.symbolOnLeft,
            maxLines: 1,
            minFontSize: 20,
            maxFontSize: 30,
            style: TextStyle(
              color: getTheme(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          height10(),
          AutoSizeText(
            'Balance is the amount of money you have in your account. You can use this money to bid on products.',
            maxLines: 3,
            minFontSize: 10,
            maxFontSize: 14,
            style: TextStyle(
              color: getTheme(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            label: const AutoSizeText('Add Balance'),
            icon: const FaIcon(FontAwesomeIcons.moneyBillTransfer),
          ),
        ],
      ),
    );
  }
}

class _ActivityBox extends StatelessWidget {
  const _ActivityBox({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });
  final String title;
  final dynamic value;
  final Color color;
  final String icon;

  @override
  Widget build(BuildContext context) {
    String amount = '';
    if (value is double) {
      amount = formatMoney(value).output.symbolOnLeft;
    } else if (value is int) {
      amount = value.toString();
    }
    return LayoutBuilder(builder: (context, bound) {
      return Container(
        width: getWidth() * 0.4,
        margin: EdgeInsetsDirectional.only(end: paddingDefault),
        padding: EdgeInsets.all(paddingDefault),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(paddingDefault),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(
                  title,
                  style: TextStyle(
                      color: color, fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                height10(),
                AutoSizeText(
                  amount,
                  style: getTheme(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
            Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: Container(
                height: bound.maxHeight * 0.2,
                width: bound.maxHeight * 0.2,
                padding: EdgeInsets.all(paddingDefault * 0.2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(paddingDefault),
                ),
                child: assetImages(icon, color: color),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _BidHistory extends StatefulWidget {
  const _BidHistory({
    required this.homeCtrl,
    required this.authCtrl,
    required this.bound,
  });
  final HomeController homeCtrl;
  final AuthController authCtrl;
  final BoxConstraints bound;

  @override
  State<_BidHistory> createState() => _BidHistoryState();
}

class _BidHistoryState extends State<_BidHistory> {
  late ScrollController scrollController;
  var controller = Get.put(BidController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getWinningBids(pageNo: 1, perPage: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BidController>(builder: (bidCtrl) {
      var total = bidCtrl.loadingWinnings ? 5 : bidCtrl.totalWinningBids;
      bool loading = bidCtrl.loadingWinnings;
      return Column(
        children: [
          height30(),
          Column(
            children: [
              _titleRow(context, bidCtrl),
              height10(),
              SizedBox(
                height: 80,
                child: LoadMoreContainer(
                  axis: Axis.horizontal,
                  onLoadMore: () async {
                    await controller.getWinningBids(
                        pageNo: controller.pageWinningBids + 1, perPage: 10);
                  },
                  onRefresh: () async {
                    await controller.getWinningBids(pageNo: 1, perPage: 10);
                  },
                  finishWhen: bidCtrl.winningBids.length >= total,
                  builder: (scroll, status) {
                    scrollController = scroll;
                    if (!loading && bidCtrl.winningBids.isEmpty) {
                      return const Center(
                          child: AutoSizeText('You have no winning bids'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: EdgeInsetsDirectional.only(
                          start: paddingDefault, end: paddingDefault),
                      itemCount: loading ? 5 : total,
                      itemBuilder: (context, index) {
                        WinnigBid? bid =
                            loading ? null : bidCtrl.winningBids[index];
                        return _WinnigBidsCard(
                          loading: loading,
                          winning: bid,
                          bound: widget.bound,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Padding _titleRow(BuildContext context, BidController bidCtrl) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingDefault),
      child: Row(
        children: [
          AutoSizeText(
            'Bid History',
            style: TextStyle(
              color: getTheme(context)
                  .textTheme
                  .displaySmall
                  ?.color
                  ?.withOpacity(0.5),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              bidCtrl
                  .getWinningBids(pageNo: 1, perPage: 10)
                  .then((value) => scrollController.animateTo(
                        scrollController.position.minScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeIn,
                      ));
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                bidCtrl.loadingWinnings
                    ? const CupertinoActivityIndicator()
                    : Icon(
                        Icons.refresh,
                        color: getTheme(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.5),
                      ),
                width5(),
                AutoSizeText(
                  'Refresh',
                  style: TextStyle(
                    color: getTheme(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withOpacity(0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WinnigBidsCard extends StatelessWidget {
  const _WinnigBidsCard({
    required this.loading,
    this.winning,
    required this.bound,
  });

  final bool loading;
  final WinnigBid? winning;
  final BoxConstraints bound;

  @override
  Widget build(BuildContext context) {
    var product = winning?.product;
    String image =
        product?.images.isNotEmpty == true ? product?.images.first ?? '' : '';
    return DefaultRefreshEffect(
      loading: loading,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.only(
                top: paddingDefault, end: paddingDefault),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(paddingDefault),
              child: Container(
                color: getTheme(context).primaryColorDark.withOpacity(0.1),
                constraints: BoxConstraints(
                  minWidth: bound.maxWidth * 0.5,
                  maxWidth: bound.maxWidth * 0.8,
                ),
                child: ListTile(
                  onTap: product == null
                      ? null
                      : () {
                          context.push('${Routes.auctionDetail}/${product.id}');
                        },
                  contentPadding: EdgeInsetsDirectional.symmetric(
                      horizontal: paddingDefault),
                  leading: Container(
                    constraints:
                        const BoxConstraints(maxWidth: 50, maxHeight: 50),
                    decoration: const BoxDecoration(
                        color: Colors.transparent, shape: BoxShape.circle),
                    child: buildCachedImageWithLoading(image, borderRadius: 50),
                  ),
                  title: AutoSizeText(
                    product?.name ?? '-----------------',
                    style: TextStyle(
                      color: getTheme(context).textTheme.displaySmall?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: AutoSizeText(
                    formatMoney(1000).output.symbolOnLeft,
                    style: TextStyle(
                      color: getTheme(context).textTheme.bodySmall?.color,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const AutoSizeText(
                    '0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),

          ///check icon
          Positioned(
            top: paddingDefault * 0.5,
            right: paddingDefault * 0.6,
            child: Container(
              height: paddingDefault * 2,
              width: paddingDefault * 2,
              padding: EdgeInsets.all(paddingDefault * 0.2),
              decoration: BoxDecoration(
                color: getTheme(context)
                    .elevatedButtonTheme
                    .style
                    ?.backgroundColor
                    ?.resolve({MaterialState.selected})?.withOpacity(1),
                borderRadius: BorderRadius.circular(paddingDefault),
              ),
              child: FittedBox(
                  child: Icon(Icons.check,
                      color: Colors.white,
                      weight: paddingDefault,
                      size: paddingDefault / 2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({
    required this.authCtrl,
    required this.bound,
  });
  final AuthController authCtrl;
  final BoxConstraints bound;

  @override
  Widget build(BuildContext context) {
    var user = authCtrl.getUser<AuctionUser>();
    var mobile = user?.mobile ?? '';
    var email = user?.email ?? '';
    bool ev = user?.ev == 1;
    var isDark = getTheme(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingDefault),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///email
              _email(context, email, ev),

              ///mobile
              _phone(context, mobile),

              ///address
              _address(context, user),
            ],
          ),
        ],
      ),
    );
  }

  ListTile _address(BuildContext context, AuctionUser? user) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: faIcon(FontAwesomeIcons.locationDot,
          color:
              getTheme(context).textTheme.titleLarge!.color!.withOpacity(0.5)),
      title: bodyMedText('Address', context, fontWeight: FontWeight.bold),
      subtitle: Builder(builder: (context) {
        var address = _getAddressString(
          user?.address?.address ?? "",
          user?.address?.city ?? "",
          user?.address?.state ?? "",
          user?.address?.country ?? "",
          user?.address?.zip ?? "",
        );
        return capText(address.isEmpty ? 'Not set' : address, context,
            fontWeight: FontWeight.w500);
      }),
    );
  }

  ListTile _phone(BuildContext context, String mobile) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: faIcon(FontAwesomeIcons.phone,
          color:
              getTheme(context).textTheme.titleLarge!.color!.withOpacity(0.5)),
      title: bodyMedText('Mobile', context, fontWeight: FontWeight.bold),
      subtitle: capText(mobile.isEmpty ? 'Not set' : mobile, context,
          fontWeight: FontWeight.w500),
    );
  }

  ListTile _email(BuildContext context, String email, bool ev) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: faIcon(FontAwesomeIcons.envelope,
          color:
              getTheme(context).textTheme.titleLarge!.color!.withOpacity(0.5)),
      title: bodyMedText('Email', context, fontWeight: FontWeight.bold),
      subtitle: capText(email.isEmpty ? 'Not set' : email, context,
          fontWeight: FontWeight.w500),
      trailing: IconButton(
        onPressed: () => showCupertinoModalPopup(
            context: context,
            builder: (_) => CustomBottomsheet(
                topMargin: getHeight(context) * 0.5,
                builder: (bound) => _EmailVerificationSheet(
                    email: email, ev: ev && email.isNotEmpty, bound: bound))),
        icon: email.isEmpty
            ? Container()
            : faIcon(
                !ev
                    ? FontAwesomeIcons.circleExclamation
                    : FontAwesomeIcons.circleCheck,
                color: !ev ? Colors.red : Colors.green,
              ),
      ),
    );
  }

  String _getAddressString(String s, String t, String u, String v, String w) {
    String address = '';
    if (s.isNotEmpty) {
      address += '$s, ';
    }
    if (t.isNotEmpty) {
      address += '$t, ';
    }
    if (u.isNotEmpty) {
      address += '$u, ';
    }
    if (v.isNotEmpty) {
      address += '$v, ';
    }
    if (w.isNotEmpty) {
      address += '$w, ';
    }
    return address;
  }
}

class _EmailVerificationSheet extends StatefulWidget {
  const _EmailVerificationSheet({
    required this.email,
    required this.ev,
    required this.bound,
  });
  final String email;
  final bool ev;
  final BoxConstraints bound;

  @override
  State<_EmailVerificationSheet> createState() =>
      _EmailVerificationSheetState();
}

class _EmailVerificationSheetState extends State<_EmailVerificationSheet> {
  final otpController = TextEditingController();

  final ValueNotifier<bool> _loadingEmail = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _emailOtpSent = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _emailVerified = ValueNotifier<bool>(false);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _emailVerified,
        builder: (context, emailVerified, _) {
          return ValueListenableBuilder(
              valueListenable: _loadingEmail,
              builder: (context, isLoading, _) {
                return ValueListenableBuilder(
                    valueListenable: _emailOtpSent,
                    builder: (context, otpSent, _) {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                  height: getHeight(context) * 0.5,
                                  width: widget.bound.maxWidth),

                              ///success celebration
                              if (emailVerified)
                                Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    child: assetLottie(
                                        MyLottie.successCelebration)),

                              ///UI
                              Positioned(
                                top: 0,
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  height: getHeight(context) * 0.5,
                                  width: widget.bound.maxWidth,
                                  padding: EdgeInsets.all(paddingDefault),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                          flex: 2,
                                          child: assetLottie(MyLottie.email)),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            ///title
                                            titleLargeText(
                                                widget.ev
                                                    ? 'Email has been verified'
                                                    : 'Email Verification',
                                                context),

                                            widget.email.isEmpty
                                                ? Container()
                                                : capText(widget.email, context,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey),

                                            ///subtitle
                                            height10(),
                                            _description(
                                                emailVerified, otpSent),

                                            ///email otp field
                                            if (!widget.email.isEmptyOrNull &&
                                                !widget.ev &&
                                                otpSent)
                                              _otpField(isLoading, context),

                                            ///button
                                            height10(),
                                            _button(context, emailVerified,
                                                otpSent, isLoading),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    });
              });
        });
  }

  ElevatedButton _button(
      BuildContext context, bool emailVerified, bool otpSent, bool isLoading) {
    return ElevatedButton.icon(
      onPressed: () {
        if (widget.ev || widget.email.isEmpty) {
          Navigator.pop(context);
          context.push(Routes.updateProfile);
        } else if (emailVerified) {
          Navigator.pop(context);
        } else {
          otpSent ? _verifyOtp(context) : _sendOtp(context);
        }
      },
      label: AutoSizeText(
        widget.ev
            ? 'Update email address'
            : widget.email.isEmpty
                ? 'Add email address'
                : emailVerified
                    ? 'Done'
                    : !otpSent
                        ? 'Send OTP'
                        : 'Verify OTP',
      ),
      icon: isLoading
          ? const CupertinoActivityIndicator(color: Colors.white)
          : Container(),
    );
  }

  Column _otpField(bool isLoading, BuildContext context) {
    return Column(
      children: [
        height10(),
        Container(
          constraints: const BoxConstraints(maxWidth: 200),
          child: TextField(
            controller: otpController,
            enabled: !isLoading,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.send,
            onSubmitted: (val) => _verifyOtp(context),
            decoration: InputDecoration(
              fillColor: getTheme(context).scaffoldBackgroundColor,
              hintText: 'Enter OTP',
              hintStyle: TextStyle(
                color: getTheme(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(paddingDefault),
                borderSide: BorderSide(
                  color: getTheme(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.5) ??
                      Colors.black,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row _description(bool emailVerified, bool otpSent) {
    return Row(
      children: [
        Expanded(
          child: AutoSizeText(
            widget.ev
                ? 'All the benefits of our app are available to you.\n Reports and notifications will be sent to your email address'
                : widget.email.isEmpty
                    ? 'Add your email address to get all the benefits of our app. Reports and notifications will be sent to your email address'
                    : emailVerified
                        ? 'Your email address is verified. All the benefits of our app are available to you. Reports and notifications will be sent to your email address'
                        : !otpSent
                            ? 'Please verify your email address to get all the benefits of our app. Reports and notifications will be sent to your email address'
                            : 'Please enter the OTP sent to your email address',
            textAlign: TextAlign.center,
            maxLines: 3,
            minFontSize: 10,
            maxFontSize: 14,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  ///send otp
  void _sendOtp(BuildContext context) async {
    _loadingEmail.value = true;
    await (await UserProvider.instance).sendEmailVerification().then((value) {
      // await 3.delay(() {
      _loadingEmail.value = false;
      _emailOtpSent.value = value;
    });
  }

  ///verify otp
  void _verifyOtp(BuildContext context) async {
    if (otpController.text.isEmpty) {
      toast('Please enter otp');
      return;
    }

    _loadingEmail.value = true;
    await (await UserProvider.instance)
        .verifyEmailOTP(otpController.text)
        .then((value) {
      // await 3.delay(() {
      otpController.clear();
      _loadingEmail.value = false;
      _emailOtpSent.value = !value;
      _emailVerified.value = value;
    });
  }
}

class _BidInfo extends StatelessWidget {
  _BidInfo({
    required this.authCtrl,
    required this.bound,
  });
  final AuthController authCtrl;
  final BoxConstraints bound;
  var bidController = Get.put(BidController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<BidController>(builder: (bidCtrl) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingDefault),
        child: Column(
          children: [
            height30(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      bidCtrl.loadingWinnings
                          ? const CupertinoActivityIndicator()
                          : bodyLargeText(
                              bidCtrl.totalWinningBids.toString(), context),
                      width10(),
                      bodyLargeText('wins', context),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    ///place bidbutton
                    child: SizedBox(
                      // width: bound.maxWidth * 0.5,
                      child: ElevatedButton.icon(
                        onPressed: () => _refferAFriend(
                            authCtrl.getUser<AuctionUser>()?.username),
                        icon: const AutoSizeText('Refer a friend'),
                        label: const Icon(Icons.person_add_alt_1_rounded),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  void _refferAFriend(String? username) async {
    await AppShare.refferAFriend(username);
  }
}

class _ProfileImage extends StatelessWidget {
  _ProfileImage({
    required this.homeCtrl,
    required this.bound,
    required this.authCtrl,
  });
  final HomeController homeCtrl;
  final AuthController authCtrl;
  final BoxConstraints bound;
  final ValueNotifier<bool> updatingImage = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    var profile = authCtrl.getUser<AuctionUser>()?.profileImage ?? '';
    logger.i('profile image $profile');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            homeCtrl.profileProgressValue.value += 20;
          },
          child: Builder(builder: (context) {
            double strokeWidth = 5;
            double size = bound.maxWidth * 0.25;
            return Stack(
              children: [
                SimpleCircularProgressBar(
                  valueNotifier: homeCtrl.profileProgressValue,
                  size: size,
                  progressStrokeWidth: strokeWidth,
                  backStrokeWidth: strokeWidth,
                  backColor: Colors.white10,
                  mergeMode: true,
                  animationDuration: 5,
                  progressColors: const [kPrimaryColor5, Colors.green],
                ),

                ///image
                Positioned(
                  top: strokeWidth,
                  left: strokeWidth,
                  right: strokeWidth,
                  bottom: strokeWidth,
                  child: CircleAvatar(
                      backgroundColor: Colors.white12,
                      child: LayoutBuilder(builder: (context, bound) {
                        return buildCachedNetworkImage(
                          profile,
                          fit: BoxFit.cover,
                          h: bound.maxHeight,
                          w: bound.maxWidth,
                          borderRadius: bound.maxWidth / 2,
                          placeholder: MyPng.dummyUser,
                        );
                        // : Container();
                      })),
                ),

                ///edit icon
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: ValueListenableBuilder(
                    valueListenable: updatingImage,
                    builder: (context, val, _) {
                      return GestureDetector(
                        onTap: val
                            ? null
                            : () => showPopover(
                                  context: context,
                                  direction: PopoverDirection.left,
                                  backgroundColor:
                                      getTheme(context).scaffoldBackgroundColor,
                                  shadow: [
                                    BoxShadow(
                                      color: getTheme(context)
                                              .textTheme
                                              .displayLarge
                                              ?.color
                                              ?.withOpacity(0.5) ??
                                          Colors.black.withOpacity(0.5),
                                      blurRadius: 100,
                                      spreadRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                  bodyBuilder: (context) =>
                                      _buildImageSourceSelection(
                                          context, profile),
                                ),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color:
                                getTheme(context).primaryColor.withOpacity(1),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color:
                                    getTheme(context).scaffoldBackgroundColor,
                                width: 2),
                          ),
                          child: val
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white)
                              : const Icon(Icons.edit,
                                  color: Colors.white, size: 16),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Container _buildImageSourceSelection(BuildContext context, String oldImage) {
    return Container(
      // color: getTheme(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(
          vertical: paddingDefault, horizontal: paddingDefault),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            iconSize: 40,
            onPressed: () =>
                _uploadImage(context, ImageSource.camera, oldImage),
            icon: const FaIcon(FontAwesomeIcons.camera,
                color: Color.fromARGB(255, 3, 253, 16)),
            color: Theme.of(context).highlightColor,
          ),

          ///gallery
          IconButton(
            iconSize: 40,
            onPressed: () =>
                _uploadImage(context, ImageSource.gallery, oldImage),
            icon: const FaIcon(
              FontAwesomeIcons.image,
              color: Color.fromARGB(255, 215, 2, 248),
            ),
            color: Theme.of(context).highlightColor,
          ),
        ],
      ),
    );
  }

  Future<void> _uploadImage(
      BuildContext context, ImageSource source, String oldImage) async {
    Navigator.pop(context);
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 100);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await cropImage(pickedFile.path);
      if (croppedFile != null) {
        updatingImage.value = true;
        await (await UserProvider.instance).updateProfileImage(
          {
            'image': MultipartFile(File(croppedFile.path),
                filename: croppedFile.path.split('/').last)
          },
        ).then((value) async => updatingImage.value = false);
      }
    }
  }
}

class _Appbar extends StatelessWidget {
  const _Appbar(this.context, {required this.authController});
  final AuthController authController;

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: displayLarge('Profile', context),
      systemOverlayStyle: getTransaparentAppBarStatusBarStyle(context),
      iconTheme: getTheme(context).iconTheme,
      actions: [
        IconButton(
          onPressed: () {
            context.push(Routes.profileSettings);
          },
          icon: Icon(Platform.isIOS
              ? CupertinoIcons.settings
              : Icons.settings_rounded),
        ),
      ],
    );
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingDefault),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ///back button
            // const AppBackButton(),

            displayLarge('Profile', context),
            const Spacer(),

            IconButton(
              onPressed: () {
                context.push(Routes.profileSettings);
              },
              icon: Icon(Platform.isIOS
                  ? CupertinoIcons.settings
                  : Icons.settings_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
