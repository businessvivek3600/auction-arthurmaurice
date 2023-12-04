import 'package:action_tds/utils/text.dart';

class Deposit {
  int? id;
  int? userId;
  int? methodCode;
  double? amount;
  String? methodCurrency;
  double? charge;
  double? rate;
  double? finalAmo;
  String? detail;
  String? btcAmo;
  String? btcWallet;
  String? trx;
  int? trial;
  int? status;
  String? adminFeedback;
  String? createdAt;
  String? updatedAt;
  Gateway? gateway;

  Deposit(
      {this.id,
      this.userId,
      this.methodCode,
      this.amount,
      this.methodCurrency,
      this.charge,
      this.rate,
      this.finalAmo,
      this.detail,
      this.btcAmo,
      this.btcWallet,
      this.trx,
      this.trial,
      this.status,
      this.adminFeedback,
      this.createdAt,
      this.updatedAt,
      this.gateway});

  Deposit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    methodCode = json['method_code'];
    amount = json['amount'].toString().getDouble();
    methodCurrency = json['method_currency'];
    charge = json['charge'].toString().getDouble();
    rate = json['rate'].toString().getDouble();
    finalAmo = json['final_amo'].toString().getDouble();
    detail = json['detail'];
    btcAmo = json['btc_amo'];
    btcWallet = json['btc_wallet'];
    trx = json['trx'];
    trial = json['try'];
    status = json['status'];
    adminFeedback = json['admin_feedback'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    gateway =
        json['gateway'] != null ? Gateway.fromJson(json['gateway']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['method_code'] = methodCode;
    data['amount'] = amount.toString();
    data['method_currency'] = methodCurrency;
    data['charge'] = charge.toString();
    data['rate'] = rate.toString();
    data['final_amo'] = finalAmo.toString();
    data['detail'] = detail;
    data['btc_amo'] = btcAmo;
    data['btc_wallet'] = btcWallet;
    data['trx'] = trx;
    data['try'] = trial;
    data['status'] = status;
    data['admin_feedback'] = adminFeedback;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (gateway != null) {
      data['gateway'] = gateway!.toJson();
    }
    return data;
  }
}

class Gateway {
  String? alias;
  String? image;

  Gateway({this.alias, this.image});

  Gateway.fromJson(Map<String, dynamic> json) {
    alias = json['alias'];
    image = json['image'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['alias'] = alias;
    data['image'] = image;
    return data;
  }
}
