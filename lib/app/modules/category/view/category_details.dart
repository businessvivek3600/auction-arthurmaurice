// ignore_for_file: must_be_immutable

import '/app/modules/category/controller/categoryController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../components/component_index.dart';
import '../../../../components/home_page_refresh_effect.dart';
import '../../../../utils/utils_index.dart';

class CategoryByIdPage extends StatelessWidget {
  CategoryByIdPage({super.key, this.id});
  final String? id;
  var controller = Get.put(CategoryController());
  @override
  Widget build(BuildContext context) {
    if (id != null && id!.isNotEmpty) {
      controller.getCategoryProducts(categoryId: id!);
    }
    return GetBuilder<CategoryController>(initState: (state) {
      // if (id != null && id!.isNotEmpty) {
      //   controller.getCategoryProducts(categoryId: id!);
      // }
    }, dispose: (_) {
      controller.categoryProducts.clear();
      controller.loadingCategoryProducts = false;
      controller.totalCategoryProducts = 0;
      controller.category = null;
    }, builder: (ctr) {
      bool loading = ctr.loadingCategoryProducts;
      int total = loading ? 15 : ctr.categoryProducts.length;
      return Scaffold(
        appBar: _AppBar(ctr),
        body: LoadMoreContainer(
          finishWhen: ctr.categoryProducts.length >= ctr.totalCategoryProducts,
          onLoadMore: () async {
            await controller.getCategoryProducts(categoryId: id!);
          },
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            await controller.getCategoryProducts(categoryId: id!);
          },
          builder: (scroll, status) {
            return DefaultRefreshEffect(
              loading: loading,
              child: MasonryGridView.count(
                controller: scroll,
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
                          loading: false,
                          product: loading ? null : ctr.categoryProducts[index],
                        )
                      : Container(height: height.toDouble());
                },
              ),
            );
          },
        ),
      );
    });
  }
}

class _AppBar extends StatelessWidget implements PreferredSizeWidget {
  const _AppBar(
    this.ctr, {
    super.key,
  });
  final CategoryController ctr;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(ctr.loadingCategoryProducts
          ? 'Loading...'
          : ctr.category?.name ?? 'Category'),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
