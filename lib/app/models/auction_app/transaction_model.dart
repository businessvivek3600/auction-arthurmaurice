import 'package:action_tds/utils/text.dart';

class Transaction {
  int? id;
  int? userId;
  double? amount;
  double? charge;
  double? postBalance;
  String? trxType;
  String? trx;
  String? details;
  String? createdAt;
  String? updatedAt;

  Transaction(
      {this.id,
      this.userId,
      this.amount,
      this.charge,
      this.postBalance,
      this.trxType,
      this.trx,
      this.details,
      this.createdAt,
      this.updatedAt});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    amount = json['amount'].toString().getDouble();
    charge = json['charge'].toString().getDouble();
    postBalance = json['post_balance'].toString().getDouble();
    trxType = json['trx_type'];
    trx = json['trx'];
    details = json['details'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['amount'] = amount.toString();
    data['charge'] = charge.toString();
    data['post_balance'] = postBalance.toString();
    data['trx_type'] = trxType;
    data['trx'] = trx;
    data['details'] = details;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
