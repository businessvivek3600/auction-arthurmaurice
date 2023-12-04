import '/utils/utils_index.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    logger.w('HomeBinding dependencies');
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
  }
}
