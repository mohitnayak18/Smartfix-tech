import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/brand_model.dart';
import 'package:smartfixTech/api_calls/models/product_model.dart';
import 'package:smartfixTech/pages/store/widgets/store_repository.dart';

class StoreController extends GetxController {
  final StoreRepository _repository = StoreRepository();

  // Observables
  final RxList<BrandModel> brands = <BrandModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  final RxList<ProductModel> filteredProducts = <ProductModel>[].obs;
  final RxString selectedBrandId = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStoreData();
  }

  // Load all data
  Future<void> loadStoreData() async {
    isLoading.value = true;
    
    try {
      // Load brands
      final brandsList = await _repository.getBrands();
      brands.value = brandsList;
      
      // Load all products
      final productsList = await _repository.getAllProducts();
      allProducts.value = productsList;
      
      // Debug: Print product images
      for (var product in productsList.take(3)) {
        print('📸 Product: ${product.title}');
        print('   Image URL: ${product.imageUrl}');
        print('   Valid URL: ${product.imageUrl.startsWith('http')}');
      }
      
      // Select first brand by default
      if (brands.isNotEmpty) {
        selectedBrandId.value = brands.first.id;
        await loadProductsByBrand(brands.first.id);
      }
      
      // Also load filtered products (initially all)
      filteredProducts.value = productsList;
    } catch (e) {
      print('❌ Error loading store data: $e');
      Get.snackbar('Error', 'Failed to load store data');
    } finally {
      isLoading.value = false;
    }
  }

  // Load products by brand
  Future<void> loadProductsByBrand(String brandId) async {
    isLoading.value = true;
    try {
      selectedBrandId.value = brandId;
      final products = await _repository.getProductsByBrand(brandId);
      filteredProducts.value = products;
    } catch (e) {
      print('Error loading products by brand: $e');
    } finally {
      isLoading.value = false;
    }
  }


  // Get selected brand name
  String getSelectedBrandName() {
    if (selectedBrandId.value.isEmpty) return '';
    try {
      return brands.firstWhere((b) => b.id == selectedBrandId.value).name;
    } catch (e) {
      return '';
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await loadStoreData();
  }

  // Add product to cart
  void addToCart(ProductModel product) {
    Get.snackbar(
      'Added to Cart',
      '${product.title} added to cart',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

