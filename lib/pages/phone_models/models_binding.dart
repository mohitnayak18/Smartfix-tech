import 'package:get/get.dart';

import 'package:smartfixTech/pages/phone_models/models_controller.dart';

class ModelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ModelsController());
  }
}
