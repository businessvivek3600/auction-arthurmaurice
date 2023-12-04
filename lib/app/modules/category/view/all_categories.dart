import '/app/models/auction_app/auction_model_index.dart';
import '/app/modules/category/controller/categoryController.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../components/component_index.dart';
import '../../../../components/home_page_refresh_effect.dart';
import '../../../routes/app_pages.dart';

class CategoriesPage extends StatelessWidget {
  CategoriesPage({super.key});
  var controller = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(
      init: CategoryController(),
      initState: (state) {
        controller.getCategories();
      },
      dispose: (_) {
        Get.delete<CategoryController>();
      },
      builder: (categoryCtrl) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Categories',
            ),
          ),
          body: _BuildCategoriesList(categoryCtrl),
        );
      },
    );
  }
}

class _BuildCategoriesList extends StatelessWidget {
  const _BuildCategoriesList(this.controller, {super.key});
  final CategoryController controller;

  @override
  Widget build(BuildContext context) {
    bool loading = controller.loading;
    logger.f('loading: $loading ${controller.categories.length}');
    return LoadMoreContainer(
        finishWhen: controller.categories.length >= controller.totalCategories,
        onLoadMore: () async {
          await Future.delayed(const Duration(seconds: 1));
          await controller.getCategories(pageNo: controller.page + 1);
        },
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          await controller.getCategories(pageNo: 1);
        },
        builder: (scroll, status) {
          int total = loading ? 15 : controller.categories.length;
          return MasonryGridView.count(
            controller: scroll,
            padding: EdgeInsets.all(paddingDefault),
            physics: const AlwaysScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            itemCount: total + 2,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              bool isLast = index == total || index == total + 1;
              final height = Get.height * 0.3;
              return !isLast
                  ? LargeCategoryCard(
                      height: height,
                      category: loading ? null : controller.categories[index],
                      loading: loading,
                    )
                  : Container(height: height.toDouble());
            },
          );
        });
  }
}

class LargeCategoryCard extends StatelessWidget {
  const LargeCategoryCard({
    super.key,
    required this.height,
    this.category,
    this.width,
    required this.loading,
  });

  final double height;
  final double? width;
  final Category? category;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    print(category?.toJson());
    return GestureDetector(
      onTap: loading
          ? null
          : () {
              context.push('${Routes.category}/${category!.id}');
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
                  border: Border.all(
                      color:
                          getTheme(context).primaryColorDark.withOpacity(0.1),
                      width: 1),
                  color: getTheme(context).primaryColorDark.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(paddingDefault),
                ),
                padding: EdgeInsets.all(paddingDefault),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: buildCachedImageWithLoading(
                        loading ? '' : (category?.icon ?? ''),
                        fit: BoxFit.contain,
                      ),
                    ),
                    height10(spaceDefault),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          category?.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        height10(spaceDefault),
                        Container(
                          decoration: BoxDecoration(
                            color:
                                getTheme(context).primaryColor.withOpacity(1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: paddingDefault / 2,
                              vertical: paddingDefault / 4),
                          child: Center(
                            child: AutoSizeText(
                              '${category?.totalProducts.toString() ?? ''}  Watches',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              minFontSize: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ));
          }),
        ),
      ),
    );
  }
}
