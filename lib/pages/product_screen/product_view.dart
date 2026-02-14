import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/product_screen/product_controller.dart';
import 'package:smartfixTech/theme/dimens.dart';

class ProductFullScreen extends StatefulWidget {
  final String? name;
  const ProductFullScreen({super.key, this.name});

  @override
  State<ProductFullScreen> createState() => _ProductFullScreenState();
}

class _ProductFullScreenState extends State<ProductFullScreen> {
  // Rx variable for selected service
  late final RxString selectedServiceId;

  final CartController cartCtrl = Get.put(CartController(), permanent: true);
  final ProductController controller = Get.put(ProductController());

  final Map args = Get.arguments ?? {};

  // Initialize with proper types
  String modelId = '';
  String brandName = '';
  String modelName = '';
  String orgPrice = '';
  String cutPrice = '';
  String offer = '';
  String serviceImageUrl = '';
  String heroTag = '';
  String brandImage = '';
  String serviceTitle = '';
  String cartId = '';
  String brandId = '';
  String productId = ''; // Add this

  @override
  void initState() {
    super.initState();

    // Initialize all variables
    _initializeArgs();

    // Initialize Rx after args are set - use serviceId from args
    selectedServiceId = RxString(args["serviceId"] ?? args["id"] ?? '');

    // Add listener to debug changes
    ever(selectedServiceId, (value) {
      log("Selected service changed to: $value");
    });

    // Fetch products after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (selectedServiceId.value.isNotEmpty &&
          modelId.isNotEmpty &&
          brandId.isNotEmpty) {
        controller.fetchProducts(selectedServiceId.value, modelId, brandId);
      }
    });
  }

  void _initializeArgs() {
    serviceImageUrl = args["productImageUrl"] ?? '';
    modelId = args["modelId"] ?? '';
    log('model:$modelId');
    brandName = args["brandName"] ?? 'Brand';
    brandId = args["brandId"] ?? '';
    log(brandId);
    modelName = args["modelName"] ?? 'Model';
    brandImage = args["brandImage"] ?? '';
    serviceTitle = args["serviceTitle"] ?? 'service';
    productId = args["id"] ?? ''; // Get the product document ID
    cartId = args["cartId"] ?? args["serviceId"] ?? args["id"] ?? '';
    heroTag = serviceImageUrl.isNotEmpty ? serviceImageUrl : 'hero_$modelId';

    // Initialize price-related fields
    orgPrice = args["orgPrice"] ?? '0';
    cutPrice = args["cutPrice"] ?? '0';
    offer = args["offer"] ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      bottomNavigationBar: _bottomBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _imageSection(),
            _titleSection(),
            _priceSection(),
            _ratingSection(),
            _offersSection(),
            _qualityCheckSection(),
            _highlightsSection(),
            _descriptionSection(),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.teal,
      title: const Text("Product Details"),
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _imageSection() {
    return Stack(
      children: [
        Container(
          height: 350,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.teal.withOpacity(0.1),
                Colors.teal.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.teal.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: GestureDetector(
                onTap: () {
                  if (serviceImageUrl.isNotEmpty) {
                    Get.to(
                      () => FullScreenImageView(
                        imageUrl: serviceImageUrl,
                        heroTag: heroTag,
                        title: serviceTitle,
                      ),
                    );
                  }
                },
                child: Container(
                  color: Colors.white,
                  child: Hero(
                    tag: heroTag,
                    child: Center(
                      child: Stack(
                        children: [
                          _safeImage(serviceImageUrl, size: 240),
                          if (serviceImageUrl.isNotEmpty)
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (brandImage.isNotEmpty)
          Positioned(
            top: 160,
            left: 30,
            child: Container(
              width: 70,
              height: 70,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  brandImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.branding_watermark,
                    size: 30,
                    color: Colors.teal,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _safeImage(String url, {double size = 70}) {
    if (url.isEmpty) {
      return _buildPlaceholderImage(size);
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildLoadingIndicator(loadingProgress);
      },
      errorBuilder: (_, __, ___) => _buildErrorImage(),
    );
  }

  Widget _buildPlaceholderImage(double size) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_iphone, size: 80, color: Colors.teal),
          Dimens.boxHeight10,
          Text(
            'Product Image',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
          color: Colors.teal,
        ),
      ),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      width: 240,
      height: 240,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 80, color: Colors.grey),
          Dimens.boxHeight10,
          Text('Image not available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _titleSection() {
    return Obx(() {
      final products = controller.products;
      final product = products.firstWhereOrNull(
        (p) =>
            p['serviceId'] == selectedServiceId.value ||
            p['id'] == selectedServiceId.value,
      );

      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 45,
              width: 45,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: brandImage.isNotEmpty
                  ? Image.network(
                      brandImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image_not_supported, size: 24),
                    )
                  : const Icon(Icons.branding_watermark, size: 24),
            ),
            Dimens.boxWidth10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    modelName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Dimens.boxHeight2,
                  Text(
                    product?['name']?.toLowerCase() ??
                        serviceTitle.toLowerCase(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _priceSection() {
    return Obx(() {
      final products = controller.products;
      final product = products.firstWhereOrNull(
        (p) =>
            p['serviceId'] == selectedServiceId.value ||
            p['id'] == selectedServiceId.value,
      );

      final price = product?['price']?.toString() ?? '0';
      final discountPrice = product?['discountPrice']?.toString() ?? price;

      // Calculate offer percentage
      final priceNum = double.tryParse(price) ?? 0;
      final discountPriceNum = double.tryParse(discountPrice) ?? priceNum;
      final offerPercentage = priceNum > 0 && discountPriceNum < priceNum
          ? ((priceNum - discountPriceNum) / priceNum * 100).round()
          : 0;

      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(
              "₹$discountPrice",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            Dimens.boxWidth8,
            if (price != discountPrice)
              Text(
                "₹$price",
                style: const TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
            Dimens.boxWidth8,
            if (offerPercentage > 0)
              Text(
                "$offerPercentage% OFF",
                style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _ratingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.teal.withOpacity(0.1)),
        ),
        child: Obx(() {
          final products = controller.products;
          final product = products.firstWhereOrNull(
            (p) =>
                p['serviceId'] == selectedServiceId.value ||
                p['id'] == selectedServiceId.value,
          );

          final ratingText = product?['rating']?.toString() ?? '0.0';
          final ratingValue = double.tryParse(ratingText) ?? 0.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rating',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Dimens.boxHeight4,
                  Text(
                    ratingText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                      color: Colors.teal,
                    ),
                  ),
                  Text(
                    'out of 5',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RatingBar.builder(
                    initialRating: ratingValue,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 28,
                    ignoreGestures: true,
                    unratedColor: Colors.grey.shade300,
                    itemPadding: const EdgeInsets.only(right: 4),
                    itemBuilder: (context, _) =>
                        const Icon(Icons.star_rounded, color: Colors.amber),
                    onRatingUpdate: (rating) {},
                  ),
                  Dimens.boxHeight8,
                  Text(
                    'Based on customer reviews',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _offersSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Available Offers",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Dimens.boxWidth8,
          const Text("• Bank Offer: 5% Cashback"),
          const Text("• No Cost EMI Available"),
          const Text("• Special Price Offer"),
        ],
      ),
    );
  }

  Widget _qualityCheckSection() {
    return Obx(() {
      final products = controller.products;

      if (products.isEmpty) {
        return const SizedBox();
      }

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                "Select you want",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal.shade800,
                ),
              ),
            ),
            Dimens.boxHeight8,
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final item = products[index];
                  // Use serviceId if available, otherwise use id
                  final serviceId = item['id'] ?? '';
                  final isSelected = selectedServiceId.value == serviceId;

                  return GestureDetector(
                    onTap: () {
                      log("Tapped on service: $serviceId");
                      // Update the selected service ID
                      selectedServiceId.value = serviceId;

                      Get.snackbar(
                        "Selected",
                        "${item['name']} selected",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.teal,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.teal
                              : Colors.grey.shade200,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? Colors.teal.withOpacity(0.2)
                                : Colors.grey.shade100,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                item['image'] ?? serviceImageUrl,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image, size: 40),
                              ),
                            ),
                            Text(
                              item['name'] ?? 'Service',
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Dimens.boxHeight4,
                            Text(
                              "₹${item['discountPrice']?.toString() ?? item['price']?.toString() ?? '0'}",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.teal
                                    : Colors.grey.shade700,
                              ),
                            ),
                            if (isSelected)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Colors.teal,
                                  size: 16,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  // Updated Highlights Section with Firebase integration
  Widget _highlightsSection() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('products')
          .doc(modelId)
          .collection('services')
          .doc(selectedServiceId.value)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        List<String> highlights = [];
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data != null && data.containsKey('highlights')) {
            highlights = List<String>.from(data['highlights'] ?? []);
          }
        }

        // If no highlights in Firebase, show default ones
        if (highlights.isEmpty) {
          highlights = [
            "Doorstep Repair",
            "Repair in 45 Minutes",
            "6 Months Warranty",
            "Genuine Parts",
          ];
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Highlights",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  // Optional: Add admin controls here
                ],
              ),
              Dimens.boxHeight8,
              ...highlights
                  .map(
                    (highlight) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.teal,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "• $highlight",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _descriptionSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        "Professional $brandName $modelName repair service with warranty.",
      ),
    );
  }

  Widget _bottomBar() {
    return Obx(() {
      final products = controller.products;
      final product = products.firstWhereOrNull(
        (p) =>
            p['serviceId'] == selectedServiceId.value ||
            p['id'] == selectedServiceId.value,
      );

      final discountPrice = product?['discountPrice']?.toString() ?? '0';

      return Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          boxShadow: [
            BoxShadow(
              color: Colors.teal.shade200.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "₹$discountPrice",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "all taxes".tr,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              width: 150,
              child: ElevatedButton.icon(
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  "ADD to cart",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: _addToCart,
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _addToCart() async {
    log('brand:$brandId');
    try {
      final user = FirebaseAuth.instance.currentUser;
      // if (user == null) {
      //   _showSnackbar(
      //     "Login required",
      //     "Please login to add items to cart",
      //     Colors.orange,
      //   );
      //   return;
      // }

      final product = controller.products.firstWhereOrNull(
        (p) =>
            p['serviceId'] == selectedServiceId.value ||
            p['id'] == selectedServiceId.value,
      );

      // if (product == null) {
      //   _showSnackbar("Error", "Product not found", Colors.red);
      //   return;
      // }

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('cart');

      // Check if product already exists in cart
      final querySnapshot = await cartRef
          .where('serviceId', isEqualTo: selectedServiceId.value)
          .where('brandId', isEqualTo: brandId)
          .where('modelId', isEqualTo: modelId)
          // .limit(1)
          .get();

     
      log(querySnapshot.docs.toString());
      if (querySnapshot.docs.isNotEmpty) {
    
        _showSnackbar(
          "Already in cart",
          "$serviceTitle is already in your cart",
          Colors.orange,
        );
        return;
      }
      // log(modelId);
      // log(brandId);
      // Add to cart
      await cartCtrl.addToCart({
        'serviceId': selectedServiceId.value,
        // 'productId': product?['id'] ?? '',
        'title': product?['name'] ?? serviceTitle,
        'brand': brandName,
        'model': modelName,
        'modelId': modelId,
        'brandId': brandId,
        'price':
            double.tryParse(product?['discountPrice']?.toString() ?? '0') ?? 0,
        'image': product?['image'] ?? serviceImageUrl,
        'quantity': 1,
      });

      _showSnackbar("Added", "Item added to cart successfully", Colors.green);
    } on FirebaseException catch (e) {
      _showSnackbar(
        "Firebase Error",
        e.message ?? "Something went wrong",
        Colors.red,
      );
    } catch (e) {
      _showSnackbar("Error", e.toString(), Colors.red);
    }
  }

  void _showSnackbar(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;
  final String heroTag;
  final String title;

  const FullScreenImageView({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(title, style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) => const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.white, size: 100),
                  SizedBox(height: 16),
                ],
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
