import 'package:get/get.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location.dart';

class GetLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GetLocationController());
  }
}
