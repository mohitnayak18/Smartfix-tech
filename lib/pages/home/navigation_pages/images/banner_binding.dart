import 'package:get/get.dart';
import 'package:smartfixapp/pages/home/navigation_pages/images/banner.dart';


class BannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BannerController());
  }
}
