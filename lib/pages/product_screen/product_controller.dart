import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  // final String serviceId;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxList<QueryDocumentSnapshot<Map<String, dynamic>>> products =
      <QueryDocumentSnapshot<Map<String, dynamic>>>[].obs;

  final RxBool isLoading = true.obs;
  // String? modelId;
  // String? serviceId;
  // String? brandId;

  Future<void> fetchProducts(
    String serviceId,
    String modelId,
    String brandId,
  ) async {
    try {
      isLoading.value = true;
      log(
        "Fetching products for serviceId: $serviceId, modelId: $modelId, brandId: $brandId",
      );

      final snapshot = await _db
          .collection('products')
          // .orderBy('name')
          .where('serviceId', isEqualTo: serviceId)
          .where('modelId', isEqualTo: modelId)
          .where('brandId', isEqualTo: brandId)
          .get();
      log("Snapshot1:${snapshot.docs}");

      products.assignAll(snapshot.docs);
      update();
      log("Snapshot2:${products}");
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
  // final _commonService = Get.find<CommonService>();

  // final _productService = Get.find<ProductService>();
}
