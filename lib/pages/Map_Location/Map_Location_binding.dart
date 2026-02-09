import 'package:get/get.dart';
import 'package:smartfixTech/pages/Map_Location/Map_Location.dart';

class MapLocationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MapLocationController());
  }
}
