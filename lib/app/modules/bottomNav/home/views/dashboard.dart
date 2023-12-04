import "dart:ui";

import 'package:action_tds/components/component_index.dart';

import "/components/home_page_refresh_effect.dart";
import "/constants/constants_index.dart";
import "/database/connect/api_handler.dart";
import "package:go_router/go_router.dart";

import '../../../../../utils/utils_index.dart';
import '../../../../models/auction_app/auction_model_index.dart';
import '../../../../routes/app_pages.dart';
import '../../../category/view/all_categories.dart';
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import 'home_categories.dart';

import '../../../auth/controllers/auth_controller.dart';
import '../controllers/home_controller.dart';
import 'home_banner_slider.dart';
import 'home_hot_bids_staggerd.dart';

class HomeDashboard extends StatelessWidget {
  HomeDashboard({super.key});
  var controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        controller.setHomeScrollController(ScrollController());
      },
      didChangeDependencies: (_) {
        controller.getDashboard(false);
      },
      dispose: (_) {
        HomeController.to.disposeHomeScrollController();
      },
      builder: (homeCtrl) {
        return GetBuilder<AuthController>(
          init: AuthController(),
          builder: (authCtrl) {
            return Scaffold(
              appBar: _appbar(context, authCtrl, homeCtrl),
              body: _body(context, authCtrl, homeCtrl),
            );
          },
        );
      },
    );
  }

  Widget _floatingTab(HomeController ctr) {
    return FloatingActionButton(
      onPressed: () => ctr.increment(),
      child: const Icon(Icons.store_mall_directory_rounded),
    );
  }

  Widget _body(
      BuildContext context, AuthController authCtrl, HomeController ctr) {
    return LoadMoreContainer(
      onRefresh: () async {
        await ctr.getDashboard();
      },
      onLoadMore: () async {},
      finishWhen: 1 == 0,
      builder: (scroll, status) => ListView(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        // controller: scroll,
        children: [
          ///search bar
          // height10(),
          // const _BuildSearchBar(),

          ///banner slider
          // height20(),
          HomeBannerSlider(),

          ///categories
          const HomeCategories(),

          ///hot bids
          height20(),
          HomeHotBids(ctr),

          // height50(100),
          //
        ],
      ),
    );
  }

  AppBar _appbar(
      BuildContext context, AuthController authCtrl, HomeController homeCtrl) {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            // bottom: Radius.circular(20),
            ),
      ),
      title: Row(
        children: [
          width10(paddingDefault / 2),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: kToolbarHeight - 10),
            child: assetImages(getAppLogo(context), fit: BoxFit.contain),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        /// adaptive serach bar
        IconButton(
          onPressed: () {
            var ctr = Get.put(_SearchController());
            ctr.searchResult = [[], []];
            ctr.currentQuery = '';
            ctr.previousQuery = '';
            ctr.suggestions.clear();
            ctr.suggestions = homeCtrl.categories
                .where((element) => element.name != null && element.name != '')
                .map((e) => e.name ?? "")
                .toList();
            showSearch(context: context, delegate: _CustomSearchDelegate());
          },
          icon: const Icon(Icons.search),
        ),

        IconButton(
          onPressed: () {
            // throw 'test error';
          },
          icon: const Icon(Icons.notifications),
        ),

        ///error log
        // IconButton(
        //   onPressed: () => context.push(Routes.errorLogListScreen),
        //   icon: const Icon(Icons.error),
        // ),
        width10(paddingDefault / 2),
      ],
    );
  }
}

