import 'package:get/get.dart';
import '/services/auth_services.dart';
import '/services/translation.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService.instance);
    Get.put<TranslationService>(TranslationService());
  }
}
