import 'package:get/get.dart';

import 'package:smartfixapp/pages/phonemodels/models_controller.dart';

class ModelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ModelsController());
  }
}
