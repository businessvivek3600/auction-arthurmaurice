import '/constants/constants_index.dart';
import 'package:get/get.dart';
import '/app/models/auction_app/auction_model_index.dart';

class HomeBanner {
  int? id;
  String? image;
  String? text;
  BannerType? type;
  String? action;
  String? linkId;
  String? createdAt;
  String? updatedAt;
  int? status;
  AuctionProduct? product;
  Category? category;
  String? bgColor;

  HomeBanner({
    this.id,
    this.image,
    this.text,
    this.type,
    this.action,
    this.linkId,
    this.createdAt,
    this.updatedAt,
    this.status,
    this.product,
    this.category,
    this.bgColor,
  });

  HomeBanner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    text = json['text'];
    type = BannerType.values
            .firstWhereOrNull((element) => element.name == json['type']) ??
        BannerType.none;
    action = json['action'];
    linkId = json['link_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    bgColor = json['background_color'];
    status = json['status'];
    product = json['product'] != null
        ? AuctionProduct.fromJson(json['product'])
        : null;
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['image'] = image;
    data['text'] = text;
    data['type'] = type?.name;
    data['action'] = action;
    data['link_id'] = linkId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['background_color'] = bgColor;
    data['status'] = status;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (category != null) {
      data['category'] = category!.toJson();
    }
    return data;
  }
}
