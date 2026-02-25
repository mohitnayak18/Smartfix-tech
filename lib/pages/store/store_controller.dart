import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Brand Model
class BrandModel {
  final String id;
  final String name;
  final String logo;
  final String? serviceId;

  BrandModel({
    required this.id,
    required this.name,
    required this.logo,
    this.serviceId,
  });

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BrandModel(
      id: doc.id,
      name: data['name'] ?? '',
      logo: data['logo'] ?? '',
      serviceId: data['serviceId'],
    );
  }
}

// Model Model (for mobile models)
class ModelModel {
  final String id;
  final String name;
  final String brandId;
  final String imageUrl;

  ModelModel({
    required this.id,
    required this.name,
    required this.brandId,
    required this.imageUrl,
  });

  factory ModelModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModelModel(
      id: doc.id,
      name: data['name'] ?? '',
      brandId: data['brandId'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }
}

// Product Model
class ProductModel {
  final String id;
  final String name;
  final String price;
  final String? discountPrice;
  final String image;
  final String brandId;
  final String modelId;
  final String? serviceId;
  final String? rating;
  final String? description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    this.discountPrice,
    required this.image,
    required this.brandId,
    required this.modelId,
    this.serviceId,
    this.rating,
    this.description,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: data['price'] ?? '0',
      discountPrice: data['discountPrice'],
      image: data['image'] ?? '',
      brandId: data['brandId'] ?? '',
      modelId: data['modelId'] ?? '',
      serviceId: data['serviceId'],
      rating: data['rating'],
      description: data['description'],
    );
  }

  // Helper getters
  double get priceNum => double.tryParse(price) ?? 0;
  double get discountPriceNum => double.tryParse(discountPrice ?? '0') ?? 0;
  bool get hasDiscount => discountPriceNum > 0;
  double get finalPrice => hasDiscount ? discountPriceNum : priceNum;
  double get offerPercentage => hasDiscount 
      ? ((priceNum - discountPriceNum) / priceNum * 100).roundToDouble() 
      : 0;
  
  String get displayPrice => hasDiscount 
      ? '₹${discountPriceNum.toStringAsFixed(0)}' 
      : '₹${priceNum.toStringAsFixed(0)}';
  
  String get originalPrice => hasDiscount ? '₹${priceNum.toStringAsFixed(0)}' : '';
}

class StoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Service ID passed from previous screen (Home -> Service -> Store)
  final String? serviceId;
  final String? serviceName;

  StoreController({this.serviceId, this.serviceName});

  // Observables for data
  final RxList<BrandModel> brands = <BrandModel>[].obs;
  final RxList<ModelModel> models = <ModelModel>[].obs;
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<ProductModel> allProducts = <ProductModel>[].obs;
  
  // Selected items
  final Rx<BrandModel?> selectedBrand = Rx<BrandModel?>(null);
  final Rx<ModelModel?> selectedModel = Rx<ModelModel?>(null);
  final Rx<ProductModel?> selectedProduct = Rx<ProductModel?>(null);
  
  // Loading states
  final RxBool isLoadingBrands = false.obs;
  final RxBool isLoadingModels = false.obs;
  final RxBool isLoadingProducts = false.obs;
  final RxBool isLoadingAllProducts = false.obs;

  // Current view state
  final RxString currentView = 'brands'.obs; // 'brands', 'models', 'products'

  // Error states
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadBrands();
    loadAllProducts();
  }

  // ==================== BRANDS ====================
  
  // Load brands (filtered by service if serviceId provided)
  Future<void> loadBrands() async {
    isLoadingBrands.value = true;
    errorMessage.value = '';
    
    try {
      Query query = _firestore.collection('mobile_brands');
      
      // If serviceId is provided, filter brands by service
      if (serviceId != null && serviceId!.isNotEmpty) {
        query = query.where('serviceId', isEqualTo: serviceId);
      }
      
      final snapshot = await query.get();
      
      brands.value = snapshot.docs.map((doc) {
        return BrandModel.fromFirestore(doc);
      }).toList();
      
      print('📱 Loaded ${brands.length} brands');
      
      // Don't auto-select first brand - let user choose
      // This gives better UX as they can see all brands first
      
    } catch (e) {
      // print('❌ Error loading brands: $e');
      errorMessage.value = 'Failed to load brands';
      // Get.snackbar(
      //   'Error',
      //   'Failed to load brands. Please try again.',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoadingBrands.value = false;
    }
  }

  // ==================== MODELS ====================
  
  // Select brand and load its models
  Future<void> selectBrand(BrandModel brand) async {
    selectedBrand.value = brand;
    currentView.value = 'models';
    isLoadingModels.value = true;
    models.clear();
    products.clear(); // Clear previous products
    
    try {
      print('📱 Loading models for brand: ${brand.name} (${brand.id})');
      
      final snapshot = await _firestore
          .collection('models')
          .where('brandId', isEqualTo: brand.id)
          .get();
      
      models.value = snapshot.docs.map((doc) {
        return ModelModel.fromFirestore(doc);
      }).toList();
      
      print('📱 Loaded ${models.length} models');
      
      // Don't auto-select first model - let user choose
      selectedModel.value = null;
      
    } catch (e) {
      // print('❌ Error loading models: $e');
      // Get.snackbar(
      //   'Error',
      //   'Failed to load models for ${brand.name}',
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      // );
    } finally {
      isLoadingModels.value = false;
    }
  }

  // ==================== PRODUCTS ====================
  
  // Select model and load its products
  Future<void> selectModel(ModelModel model) async {
    selectedModel.value = model;
    currentView.value = 'products';
    isLoadingProducts.value = true;
    products.clear();
    
    try {
      print('📱 Loading products for model: ${model.name} (${model.id})');
      
      final snapshot = await _firestore
          .collection('products')
          .where('modelId', isEqualTo: model.id)
          .get();
      
      products.value = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc);
      }).toList();
      
      print('📱 Loaded ${products.length} products');
      
    } catch (e) {
      // print('❌ Error loading products: $e');
      Get.snackbar(
        'Error',
        'Failed to load products for ${model.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoadingProducts.value = false;
    }
  }

  // ==================== ALL PRODUCTS ====================
  
  // Load all products (for "All Products" section)
  Future<void> loadAllProducts() async {
    isLoadingAllProducts.value = true;
    
    try {
      final snapshot = await _firestore.collection('products').get();
      
      allProducts.value = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(doc);
      }).toList();
      
      print('📱 Loaded ${allProducts.length} total products');
      
    } catch (e) {
      print('❌ Error loading all products: $e');
    } finally {
      isLoadingAllProducts.value = false;
    }
  }

  // ==================== NAVIGATION ====================
  
  // Go back to brands view
  void backToBrands() {
    currentView.value = 'brands';
    selectedBrand.value = null;
    selectedModel.value = null;
    models.clear();
    products.clear();
  }

  // Go back to models view
  void backToModels() {
    if (selectedBrand.value != null) {
      currentView.value = 'models';
      selectedModel.value = null;
      products.clear();
    } else {
      backToBrands();
    }
  }

  // Select product and navigate to details
  void goToProductDetails(ProductModel product) {
    selectedProduct.value = product;
    Get.toNamed('/product-details', arguments: product);
  }

  // ==================== CART ====================
  
  // Add product to cart
  void addToCart(ProductModel product) {
    // TODO: Implement actual cart functionality
    // Get.snackbar(
    //   '✅ Added to Cart',
    //   '${product.name} added to cart',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 2),
    //   margin: const EdgeInsets.all(10),
    //   borderRadius: 8,
    //   icon: const Icon(Icons.shopping_cart, color: Colors.white),
    // );
  }

  // ==================== HELPER METHODS ====================
  
  // Get brand name by ID
  String getBrandName(String brandId) {
    try {
      // First check if it's in selected brand
      if (selectedBrand.value?.id == brandId) {
        return selectedBrand.value!.name;
      }
      
      // Then check in brands list
      final brand = brands.firstWhere(
        (b) => b.id == brandId,
        orElse: () => brands.isNotEmpty ? brands.first : BrandModel(id: '', name: 'Unknown', logo: ''),
      );
      return brand.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get model name by ID
  String getModelName(String modelId) {
    try {
      // First check if it's in selected model
      if (selectedModel.value?.id == modelId) {
        return selectedModel.value!.name;
      }
      
      // Then check in models list
      final model = models.firstWhere(
        (m) => m.id == modelId,
        orElse: () => models.isNotEmpty ? models.first : ModelModel(id: '', name: 'Unknown', brandId: '', imageUrl: ''),
      );
      return model.name;
    } catch (e) {
      return 'Unknown';
    }
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait([
      loadBrands(),
      loadAllProducts(),
    ]);
    
    // If we were in a specific view, reload that data too
    if (selectedBrand.value != null) {
      await selectBrand(selectedBrand.value!);
    }
    
    if (selectedModel.value != null) {
      await selectModel(selectedModel.value!);
    }
    
    // Get.snackbar(
    //   'Success',
    //   'Data refreshed',
    //   snackPosition: SnackPosition.BOTTOM,
    //   backgroundColor: Colors.green,
    //   colorText: Colors.white,
    //   duration: const Duration(seconds: 1),
    // );
  }

  // Reset everything
  void reset() {
    currentView.value = 'brands';
    selectedBrand.value = null;
    selectedModel.value = null;
    selectedProduct.value = null;
    models.clear();
    products.clear();
    errorMessage.value = '';
  }
}