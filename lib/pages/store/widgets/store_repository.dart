import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartfixapp/api_calls/models/brand_model.dart';
import 'package:smartfixapp/api_calls/models/product_model.dart';

class StoreRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references based on your screenshots
  CollectionReference get brandsCollection => _firestore.collection('models');
  CollectionReference get productsCollection => _firestore.collection('products');
  
  // Debug logging method
  void _log(String emoji, String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    print('$emoji [$timestamp] $message');
  }

  // Get all brands (from 'models' collection)
  Future<List<BrandModel>> getBrands() async {
    _log('🚀', '========== getBrands() ==========');
    _log('📂', 'Collection: models');
    
    try {
      _log('📡', 'Querying models collection...');
      
      final querySnapshot = await brandsCollection.get();
      
      _log('✅', 'Query successful!');
      _log('📊', 'Found ${querySnapshot.docs.length} brand(s)');
      
      // Log each brand
      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        _log('📄', 'Brand Document: ${doc.id}');
        _log('   ', '  ID: ${data['id']}');
        _log('   ', '  Name: ${data['name']}');
        _log('   ', '  Logo URL: ${data['logo']}');
        _log('   ', '  All fields: ${data.keys.toList()}');
      }

      final brands = querySnapshot.docs
          .map((doc) {
            try {
              return BrandModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
            } catch (e) {
              _log('⚠️', 'Error converting ${doc.id}: $e');
              return null;
            }
          })
          .where((brand) => brand != null)
          .cast<BrandModel>()
          .toList();

      _log('✅', 'Successfully created ${brands.length} BrandModel(s)');
      _log('🏁', '========== getBrands() COMPLETED ==========');
      
      return brands;
    } catch (e, stackTrace) {
      _log('❌', 'ERROR in getBrands(): $e');
      _log('   ', 'Stack Trace: $stackTrace');
      return [];
    }
  }

  // Get products by brand ID
  Future<List<ProductModel>> getProductsByBrand(String brandId) async {
    _log('🚀', '========== getProductsByBrand() ==========');
    _log('🎯', 'Brand ID: $brandId');
    _log('📂', 'Collection: products');
    
    try {
      _log('📡', 'Querying products where brandId == "$brandId"...');
      
      final querySnapshot = await productsCollection
          .where('id', isEqualTo: brandId)
          .get();

      _log('✅', 'Query successful!');
      _log('📊', 'Found ${querySnapshot.docs.length} product(s) for brand $brandId');
      
      final products = <ProductModel>[];
      for (var doc in querySnapshot.docs) {
        try {
          final product = _convertToProductModel(doc);
          if (product != null) {
            products.add(product);
            _log('📦', 'Added product: ${product.title}');
            _log('   ', '  Image URL: ${product.imageUrl}');
          }
        } catch (e) {
          _log('⚠️', 'Error converting product ${doc.id}: $e');
        }
      }

      _log('✅', 'Successfully created ${products.length} ProductModel(s)');
      _log('🏁', '========== getProductsByBrand() COMPLETED ==========');
      
      return products;
    } catch (e, stackTrace) {
      _log('❌', 'ERROR in getProductsByBrand(): $e');
      _log('   ', 'Stack Trace: $stackTrace');
      return [];
    }
  }

  // Get all products
  Future<List<ProductModel>> getAllProducts() async {
    _log('🚀', '========== getAllProducts() ==========');
    _log('📂', 'Collection: products');
    
    try {
      _log('📡', 'Querying all products...');
      
      final querySnapshot = await productsCollection.get();
      
      _log('✅', 'Query successful!');
      _log('📊', 'Found ${querySnapshot.docs.length} product(s) total');
      
      final products = <ProductModel>[];
      for (var doc in querySnapshot.docs) {
        try {
          final product = _convertToProductModel(doc);
          if (product != null) {
            products.add(product);
          }
        } catch (e) {
          _log('⚠️', 'Error converting ${doc.id}: $e');
        }
      }

      _log('✅', 'Successfully created ${products.length} ProductModel(s)');
      _log('🏁', '========== getAllProducts() COMPLETED ==========');
      
      return products;
    } catch (e, stackTrace) {
      _log('❌', 'ERROR in getAllProducts(): $e');
      _log('   ', 'Stack Trace: $stackTrace');
      return [];
    }
  }

  // Helper method to convert Firestore document to ProductModel
  ProductModel? _convertToProductModel(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      
      // DEBUG: Print all fields
      print('🔍 [DEBUG] Product ${doc.id} fields:');
      data.forEach((key, value) {
        print('   $key: $value');
      });
      
      // Handle image field - check multiple possible names
      String? imageUrl;
      if (data.containsKey('img@clr1')) {
        imageUrl = data['img@clr1']?.toString();
        print('✅ Found image in img@clr1: $imageUrl');
      } else if (data.containsKey('imageUrl')) {
        imageUrl = data['imageUrl']?.toString();
        print('✅ Found image in imageUrl: $imageUrl');
      } else if (data.containsKey('img')) {
        imageUrl = data['img']?.toString();
        print('✅ Found image in img: $imageUrl');
      } else {
        print('⚠️ No image field found. Available fields: ${data.keys}');
      }
      
      // Validate URL
      if (imageUrl != null && imageUrl.isNotEmpty) {
        if (!imageUrl.startsWith('http')) {
          print('⚠️ Image URL doesn\'t start with http: $imageUrl');
        }
      } else {
        print('⚠️ Empty or null image URL');
      }
      
      return ProductModel(
        id: doc.id,
        title: data['name']?.toString() ?? 'No Name',
        price: _parsePrice(data['originalprice']),
        imageUrl: imageUrl ?? '',
        brandId: data['id']?.toString() ?? '',
        isAvailable: data['isAvailable']?.toString().toLowerCase() == 'true',
        cutOfferPrice: _parsePrice(data['cutofferprice']),
        offerPercentage: _parseInt(data['offerpercentage']),
      );
    } catch (e) {
      print('❌ Error in _convertToProductModel: $e');
      return null;
    }
  }

  int _parsePrice(dynamic price) {
    if (price == null) return 0;
    if (price is int) return price;
    if (price is double) return price.toInt();
    if (price is String) {
      return int.tryParse(price) ?? 0;
    }
    return 0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int min(int a, int b) => a < b ? a : b;

  // ... rest of your methods (searchProducts, getFeaturedProducts, debugFirestoreData)
}