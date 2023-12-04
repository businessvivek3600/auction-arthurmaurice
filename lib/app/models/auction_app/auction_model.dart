import '/utils/utils_index.dart';

import '../../modules/auth/user_model.dart';

class AuctionProduct {
  int? id;
  int? categoryId;
  String? name;
  String? startDate;
  String? endDate;
  String? price;
  late int totalBids;
  String? shippingCost;
  String? deliveryTime;
  List<String>? keywords;
  String? shortDescription;
  String? longDescription;
  String? image;
  late List<String> images;
  String? modelLink;
  bool? hasModel;
  Map<String, dynamic>? othersInfo;
  late double avgRating;
  late int totalRating;
  late int totalReviews;
  int? status;
  int? winnerId;
  int? bidComplete;
  String? createdAt;
  String? updatedAt;
  Category? category;
  List<Bid> bids = [];
  late double highestBidAmount;
  AuctionReview? userReview;

  AuctionProduct({
    this.id,
    this.categoryId,
    this.name,
    this.totalBids = 0,
    this.startDate,
    this.endDate,
    this.price,
    this.shippingCost,
    this.deliveryTime,
    this.keywords,
    this.shortDescription,
    this.longDescription,
    this.image,
    required this.images,
    this.modelLink = '',
    this.hasModel = false,
    this.othersInfo,
    this.avgRating = 0.0,
    this.totalRating = 0,
    this.totalReviews = 0,
    this.status,
    this.winnerId,
    this.bidComplete,
    this.createdAt,
    this.updatedAt,
    this.category,
    this.bids = const [],
    this.highestBidAmount = 0.0,
    this.userReview,
  });

