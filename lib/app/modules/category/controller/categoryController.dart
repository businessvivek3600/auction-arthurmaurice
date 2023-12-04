import '/app/models/auction_app/auction_model_index.dart';
import '/constants/constants_index.dart';
import 'package:get/get.dart';

import '../../../../database/connect/api_handler.dart';
import '../../../../utils/utils_index.dart';

class CategoryController extends GetxController {
  static const tag = 'CategoryController';
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    categories.clear();
    totalCategories = 0;
    loading = true;

    categoryProducts.clear();
    category = null;
    pageCategoryProducts = 1;
    totalCategoryProducts = 0;
    super.onClose();
  }

  List<Category> categories = [];
  int totalCategories = 0;
  bool loading = true;
  int page = 1;

  Future<void> getCategories({
    int pageNo = 1,
    int perPage = 10,
    String products = '',
  }) async {
    try {
      loading = true;
      update();
      page = pageNo;
      Uri uri = Uri.parse(ApiConst.categories);
      uri = uri.replace(queryParameters: {
        'page_no': '$pageNo',
        'per_page': '$perPage',
        if (products.isNotEmpty) 'product': products,
      });
      logger.i('getCategories uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.path, method: ApiMethod.GET);
      if (res != null) {
        totalCategories = res['total_data'];
        if (pageNo == 1) {
          categories = await _getCategoryListFromJson(res['categories']);
        } else {
          categories.addAll(await _getCategoryListFromJson(res['categories']));
        }
      }
    } catch (e) {
      logger.e('getCategories error: $e', tag: tag, error: e);
    }
    loading = false;
    update();
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

  List<AuctionProduct> categoryProducts = [];
  Category? category;
  bool loadingCategoryProducts = true;
  int pageCategoryProducts = 1;
  int totalCategoryProducts = 0;

  Future<void> getCategoryProducts({
    int pageNo = 1,
    int perPage = 10,
    String categoryId = '',
  }) async {
    logger.i('getCategoryProducts categoryId: $categoryId', tag: tag);
    try {
      loadingCategoryProducts = true;
      pageCategoryProducts = pageNo;
      Uri uri = Uri.parse(ApiConst.categoryProducts);
      uri = uri.replace(queryParameters: {
        'page_no': '$pageNo',
        'per_page': '$perPage',
        'category_id': categoryId,
      });
      logger.i('getCategoryProducts uri: $uri', tag: tag);
      var res = await ApiHandler.hitApi(uri.toString(), method: ApiMethod.GET);
      if (res != null) {
        totalCategoryProducts = int.tryParse('${res['total_data']}') ?? 0;
        if (pageNo == 1) {
          categoryProducts = await _getProductListFromJson(res['products']);
        } else {
          categoryProducts
              .addAll(await _getProductListFromJson(res['products']));
        }
        try {
          category = Category.fromJson(res['category']);
        } catch (e) {
          logger.e('getCategoryProducts error: $e', tag: tag, error: e);
        }
        update();
      }
    } catch (e) {
      logger.e('getCategoryProducts error: $e', tag: tag, error: e);
    }
    loadingCategoryProducts = false;
    update();
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
}
