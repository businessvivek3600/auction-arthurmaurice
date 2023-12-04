import 'package:action_tds/components/component_index.dart';
import 'package:action_tds/constants/asset_constants.dart';

import '/app/models/auction_app/auction_model.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '/utils/utils_index.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
        init: HomeController(),
        initState: (_) {},
        builder: (homeCtrl) {
          bool loading = homeCtrl.loadingDashboard;
          int total = loading ? 6 : homeCtrl.categories.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.only(
                    start: paddingDefault,
                    end: paddingDefault,
                    top: paddingDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    titleLargeText('Categories', context),
                    GestureDetector(
                      child: bodyMedText('View All', context),
                      onTap: () => context.push(Routes.category),
                    )
                  ],
                ),
              ),
              height10(spaceDefault),
              SizedBox(
                height: getHeight() * 0.15,
                child: MasonryGridView.count(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsetsDirectional.symmetric(
                      horizontal: paddingDefault),
                  physics: const AlwaysScrollableScrollPhysics(),
                  crossAxisCount: 1,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  itemCount: total,
                  itemBuilder: (context, index) {
                    return Categorycard(
                        loading: loading,
                        margin: 0,
                        category: loading ? null : homeCtrl.categories[index]);
                  },
                ),
              ),
            ],
          );
        });
  }
}

class Categorycard extends StatelessWidget {
  Categorycard({
    super.key,
    required this.loading,
    required this.margin,
    this.category,
  });

  final bool loading;
  final double margin;

  Category? category;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, bound) {
      return DefaultRefreshEffect(
        loading: loading,
        child: GestureDetector(
          onTap: loading
              ? null
              : () => context.push('${Routes.category}/${category!.id}'),
          child: Container(
            // margin: EdgeInsetsDirectional.only(start: margin),
            // padding: EdgeInsets.all(paddingDefault / 2),
            decoration: BoxDecoration(
              boxShadow: const [
                // BoxShadow(
                //   color: Colors.grey.withOpacity(0.05),
                //   spreadRadius: 0.1,
                //   blurRadius: 5,
                //   offset: const Offset(0, 1),
                // ),
                // border: Border.all(
              ],
              //     color: getTheme(context).secondaryHeaderColor.withOpacity(1),
              //     width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 2,
                  child: loading
                      ? Container(
                          width: bound.maxHeight,
                          height: bound.maxHeight,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: getTheme(context)
                                .primaryColorDark
                                .withOpacity(0.05),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: paddingDefault / 2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              width: bound.maxHeight,
                              height: bound.maxHeight,
                              decoration: BoxDecoration(
                                // color:
                                //     getTheme(context).primaryColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                                // shape: BoxShape.circle,
                              ),
                              child: buildCachedImageWithLoading(
                                category?.icon ?? '',
                                fit: BoxFit.contain,
                                placeholder: MyPng.watchPlaceholder,
                              ),
                            ),
                          ),
                        ),
                ),
                height10(paddingDefault / 2),
                Expanded(
                  flex: 1,
                  child: AutoSizeText(
                    (category?.name ?? 'Category Name').split(' ').join('\n'),
                    style: getTheme(context).textTheme.bodySmall?.copyWith(),
                    maxLines: 2,
                    minFontSize: 10,
                    maxFontSize: 14,
                    textAlign: TextAlign.center,
                  ),
                ),
                height10(paddingDefault / 2),
              ],
            ),
          ),
        ),
      );
    });
  }
}
