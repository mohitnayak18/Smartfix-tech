import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/cart/cart.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/store/store_controller.dart';

class StoreScreen extends StatefulWidget {
  final String? serviceId;
  final String? serviceName;
  const StoreScreen({super.key, this.serviceId, this.serviceName});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late final StoreController controller;
  final CartController cartCtrl = Get.put(CartController(), permanent: true);

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      StoreController(
        serviceId: widget.serviceId,
        serviceName: widget.serviceName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(cartCtrl),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingBrands.value && controller.brands.isEmpty) {
          return _buildInitialLoading();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshData,
          color: Colors.teal,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Show different views based on current state
                    _buildCurrentView(),

                    const SizedBox(height: 24),

                    // Always show "All Products" section at bottom
                    _buildAllProductsSection(),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ==================== APP BAR ====================

  Widget _buildAppBarTitle(CartController cartCtrl) {
    return Obx(() {
      final itemCount = cartCtrl.cartItems.length;

      return Row(
        children: [
          /// Store Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_outlined,
              size: 22,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 12),

          /// Store Text
          const Expanded(
            child: Text(
              "Store",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          /// 🛍 Shopping Bag With Badge + Navigation
          GestureDetector(
            onTap: () {
              Get.to(() => const CartView()); // 👈 Navigate here
            },
            child: Stack(
              
              alignment: Alignment.topRight,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 28,
                  color: Colors.white,
                ),

                if (itemCount > 0)
                  Positioned(
                    // height: -2,
                    right: -1,
                    // bottom: 1,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    });
  }

  // ==================== CURRENT VIEW ====================

  Widget _buildCurrentView() {
    switch (controller.currentView.value) {
      case 'models':
        return _buildModelsView();
      case 'products':
        return _buildProductsView();
      case 'brands':
      default:
        return _buildBrandsView();
    }
  }

  // ==================== BRANDS VIEW ====================

  Widget _buildBrandsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Select Brand",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Choose your mobile brand",
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 16),

        // Brands Grid
        Obx(() {
          if (controller.isLoadingBrands.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.brands.isEmpty) {
            return _buildEmptyState(
              icon: Icons.phonelink_off,
              message: "No brands available",
              subMessage: "Check back later",
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.brands.length,
            itemBuilder: (context, index) {
              final brand = controller.brands[index];
              return _buildBrandCard(brand);
            },
          );
        }),
      ],
    );
  }

  Widget _buildBrandCard(BrandModel brand) {
    return GestureDetector(
      onTap: () => controller.selectBrand(brand),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Brand Image
            SizedBox(
              height: 45,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: _buildBrandImage(brand.logo),
              ),
            ),
            // Brand Name
            Container(
              height: 28,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                brand.name,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandImage(String logo) {
    if (logo.isEmpty) {
      return const Icon(Icons.phone_android, size: 22, color: Colors.grey);
    }

    return CachedNetworkImage(
      imageUrl: logo,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          height: 14,
          width: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) =>
          const Icon(Icons.broken_image, size: 22, color: Colors.grey),
      fit: BoxFit.contain,
    );
  }

  // ==================== MODELS VIEW ====================

  Widget _buildModelsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Breadcrumb navigation
        _buildBreadcrumb(
          items: [
            BreadcrumbItem(label: 'Brands', onTap: controller.backToBrands),
            BreadcrumbItem(
              label: controller.selectedBrand.value?.name ?? 'Models',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Selected brand info
        if (controller.selectedBrand.value != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Row(
              children: [
                Container(
                  height: 32,
                  width: 32,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _buildBrandImage(controller.selectedBrand.value!.logo),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedBrand.value!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Select model',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Models Grid
        Obx(() {
          if (controller.isLoadingModels.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.models.isEmpty) {
            return _buildEmptyState(
              icon: Icons.device_unknown,
              message: "No models available",
              subMessage:
                  "for ${controller.selectedBrand.value?.name ?? 'this brand'}",
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.models.length,
            itemBuilder: (context, index) {
              final model = controller.models[index];
              return _buildModelCard(model);
            },
          );
        }),
      ],
    );
  }

  Widget _buildModelCard(ModelModel model) {
    return GestureDetector(
      onTap: () => controller.selectModel(model),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Model Image
            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: _buildModelImage(model.imageUrl),
              ),
            ),
            // Model Name
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(8),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    model.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'View',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.teal.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Center(
        child: Icon(Icons.phone_android, size: 28, color: Colors.grey.shade400),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => Center(
        child: Icon(Icons.broken_image, size: 28, color: Colors.grey.shade400),
      ),
      fit: BoxFit.contain,
    );
  }

  // ==================== PRODUCTS VIEW ====================

  Widget _buildProductsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Breadcrumb navigation
        _buildBreadcrumb(
          items: [
            BreadcrumbItem(label: 'Brands', onTap: controller.backToBrands),
            BreadcrumbItem(
              label: controller.selectedBrand.value?.name ?? 'Models',
              onTap: controller.backToModels,
            ),
            BreadcrumbItem(
              label: controller.selectedModel.value?.name ?? 'Products',
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Selected model info
        if (controller.selectedModel.value != null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.shade100),
            ),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _buildModelImage(
                    controller.selectedModel.value!.imageUrl,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.selectedModel.value!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${controller.products.length} products',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Products Grid
        Obx(() {
          if (controller.isLoadingProducts.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.products.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              message: "No products available",
              subMessage:
                  "for ${controller.selectedModel.value?.name ?? 'this model'}",
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.products.length,
            itemBuilder: (context, index) {
              final product = controller.products[index];
              return _buildProductCard(product);
            },
          );
        }),
      ],
    );
  }

  // ==================== ALL PRODUCTS SECTION ====================

  Widget _buildAllProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "All Products",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (controller.isLoadingAllProducts.value)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingAllProducts.value &&
              controller.allProducts.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.allProducts.isEmpty) {
            return _buildEmptyState(
              icon: Icons.inventory_2_outlined,
              message: "No products available",
              subMessage: "Check back later",
            );
          }

          return GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.58,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: controller.allProducts.length > 4
                ? 4
                : controller.allProducts.length,
            itemBuilder: (context, index) {
              final product = controller.allProducts[index];
              return _buildProductCard(product);
            },
          );
        }),

        if (controller.allProducts.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Get.toNamed(
                    '/all-products',
                    arguments: {
                      'serviceId': widget.serviceId,
                      'serviceName': widget.serviceName,
                    },
                  );
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View All ${controller.allProducts.length} Products',
                  style: TextStyle(fontSize: 12, color: Colors.teal.shade700),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ==================== PRODUCT CARD WITH ADD TO CART ====================

  Widget _buildProductCard(ProductModel product) {
    return GestureDetector(
      onTap: () => controller.goToProductDetails(product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 85,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: product.image.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: product.image,
                        placeholder: (context, url) => const Center(
                          child: SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            _buildNoImagePlaceholder(),
                        fit: BoxFit.contain,
                      )
                    : _buildNoImagePlaceholder(),
              ),
            ),

            // Product Details
            Container(
              height: 105,
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),

                  // Brand
                  Text(
                    controller.getBrandName(product.brandId),
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Price
                  _buildPrice(product),

                  const SizedBox(height: 6),

                  // Add to Cart Button - Using the cart logic
                  SizedBox(
                    width: double.infinity,
                    height: 20,
                    child: ElevatedButton(
                      onPressed: () => _addToCart(product),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        elevation: 0,
                        minimumSize: const Size(0, 20),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ADD TO CART LOGIC (from ProductFullScreen) ====================

  Future<void> _addToCart(ProductModel product) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Get brand and model names
      final brandName = controller.getBrandName(product.brandId);
      final modelName = controller.getModelName(product.modelId);

      // Get selected brand and model for additional info
      final selectedBrand = controller.selectedBrand.value;
      final selectedModel = controller.selectedModel.value;

      final cartRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('cart');

      // Check if product already exists in cart
      final querySnapshot = await cartRef
          .where('serviceId', isEqualTo: widget.serviceId ?? '')
          .where('brandId', isEqualTo: product.brandId)
          .where('modelId', isEqualTo: product.modelId)
          .where('productId', isEqualTo: product.id)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // _showSnackbar(
        //   "Already in cart",
        //   "${product.name} is already in your cart",
        //   Colors.orange,
        // );
        return;
      }

      // Add to cart using CartController
      await cartCtrl.addToCart({
        'serviceId': widget.serviceId ?? '',
        'productId': product.id,
        'title': product.name,
        'brand': brandName,
        'brandId': product.brandId,
        'model': modelName,
        'modelId': product.modelId,
        'price': product.finalPrice,
        'originalPrice': product.priceNum,
        'discountPrice': product.discountPriceNum,
        'image': product.image,
        'quantity': 1,
      });

      // _showSnackbar(
      //   "Added to Cart",
      //   "${product.name} added successfully",
      //   Colors.green,
      // );
    } on FirebaseException catch (e) {
      _showSnackbar("Error", e.message ?? "Something went wrong", Colors.red);
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
      margin: const EdgeInsets.all(8),
    );
  }

  Widget _buildPrice(ProductModel product) {
    if (product.hasDiscount) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${product.priceNum.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 9,
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  '${product.offerPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 7,
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            '₹${product.discountPriceNum.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      );
    }

    return Text(
      '₹${product.priceNum.toStringAsFixed(0)}',
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildInitialLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.teal),
          SizedBox(height: 12),
          Text(
            'Loading store...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? subMessage,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            if (subMessage != null)
              Text(
                subMessage,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported,
            size: 18,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 1),
          Text(
            'No Image',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 7),
          ),
        ],
      ),
    );
  }

  Widget _buildBreadcrumb({required List<BreadcrumbItem> items}) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (item.onTap != null)
                GestureDetector(
                  onTap: item.onTap,
                  child: _buildBreadcrumbText(item.label, isLast: item.isLast),
                )
              else
                _buildBreadcrumbText(item.label, isLast: item.isLast),

              if (index < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    Icons.chevron_right,
                    size: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBreadcrumbText(String label, {bool isLast = false}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: isLast ? FontWeight.w600 : FontWeight.normal,
        color: isLast ? Colors.teal : Colors.grey.shade700,
        decoration: !isLast ? TextDecoration.underline : null,
      ),
    );
  }
}

// Helper class for breadcrumb navigation
class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;
  final bool isLast;

  BreadcrumbItem({required this.label, this.onTap, this.isLast = false});
}
