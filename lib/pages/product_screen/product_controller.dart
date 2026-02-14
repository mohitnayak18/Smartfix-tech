import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// class ProductController extends GetxController {
//   // final String serviceId;
//   final FirebaseFirestore _db = FirebaseFirestore.instance;

//   final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> products =
//       <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

class ProductController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔥 Store only Map data
  final RxList<Map<String, dynamic>> products = <Map<String, dynamic>>[].obs;

  final RxBool isLoading = true.obs;

  Future<void> fetchProducts(
    String serviceId,
    String modelId,
    String brandId,
  ) async {
    try {
      isLoading.value = true;

      final snapshot = await _db
          .collection('products')
          .where('serviceId', isEqualTo: serviceId)
          .where('modelId', isEqualTo: modelId)
          .where('brandId', isEqualTo: brandId)
          .get();
      // log(snapshot.toString());
      // 🔥 Convert docs to Map directly
      products.assignAll(snapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load products',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
