import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class ModelsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RxList<QueryDocumentSnapshot> models = <QueryDocumentSnapshot>[].obs;
  RxBool isLoading = true.obs;
  RxString error = ''.obs;

  void fetchModels(String brandId) {
    isLoading.value = true;
    error.value = '';
    models.clear(); // Clear previous models

    try {
      _db
          .collection('models')
          .where('brandId', isEqualTo: brandId)
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isEmpty) {
                // log('⚠️ No models found for brandId: $brandId');
               

                // Debug: Check ALL models to see their structure
                // _debugAllModels();
                // log('snapshot.docs: ${snapshot.docs}');
              }

              models.value = snapshot.docs;
              _sortModelsAlphabetically();
              isLoading.value = false;

              // log('✅ Found ${models.length} models for brandId: $brandId');
            },
            onError: (error) {
              isLoading.value = false;
              this.error.value = 'Error: $error';
              // log('❌ Firestore error: $error');
            },
          );
    } catch (e) {
      isLoading.value = false;
      error.value = 'Exception: $e';
      // log('❌ Exception: $e');
    }
  }

  

  void _sortModelsAlphabetically() {
    models.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;
      final nameA = dataA['name']?.toString().toLowerCase() ?? '';
      final nameB = dataB['name']?.toString().toLowerCase() ?? '';
      return nameA.compareTo(nameB);
    });
    models.refresh();
  }
}