  AuctionProduct.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    categoryId = json['category_id'];
    name = json['name'];
    startDate = json['started_at'];
    endDate = json['expired_at'];
    price = json['price'];
    totalBids = json['total_bid'] ?? 0;
    shippingCost = json['shipping_cost'];
    deliveryTime = json['delivery_time'];
    if (json['keywords'] != null && json['keywords'] is List) {
      keywords = <String>[];
      json['keywords'].forEach((v) {
        keywords!.add(v);
      });
    }
    shortDescription = json['short_description'];
    longDescription = json['long_description'];
    image = json['image'];
    if (json['images'] != null && json['images'] is List) {
      images = <String>[];
      json['images'].forEach((v) {
        images.add(v);
      });
    } else {
      images = <String>[];
    }
    hasModel = json['has_modal'] == 1;
    modelLink = json['modal_url'] ?? '';
    othersInfo = json['others_info'];
    avgRating = double.tryParse(json['avg_rating'].toString()) ?? 0.0;
    totalRating = json['total_rating'] ?? 0;
    totalReviews = json['review_count'] ?? 0;
    status = json['status'];
    winnerId = json['winner_id'];
    bidComplete = json['bid_complete'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    category =
        json['category'] != null ? Category.fromJson(json['category']) : null;
    if (json['bids'] != null && json['bids'] is List) {
      bids = <Bid>[];
      json['bids'].forEach((v) {
        bids.add(Bid.fromJson(v));
      });
    }
    highestBidAmount = double.tryParse(json['highest_bid'].toString()) ?? 0.0;
    userReview = json['user_review'] != null
        ? AuctionReview.fromJson(json['user_review'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['category_id'] = categoryId;
    data['name'] = name;
    data['started_at'] = startDate;
    data['expired_at'] = endDate;
    data['price'] = price;
    data['total_bid'] = totalBids;
    data['shipping_cost'] = shippingCost;
    data['delivery_time'] = deliveryTime;
    data['keywords'] = keywords;
    data['short_description'] = shortDescription;
    data['long_description'] = longDescription;
    data['image'] = image;
    data['images'] = images;
    data['has_modal'] = hasModel;
    data['modal_url'] = modelLink;
    data['others_info'] = othersInfo;
    data['avg_rating'] = avgRating.toString();
    data['total_rating'] = totalRating;
    data['review_count'] = totalReviews;
    data['status'] = status;
    data['winner_id'] = winnerId;
    data['bid_complete'] = bidComplete;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (category != null) {
      data['category'] = category!.toJson();
    }
    if (bids.isNotEmpty) {
      data['bids'] = bids.map((v) => v.toJson()).toList();
    }
    data['highest_bid'] = highestBidAmount.toString();
    if (userReview != null) {
      data['user_review'] = userReview!.toJson();
    }
    return data;
  }

  /// is live
  bool get isLive {
    if (startDate != null && endDate != null) {
      DateTime start = DateTime.parse(startDate!);
      DateTime end = DateTime.parse(endDate!);
      DateTime now = DateTime.now();
      if (now.isAfter(start) && now.isBefore(end)) {
        return true;
      }
    }
    return false;
  }

  /// is upcoming
  bool get isUpcoming {
    if (startDate != null && endDate != null) {
      DateTime start = DateTime.parse(startDate!);
      DateTime end = DateTime.parse(endDate!);
      DateTime now = DateTime.now();
      if (now.isBefore(start)) {
        return true;
      }
    }
    return false;
  }

  /// is closed
  bool get isClosed {
    if (startDate != null && endDate != null) {
      DateTime end = DateTime.parse(endDate!);
      DateTime now = DateTime.now();
      if (now.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  /// is winner
  bool get isWinner {
    if (winnerId != null) {
      return true;
    }
    return false;
  }

  /// is bid complete
  bool get isBidComplete {
    if (bidComplete != null) {
      return true;
    }
    return false;
  }

  /// is bid started
  bool get isBidStarted {
    try {
      if (startDate != null) {
        DateTime? start = DateTime.tryParse(startDate!);
        DateTime now = DateTime.now();
        if (start != null && now.isBefore(start)) {
          logger.w('isBidStarted: false');
          return false;
        }
        logger.i('isBidStarted: $start true');
        return true;
      }
    } catch (e) {
      logger.e('isBidStarted: $e');
    }
    return false;
  }

  /// is bid ended
  bool get isBidEnded {
    if (endDate != null) {
      DateTime end = DateTime.parse(endDate!);
      DateTime now = DateTime.now();
      if (now.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  (bool, bool, Duration?, String?) isStartedButNotCompleted(
      String? start, String? end) {
    bool isStarted = false;
    bool isCompleted = false;
    Duration? duration;
    String? endedON;
    if (start != null) {
      DateTime? startDate = DateTime.tryParse(start);
      DateTime now = DateTime.now();
      if (startDate != null && now.isBefore(startDate)) {
        // logger.w('isBidStarted: false $startDate');
        isStarted = false;
        duration = startDate.difference(now);
      } else {
        isStarted = true;
      }
    }
    if (end != null) {
      DateTime endDate = DateTime.parse(end);
      DateTime now = DateTime.now();
      if (now.isAfter(endDate)) {
        // logger.w('isBidEnded: true $endDate');
        isCompleted = true;
        endedON = MyDateUtils.getTimeDifference(endDate);
      } else {
        // logger.w('isBidEnded: false $endDate');
        duration ??= endDate.difference(now);
      }
      // logger.i('isBidStarted: started on  $start and ended on  $endDate');
    }
    return (
      isStarted,
      isCompleted,
      duration,
      endedON,
    );
  }
}

class Category {
  int? id;
  String? icon;
  String? name;
  int? status;
  String? createdAt;
  String? updatedAt;
  late int totalProducts;
  List<AuctionProduct>? products;

  Category({
    this.id,
    this.icon,
    this.name,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.products,
    this.totalProducts = 0,
  });

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    name = json['name'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    totalProducts = int.tryParse(json['product_count'].toString()) ?? 0;
    if (json['products'] != null && json['products'] is List) {
      products = <AuctionProduct>[];
      json['products'].forEach((v) {
        products!.add(AuctionProduct.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['icon'] = icon;
    data['name'] = name;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['product_count'] = totalProducts;
    if (products != null) {
      data['products'] = products!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Bid {
  int? id;
  int? productId;
  int? userId;
  String? amount;
  String? shippingCost;
  String? totalAmount;
  String? createdAt;
  String? updatedAt;
  AuctionUser? user;
  AuctionProduct? product;

  Bid(
      {this.id,
      this.productId,
      this.userId,
      this.amount,
      this.shippingCost,
      this.totalAmount,
      this.createdAt,
      this.updatedAt,
      this.user,
      this.product});

  Bid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productId = json['product_id'];
    userId = json['user_id'];
    amount = json['amount'];
    shippingCost = json['shipping_cost'];
    totalAmount = json['total_amount'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null
        ? AuctionProduct.fromJson(json['product'])
        : null;
    user = json['user'] != null ? AuctionUser.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['product_id'] = productId;
    data['user_id'] = userId;
    data['amount'] = amount;
    data['shipping_cost'] = shippingCost;
    data['total_amount'] = totalAmount;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (user != null) {
      data['user'] = user!.toJson();
    }
    if (product != null) {
      data['product'] = product!.toJson();
    }
    return data;
  }
}

class WinnigBid {
  int? id;
  int? bidId;
  int? userId;
  int? shippingStatus;
  String? createdAt;
  String? updatedAt;
  AuctionProduct? product;
  Bid? bid;

  WinnigBid(
      {this.id,
      this.bidId,
      this.userId,
      this.shippingStatus,
      this.createdAt,
      this.updatedAt,
      this.product,
      this.bid});

  WinnigBid.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    bidId = json['bid_id'];
    userId = json['user_id'];
    shippingStatus = json['shipping_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    product = json['product'] != null
        ? AuctionProduct.fromJson(json['product'])
        : null;
    bid = json['bid'] != null ? Bid.fromJson(json['bid']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['bid_id'] = bidId;
    data['user_id'] = userId;
    data['shipping_status'] = shippingStatus;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (product != null) {
      data['product'] = product!.toJson();
    }
    if (bid != null) {
      data['bid'] = bid!.toJson();
    }
    return data;
  }
}

class AuctionReview {
  int? id;
  late double rating;
  String? description;
  int? userId;
  int? productId;
  int? merchantId;
  String? createdAt;
  String? updatedAt;
  String? username;
  String? profilePic;

  AuctionReview(
      {this.id,
      this.rating = 0.0,
      this.description,
      this.userId,
      this.productId,
      this.merchantId,
      this.createdAt,
      this.updatedAt,
      this.username,
      this.profilePic});

  AuctionReview.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    rating = double.tryParse(json['rating'].toString()) ?? 0.0;
    description = json['description'];
    userId = json['user_id'];
    productId = json['product_id'];
    merchantId = json['merchant_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    username = json['user']?['username'] ?? '';
    profilePic = json['user']?['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['rating'] = rating;
    data['description'] = description;
    data['user_id'] = userId;
    data['product_id'] = productId;
    data['merchant_id'] = merchantId;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['username'] = username;
    data['profile_pic'] = profilePic;
    return data;
  }
}
