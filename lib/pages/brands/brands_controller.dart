// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class BrandsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> brands =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      isLoading.value = true;

      final snapshot = await _db
          .collection('mobile_brands')
          .orderBy('name')
          .get();

      brands.assignAll(snapshot.docs);
     
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load brands',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
