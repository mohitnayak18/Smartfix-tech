import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/models/banner_model.dart';

class BannerController extends GetxController {
  // State
  final isLoading = false.obs;
  final carouselCurrentIndex = 0.obs;
  final RxList<BannerModel> banners = <BannerModel>[].obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  void updatePageIndicator(int index) {
    carouselCurrentIndex.value = index;
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      final result = await _db
          .collection('banners')
          .where('active', isEqualTo: true)
          // .orderBy('order')
          .get();

      final fetchedBanners = result.docs
          .map((doc) => BannerModel.fromSnapshot(doc))
          .toList();

      banners.assignAll(fetchedBanners);

    } on FirebaseException catch (e) {
      Get.snackbar("Firebase Error", e.message ?? "Something went wrong");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
