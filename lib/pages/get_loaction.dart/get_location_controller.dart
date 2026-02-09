import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/services/common_service.dart';

class GetLocationController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final _commonService = Get.find<CommonService>();

  // final isLoading = false.obs;

  late String verificationId;

  @override
  void onInit() {
    super.onInit();
    // verificationId = Get.arguments['verificationId'];
  }

  
}
