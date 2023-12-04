import 'package:action_tds/app/modules/bottomNav/transactions/controller/transactionController.dart';
import 'package:action_tds/app/modules/bottomNav/transactions/view/deposit_history.dart';
import 'package:action_tds/components/component_index.dart';
import 'package:action_tds/utils/text.dart';
import 'package:action_tds/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'all_transaction.dart';

class TransactionPage extends StatelessWidget {
  TransactionPage({super.key});
  var controller = Get.put(TransactionController());
  @override
  Widget build(BuildContext context) {
    var collapsedHeight = kToolbarHeight;
    var expandedHeight = collapsedHeight + getHeight(context) * 0.06;
    return GetBuilder<TransactionController>(
      builder: (transCtrl) {
        return Scaffold(
          appBar: _AppBar(
            transCtrl: transCtrl,
            expandedHeight: expandedHeight,
            collapsedHeight: collapsedHeight,
          ),
          body:
              _buildTabView(context, transCtrl, expandedHeight: expandedHeight),
        );
      },
    );
  }

  Widget _buildTabView(BuildContext context, TransactionController transCtrl,
      {required double expandedHeight}) {
    return SizedBox(
      height: getHeight(context) + expandedHeight,
      child: TabBarView(
        controller: transCtrl.tabController,
        children: [
          TransactionHistory(),
          // DepositeHistory(),
          DepositeHistory(),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar({
    super.key,
    required this.transCtrl,
    required this.expandedHeight,
    required this.collapsedHeight,
  });
  final TransactionController transCtrl;
  final double expandedHeight;
  final double collapsedHeight;

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        systemOverlayStyle: getTransaparentAppBarStatusBarStyle(context),
        elevation: 0,
        toolbarHeight: 0,
        flexibleSpace: FlexibleSpaceBar(
          titlePadding:
              EdgeInsetsDirectional.only(bottom: collapsedHeight * 0.2),
          expandedTitleScale: 1.1,
          title: Row(
            children: [
              const Spacer(flex: 1),
              Expanded(
                flex: 3,
                child: Container(
                  height: getHeight(context) * 0.05,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                          color: getTheme(context).primaryColorDark, width: 1)),
                  padding: EdgeInsets.all(getHeight(context) * 0.005),
                  child: TabBar(
                    controller: transCtrl.tabController,
                    indicatorColor: Colors.white,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: getTheme(context).primaryColor,
                    ),
                    labelColor: Colors.white,
                    labelPadding: EdgeInsets.zero,
                    dividerColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: EdgeInsets.zero,
                    indicatorWeight: 0,
                    splashBorderRadius: BorderRadius.circular(100),
                    dragStartBehavior: DragStartBehavior.start,
                    labelStyle: getTheme(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.bold),
                    tabs: [
                      Tab(
                        child: Padding(
                          padding: EdgeInsets.all(getHeight(context) * 0.005),
                          child: const AutoSizeText('All Transactions',
                              maxLines: 1, textAlign: TextAlign.center),
                        ),
                      ),
                      const Tab(
                        text: 'Deposit',
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
          centerTitle: true,
          background: SafeArea(
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: getWidth(context) * 0.05),
              child: displayLarge('Transactions', context),
            ),
          ),
        ),
      );
    });
  }

  @override
  Size get preferredSize => Size.fromHeight(expandedHeight);
}
