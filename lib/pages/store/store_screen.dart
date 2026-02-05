import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/models/product_model.dart';
import 'package:smartfixapp/pages/store/store_controller.dart';

const _appBarTitleStyle = TextStyle(
  fontSize: 23,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  letterSpacing: 0.5,
);

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late StoreController storeController;

  @override
  void initState() {
    super.initState();
    // Initialize controller
    if (Get.isRegistered<StoreController>()) {
      storeController = Get.find<StoreController>();
    } else {
      storeController = Get.put(StoreController());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      // AppBar(
      //   // automaticallyImplyLeading: true,
      //   toolbarHeight: 33,
      //   // toolbarHeight: 80,
      //   backgroundColor: Theme.of(context).primaryColor,
      //   title: Text("Store"),
      //   titleTextStyle: TextStyle(
      //     height: 0.8,
      //     fontWeight: FontWeight.bold,
      //     fontSize: 18,
      //   ),

      //   // leading: IconButton(
      //   //   onPressed: Get.back,
      //   //   icon: Icon(
      //   //     Icons.adaptive.arrow_back,
      //   //     color: Colors.white,
      //   //   ),
      //   // ),
      // ),
      // AppBar(
      //   // toolbarHeight: 20,
      //   // leading: IconButton(
      //   //   onPressed: () => {Get.back()},
      //   //   icon: const Icon(Icons.arrow_back, color: Colors.white),
      //   // ),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   // centerTitle: true,
      //   title: Column(
      //     // crossAxisAlignment: CrossAxisAlignment.end,
      //     children: [
      //       Text(
      //         'Store',
      //         style: TextStyle(
      //           color: Colors.white,
      //           fontWeight: FontWeight.bold,
      //           fontSize: 18,
      //           height: 1.5,
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      body: Obx(() {
        if (storeController.isLoading.value && storeController.brands.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Loading store...'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ MOBILE BRANDS ------------------
              const Text(
                "Mobile Brands",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Brands Horizontal List - FIXED: Constrained height
              SizedBox(
                height: 120, // Fixed height
                child: storeController.brands.isEmpty
                    ? const Center(
                        child: Text(
                          "No brands available",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: storeController.brands.length,
                        itemBuilder: (context, index) {
                          final brand = storeController.brands[index];
                          bool isSelected =
                              storeController.selectedBrandId.value == brand.id;

                          return Container(
                            width: 90, // Fixed width
                            margin: EdgeInsets.only(
                              right: 12,
                              left: index == 0 ? 0 : 0,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                storeController.loadProductsByBrand(brand.id);
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 60,
                                    width: 60,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.teal.shade100
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.teal
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: brand.imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: brand.imageUrl,
                                            placeholder: (context, url) =>
                                                const CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(
                                                      Icons.business,
                                                      size: 24,
                                                    ),
                                            fit: BoxFit.contain,
                                          )
                                        : const Icon(Icons.business, size: 24),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    brand.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? Colors.teal
                                          : Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 30),

              // ------------------ BRAND-WISE PRODUCTS ------------------
              Obx(() {
                final brandName =
                    storeController.selectedBrandId.value.isNotEmpty
                    ? storeController.brands
                          .firstWhere(
                            (b) =>
                                b.id == storeController.selectedBrandId.value,
                            orElse: () =>
                                storeController.brands.firstOrNull ??
                                storeController.brands.first,
                          )
                          .name
                    : "Select a brand";

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Products ($brandName)",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                );
              }),

              // Products Grid - FIXED: Using ConstrainedBox to prevent overflow
              Obx(() {
                final products = storeController.filteredProducts;
                if (products.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products for this brand",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _calculateGridHeight(products.length),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75, // Adjusted ratio
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              }),

              const SizedBox(height: 30),

              // ------------------ ALL PRODUCTS ------------------
              const Text(
                "All Products",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // All Products Grid
              Obx(() {
                final allProducts = storeController.allProducts;
                if (allProducts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No products available",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: _calculateGridHeight(allProducts.length),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: allProducts.length,
                    itemBuilder: (context, index) {
                      final product = allProducts[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  // Helper to calculate grid height dynamically
  double _calculateGridHeight(int itemCount) {
    const double itemHeight = 180; // Approximate height of each card
    const double spacing = 12;
    const int crossAxisCount = 2;

    int rows = (itemCount / crossAxisCount).ceil();
    return (rows * itemHeight) + ((rows - 1) * spacing);
  }

  // AppBar _appBar() {

  //   return AppBar(

  //     backgroundColor: Colors.teal,

  //     title: const Text("Product Details"),
  //     toolbarHeight: 80,
  //     iconTheme: const IconThemeData(color: Colors.white),
  //     titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //     foregroundColor: Colors.white,
  //   );
  // }

  Widget _buildProductCard(ProductModel product) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image Section
          _buildProductImage(product),

          // Product Details Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Product Name
                  _buildProductTitle(product.title),

                  const SizedBox(height: 4),

                  // Price Section
                  _buildPriceSection(product),

                  // Add to Cart Button
                  _buildAddToCartButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Image widget extracted for better organization
  Widget _buildProductImage(ProductModel product) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(889)),
        color: const Color.fromARGB(255, 247, 245, 245),
      ),
      child: product.imageUrl.isNotEmpty
          ? _buildNetworkImage(product.imageUrl)
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) => _buildLoadingIndicator(),
        errorWidget: (context, url, error) => _buildErrorImage(),
        fit: BoxFit.contain,
        width: double.infinity,
        height: 90,
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
    );
  }

  Widget _buildPlaceholderImage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_bag, size: 30, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'No Image',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorImage() {
    return _buildPlaceholderImage(); // Reuse same widget for consistency
  }

  // Product title widget
  Widget _buildProductTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  // Price section widget
  Widget _buildPriceSection(ProductModel product) {
    final hasDiscount = product.offerPercentage > 0;

    return hasDiscount
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   '₹${product.price}',
              //   style: const TextStyle(
              //     fontSize: 12,
              //     decoration: TextDecoration.lineThrough,
              //     color: Colors.grey,
              //   ),
              // ),
              // const SizedBox(height: 2),
              Text(
                '₹${product.cutOfferPrice}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          )
        : Text(
            '₹${product.price}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      // actions: [_buildClearCartButton(cartCtrl)],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.storefront_outlined,
            size: 22,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        const Text("Store", style: _appBarTitleStyle),
      ],
    );
  }

  // Add to cart button widget
  Widget _buildAddToCartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Implement add to cart functionality
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
          visualDensity: VisualDensity.compact,
        ),
        child: const Text(
          'Add to Cart',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
