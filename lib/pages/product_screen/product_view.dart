import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/api_calls/models/cart_model.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/cart/cart_view.dart';
import 'package:smartfixTech/pages/product_screen/product_controller.dart';
import 'package:smartfixTech/theme/dimens.dart';
// import 'package:smartfixTech/pages/product_scren/product_controller.dart';

class ProductFullScreen extends StatefulWidget {
  const ProductFullScreen({super.key});

  @override
  State<ProductFullScreen> createState() => _ProductFullScreenState();
}

class _ProductFullScreenState extends State<ProductFullScreen> {
  final CartController cartCtrl = Get.put(CartController(), permanent: true);
  final ProductController controller = Get.put(ProductController());
  final Map args = Get.arguments ?? {};

  String modelId = '';
  String brandName = '';
  String modelName = '';
  String orgPrice = '0';
  String cutPrice = '0';
  String offer = '0';
  String serviceImageUrl = '';
  String heroTag = '';
  String brandImage = '';
  String serviceId = '';
  String serviceTitle = '';
  // String avgRating = '0.0';
  String brandId = '';

  @override
  void initState() {
    super.initState();

    serviceImageUrl = args["productImageUrl"] ?? '';
    modelId = args["modelId"] ?? '';
    brandName = args["brandName"] ?? 'Brand';
    brandId = args["brandId"] ?? '';
    modelName = args["modelName"] ?? 'Model';
    // orgPrice = args["orgPrice"] ?? '0';
    // cutPrice = args["cutPrice"] ?? '0';
    // offer = args["offer"] ?? '0';
    brandImage = args["brandImage"] ?? '';
    serviceId = args["serviceId"] ?? '';
    serviceTitle = args["serviceTitle"] ?? 'service';
    // avgRating = args["avgRating"] ?? '0.0';
    heroTag = serviceImageUrl.isNotEmpty ? serviceImageUrl : 'hero_$modelId';

    // Initialize controller with parameters
    // controller.serviceId = serviceId;
    // controller.modelId = modelId;
    // controller.brandId = brandId;

    // Fetch products after a short delay to ensure controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchProducts(serviceId, modelId, brandId);
    });
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
      ),
      foregroundColor: Colors.white,
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

        // Image Container with shadow and border
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
                  Get.to(
                    () => FullScreenImageView(
                      imageUrl: serviceImageUrl,
                      heroTag: heroTag,
                      title: serviceTitle,
                    ),
                  );
                },
                child: Container(
                  color: Colors.white,
                  child: Hero(
                    tag: heroTag,
                    child: Center(
                      child: Stack(
                        children: [
                          // Main Image
                          _safeImage(serviceImageUrl, size: 240),

                          // Zoom icon overlay
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

        // Floating brand badge
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
      return Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_iphone, size: 80, color: Colors.teal),
            Dimens.boxHeight10,
            // SizedBox(height: 10),
            Text(
              'Product Image',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
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
      },
      errorBuilder: (_, __, ___) => Container(
        width: 240,
        height: 240,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 80, color: Colors.grey),
            Dimens.boxHeight10,
            Text('Image not available', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _titleSection() {
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
            child: Image.network(
              brandImage,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.image_not_supported, size: 24),
            ),
          ),
          Dimens.boxWidth10,
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  modelName,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Dimens.boxHeight2,
                Text(
                  serviceTitle.toUpperCase(),
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
  }

  Widget _priceSection() {
    return Obx(() {
      final products = controller.products;
      final product = products.isNotEmpty ? products.first : null;

      final price = product?['price']?.toString() ?? '0';
      final discountPrice = product?['discountPrice']?.toString() ?? price;

      // Calculate offer percentage
      double priceNum = double.tryParse(price) ?? 0;
      double discountPriceNum = double.tryParse(discountPrice) ?? priceNum;
      int offerPercentage = 0;

      if (priceNum > 0 && discountPriceNum < priceNum) {
        offerPercentage = (((priceNum - discountPriceNum) / priceNum) * 100)
            .round();
      }

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
          final product = products.isNotEmpty ? products.first.data() : null;
          final ratingText = product?['rating']?.toString() ?? '0.0';
          final ratingValue = double.tryParse(ratingText) ?? 0.0;

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Rating number
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

              // Right side - Stars
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
        children:  [
          Text(
            "Available Offers",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Dimens.boxWidth8,
          Text("• Bank Offer: 5% Cashback"),
          Text("• No Cost EMI Available"),
          Text("• Special Price Offer"),
        ],
      ),
    );
  }

  Widget _highlightsSection() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          Text("Highlights", style: TextStyle(fontWeight: FontWeight.bold)),
          Dimens.boxHeight8,
          Text("• Doorstep Repair"),
          Text("• Repair in 45 Minutes"),
          Text("• 6 Months Warranty"),
          Text("• Genuine Parts"),
        ],
      ),
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
      final product = products.isNotEmpty ? products.first : null;
      final discountPrice = product?['discountPrice']?.toString() ?? '0';

      return Container(
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          boxShadow: [BoxShadow(color: Colors.teal.shade200, blurRadius: 2000)],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Dimens.boxHeight5,
                  Text(
                    "₹$discountPrice",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // const SizedBox(height: 2),
                   Text(
                    "all taxes".tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(255, 161, 160, 160),
                    ),
                  ),
                ],
              ),
            ),
            // const SizedBox(width: 1),
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
                onPressed: () {
                  cartCtrl.addToCart({
                    'productId': serviceId, // ✅ use serviceId
                    'title': serviceTitle,
                    'brand': brandName, // ✅ from args
                    'model': modelName, // ✅ from args
                    'price':
                        double.tryParse(
                          product?['discountPrice']?.toString() ?? '0',
                        ) ??
                        0,
                    'image': serviceImageUrl,
                    'quantity': 1,
                  });
                },

                // child: const Text(
                //   "ADD SERVICE",
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     color: Colors.white,
                //   ),
                // ),
              ),
            ),
          ],
        ),
      );
    });
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
            minScale: 1,
            maxScale: 4,
            child: Image.network(
              imageUrl,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image,
                color: Colors.white,
                size: 100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// class SplashView extends StatefulWidget {
//   const SplashView({super.key});

//   @override
//   State<SplashView> createState() => _SplashViewState();
// }

// class _SplashViewState extends State<SplashView> {
//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) => GetBuilder<SplashController>(
//     builder: (controller) {
//       return Scaffold(
//         resizeToAvoidBottomInset: false,
//         backgroundColor: Theme.of(context).primaryColor,
//         body: SafeArea(
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Builder(
//                   builder: (_) {
                    
//                     final asset = AssetConstants.splashLogo;
//                     if (asset.toLowerCase().endsWith('.svg')) {
//                       return SvgPicture.asset(
//                         asset,
//                         width: Dimens.hundredTwenty,
//                         height: Dimens.hundredTwenty,
//                       );
//                     }
//                     return Image.asset(
//                       asset,
//                       width: Dimens.hundredTwenty,
//                       height: Dimens.hundredTwenty,
//                       fit: BoxFit.contain,
//                     );
//                   },
//                 ),
//                 Dimens.boxHeight20,
//                 Text(
//                   'smartfixnm'.tr,
//                   style: TextStyle(
//                     fontSize: Dimens.twentyEight,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white70,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }


