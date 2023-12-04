import 'package:get/get.dart';

import '../controllers/app_tour_controller.dart';

class AppTourBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AppTourController>(
      () => AppTourController(),
    );
  }
}