class _CustomSearchDelegate extends SearchDelegate<Future<Widget>> {
  var controller = Get.put(_SearchController());

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(CupertinoIcons.clear_circled_solid),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    /// back button
    return IconButton(
      onPressed: () async {
        query = '';
        controller.searchResult.clear();
        controller.currentQuery = '';
        controller.previousQuery = '';
        close(context, Future.value(Container()));
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }
    return FutureBuilder<List>(
      future: controller.updateSearch(query),
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return resultContent(context, snapshot.data);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget resultContent(BuildContext context, list) {
    return Scaffold(
      body: Column(
        children: [
          if (list[0].isNotEmpty)
            SizedBox(
              height: getHeight(context) * 0.3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(paddingDefault),
                    child: titleLargeText('Categories', context),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsetsDirectional.symmetric(
                          horizontal: paddingDefault),
                      scrollDirection: Axis.horizontal,
                      itemCount: list[0].length,
                      itemBuilder: (context, index) {
                        Category category = list[0][index];
                        return Padding(
                          padding: EdgeInsets.only(right: paddingDefault),
                          child: LargeCategoryCard(
                            height: getHeight(context) * 0.2,
                            width: 200,
                            loading: false,
                            category: category,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (list[1].isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.all(paddingDefault),
                    child: titleLargeText('Auctions', context),
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: controller.searchResult[1].length,
                      itemBuilder: (context, index) {
                        AuctionProduct product =
                            controller.searchResult[1][index];
                        return ListTile(
                          onTap: () {
                            context
                                .push('${Routes.auctionDetail}/${product.id}');
                          },
                          leading: buildCachedImageWithLoading(
                            product.images?.first ?? '',
                            h: 50,
                            w: 50,
                            fit: BoxFit.cover,
                            borderRadius: 10,
                          ),
                          title: Text(product.name ?? ''),
                          subtitle: Text(product.category?.name ?? ''),
                          trailing: Text(product.bids.length.toString()),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    logger.i('search query: $query', tag: _SearchController.tag);

    ///build random suggestions
    final suggestionList = controller.suggestions
        .where((element) => element.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemBuilder: (context, index) {
        var suggession = suggestionList[index];
        List<String> splitWord = [];
        int startIndex = suggession.toLowerCase().indexOf(query.toLowerCase());
        int endIndex = startIndex + query.length - 1;
        splitWord.add(suggession.substring(0, startIndex));
        splitWord.add(suggession.substring(startIndex, endIndex + 1));
        if (suggession.length > endIndex + 1) {
          splitWord.add(suggession.substring(endIndex + 1));
        }
        print('fragments $splitWord');
        return ListTile(
          onTap: () {
            query = suggestionList[index];
            showResults(context);
          },
          leading: const Icon(Icons.search),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: getTheme(context).secondaryHeaderColor,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    ...splitWord.map(
                      (e) {
                        Color color = splitWord.indexOf(e) == 1
                            ? getTheme(context).secondaryHeaderColor
                            : Colors.grey;
                        return TextSpan(
                          text: e,
                          style: TextStyle(color: color),
                        );
                      },
                    ).toList(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      itemCount: suggestionList.length,
    );
  }
}

class _SearchController extends GetxController {
  static const String tag = 'SearchBloc';

  static int page = 1;
  String currentQuery = '';
  String previousQuery = '';
  List searchResult = [[], []];

  List<String> suggestions = [];

  Future<List> updateSearch(String query) async {
    if (query.isNotEmpty) {
      logger.d(
          'query: $query currentQuery:$currentQuery previousQuery:$previousQuery');
      if (query != currentQuery) {
        previousQuery = currentQuery;
        currentQuery = query;
        page = 1;
        searchResult = await search(currentQuery, page);
        update();
      }
    }
    return searchResult;
  }

  Future<List> search(String query, [int p = 1]) async {
    List result = [
      [],
      [],
    ];
    page = p;
    try {
      var res = await ApiHandler.hitApi(ApiConst.search,
          method: ApiMethod.GET,
          query: {'search': query, 'page_no': page.toString()});
      if (res != null) {
        result[0] = await _getCategoryListFromJson(res['category']);
        result[1] = await _getProductListFromJson(res['products']);
        page++;
      }
      logger.f('search result: $result', tag: tag);
    } catch (e) {
      logger.e('search Error', tag: tag, error: e);
    }
    return result;
  }

  Future<List<AuctionProduct>> _getProductListFromJson(dynamic json) async {
    List<AuctionProduct> products = [];
    try {
      if (json != null && json is List) {
        await Future.microtask(() =>
            products = json.map((e) => AuctionProduct.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getProductListFromJson  error: ', tag: tag, error: e);
    }
    return products;
  }

  Future<List<Category>> _getCategoryListFromJson<T>(dynamic json) async {
    List<Category> categories = [];

    try {
      if (json != null && json is List) {
        await Future.microtask(
            () => categories = json.map((e) => Category.fromJson(e)).toList());
      }
    } catch (e) {
      logger.e('_getCategoryListFromJson $T error: ', tag: tag, error: e);
    }
    return categories;
  }
}

class _BuildSearchBar extends StatelessWidget {
  const _BuildSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        blendMode: BlendMode.srcOver,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: paddingDefault),
          decoration: BoxDecoration(
            color: Colors.grey.shade200.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors:
                            [kPrimaryColor6, lightAccent].reversed.toList()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                      icon: const Icon(CupertinoIcons.search,
                          color: Colors.white38),
                      onPressed: () {})),
              width10(),
              Column(
                children: [
                  bodyLargeText(
                      'Search ${Get.put(AuthController()).currentUser}',
                      context,
                      color: Colors.white60),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
