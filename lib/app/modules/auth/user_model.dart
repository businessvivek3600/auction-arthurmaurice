import 'package:nb_utils/nb_utils.dart';

import '/app/models/root_models/root_user_model.dart';

class AuctionUser extends AppUser {
  String? firstname;
  String? lastname;
  String? username;
  String? email;
  int? refBy;
  String? mobile;
  Address? address;
  int? status;
  int? ev;
  int? sv;
  int? ts;
  int? tv;
  String? updatedAt;
  String? createdAt;
  int? id;
  String? profileImage;
  late int bidCount;
  late int totalTransactions;
  late double totalDeposit;
  late double totalBidAmount;
  late double totalBalance;

  AuctionUser({
    this.firstname,
    this.lastname,
    this.username,
    this.email,
    this.refBy,
    this.mobile,
    this.address,
    this.status,
    this.ev,
    this.sv,
    this.ts,
    this.tv,
    this.updatedAt,
    this.createdAt,
    this.id,
    this.profileImage,
    this.bidCount = 0,
    this.totalTransactions = 0,
    this.totalDeposit = 0,
    this.totalBidAmount = 0,
    this.totalBalance = 0,
  });

  AuctionUser.fromJson(Map<String, dynamic> json) {
    firstname = json['firstname'];
    lastname = json['lastname'];
    username = json['username'];
    email = json['email'];
    refBy = json['ref_by'];
    mobile = json['mobile'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    status = json['status'];
    ev = json['ev'];
    sv = json['sv'];
    ts = json['ts'];
    tv = json['tv'];
    updatedAt = json['updated_at'];
    createdAt = json['created_at'];
    id = json['id'];
    profileImage = json['image'];
    bidCount = json['bid_count'].toString().toInt();
    totalTransactions = json['total_transactions'].toString().toInt();
    totalDeposit = json['total_deposit'].toString().toDouble();
    totalBidAmount = json['total_bid_amount'].toString().toDouble();
    totalBalance = json['total_balance'].toString().toDouble();
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['firstname'] = firstname;
    data['lastname'] = lastname;
    data['username'] = username;
    data['email'] = email;
    data['ref_by'] = refBy;
    data['mobile'] = mobile;
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['status'] = status;
    data['ev'] = ev;
    data['sv'] = sv;
    data['ts'] = ts;
    data['tv'] = tv;
    data['updated_at'] = updatedAt;
    data['created_at'] = createdAt;
    data['id'] = id;
    data['image'] = profileImage;
    data['bid_count'] = bidCount;
    data['total_transactions'] = totalTransactions;
    data['total_deposit'] = totalDeposit.toString();
    data['total_bid_amount'] = totalBidAmount.toString();
    data['total_balance'] = totalBalance.toString();

    return data;
  }

  /// get fullname
  String get fullName => '${firstname ?? ''} ${lastname ?? ""}';
}

class Address {
  String? address;
  String? state;
  String? zip;
  String? country;
  String? city;

  Address({this.address, this.state, this.zip, this.country, this.city});

  Address.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
    city = json['city'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['state'] = state;
    data['zip'] = zip;
    data['country'] = country;
    data['city'] = city;
    return data;
  }
}
