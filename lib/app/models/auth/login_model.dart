abstract class AuthFormModel {
  Map<String, dynamic> toJson();
  AuthFormModel fromJson(Map<String, dynamic> json);
}

class SocialLoginModel extends AuthFormModel {
  String? email;
  String? password;
  String? name;
  String? phone;
  String? image;
  String? provider;
  String? providerId;
  String? token;
  String? fcmToken;
  String? deviceType;
  String? deviceToken;
  String? deviceName;
  String? deviceOs;
  String? deviceOsVersion;
  String? deviceModel;
  SocialLoginType socialLoginType;
  bool? agreeTerms;

  SocialLoginModel({
    this.email,
    this.password,
    this.name,
    this.phone,
    this.image,
    this.provider,
    this.providerId,
    this.token,
    this.fcmToken,
    this.deviceType,
    this.deviceToken,
    this.deviceName,
    this.deviceOs,
    this.deviceOsVersion,
    this.deviceModel,
    this.socialLoginType = SocialLoginType.none,
    this.agreeTerms,
  });

  @override
  AuthFormModel fromJson(Map<String, dynamic> json) {
    return SocialLoginModel(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      phone: json['phone'],
      image: json['image'],
      provider: json['provider'],
      providerId: json['providerId'],
      token: json['token'],
      fcmToken: json['fcmToken'],
      deviceType: json['deviceType'],
      deviceToken: json['deviceToken'],
      deviceName: json['deviceName'],
      deviceOs: json['deviceOs'],
      deviceOsVersion: json['deviceOsVersion'],
      deviceModel: json['deviceModel'],
      socialLoginType: json['socialLoginType'],
      agreeTerms: json['agree'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'image': image,
      'provider': provider,
      'providerId': providerId,
      'token': token,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
      'deviceToken': deviceToken,
      'deviceName': deviceName,
      'deviceOs': deviceOs,
      'deviceOsVersion': deviceOsVersion,
      'deviceModel': deviceModel,
      'socialLoginType': socialLoginType.name,
      'agree': agreeTerms,
    };
  }
}

///Social register model
class SocialRegisterModel extends AuthFormModel {
  String? email;
  String? password;
  String? name;
  String? username;
  String? phone;
  String? image;
  String? provider;
  String? providerId;
  String? token;
  String? fcmToken;
  String? deviceType;
  String? deviceToken;
  String? deviceName;
  String? deviceOs;
  String? deviceOsVersion;
  String? deviceModel;
  SocialLoginType socialLoginType;
  String? agreeTerms;
  String? reference;

  SocialRegisterModel({
    this.email,
    this.password,
    this.name,
    this.username,
    this.phone,
    this.image,
    this.provider,
    this.providerId,
    this.token,
    this.fcmToken,
    this.deviceType,
    this.deviceToken,
    this.deviceName,
    this.deviceOs,
    this.deviceOsVersion,
    this.deviceModel,
    this.socialLoginType = SocialLoginType.none,
    this.agreeTerms,
    this.reference,
  });

  @override
  AuthFormModel fromJson(Map<String, dynamic> json) {
    return SocialRegisterModel(
      email: json['email'],
      password: json['password'],
      name: json['name'],
      username: json['username'],
      phone: json['phone'],
      image: json['image'],
      provider: json['provider'],
      providerId: json['providerId'],
      token: json['token'],
      fcmToken: json['fcmToken'],
      deviceType: json['deviceType'],
      deviceToken: json['deviceToken'],
      deviceName: json['deviceName'],
      deviceOs: json['deviceOs'],
      deviceOsVersion: json['deviceOsVersion'],
      deviceModel: json['deviceModel'],
      socialLoginType: json['socialLoginType'],
      agreeTerms: json['agree'] ?? '0',
      reference: json['reference'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'username': username,
      'phone': phone,
      'image': image,
      'provider': provider,
      'providerId': providerId,
      'token': token,
      'fcmToken': fcmToken,
      'deviceType': deviceType,
      'deviceToken': deviceToken,
      'deviceName': deviceName,
      'deviceOs': deviceOs,
      'deviceOsVersion': deviceOsVersion,
      'deviceModel': deviceModel,
      'socialLoginType': socialLoginType.name,
      'agree': agreeTerms,
      'reference': reference,
    };
  }
}

enum SocialLoginType {
  google,
  facebook,
  apple,
  twitter,
  github,
  phone,
  email,
  password,
  none
}
