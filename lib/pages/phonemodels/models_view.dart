import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/phonemodels/models_controller.dart';
import 'package:smartfixTech/pages/product_screen/product_view.dart';
// import 'package:smartfixTech/pages/home/navigation_pages/home/product/product_full_screen.dart';

class ModelsView extends StatefulWidget {
  final String brandId;
  final String brandName;
  // final String title;
  // final String orgprice;
  // final String cutPrice;
  // final String offer;
  final String imageUrl;
  final String serviceId;
  final String serviceTitle;
  final String avgRating;
  final String brandImage;

  const ModelsView({
    super.key,
    required this.avgRating,
    required this.brandId,
    required this.brandName,
    // required this.title,
    // required this.orgprice,
    // required this.cutPrice,
    // required this.offer,
    required this.imageUrl,
    required this.serviceId,
    required this.serviceTitle,
    required this.brandImage,
  });

  @override
  State<ModelsView> createState() => _ModelsViewState();
}

class _ModelsViewState extends State<ModelsView> {
  final ModelsController controller = Get.put(ModelsController());

  @override
  void initState() {
    super.initState();
    controller.fetchModels(widget.brandId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        backgroundColor: Colors.teal,
        title: Text('${widget.brandName} Models'),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.teal),
          );
        }

        if (controller.models.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_android_outlined,
                  size: 60,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No models found for ${widget.brandName}',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => controller.fetchModels(widget.brandId),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: controller.models.length,
          itemBuilder: (context, index) {
            // Get the Firestore document for this index
            final modelDoc = controller.models[index];
            final modelData = (modelDoc.data() as Map<String, dynamic>?) ?? {};
            final String modelId = modelDoc.id;
            final String modelName =
                modelData['name']?.toString() ?? 'Unknown Model';
            final String imageUrl = modelData['imageUrl']?.toString() ?? '';

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                log("serviceId333: ${widget.serviceId}");
                // Navigate to ProductFullScreen with all required arguments
                Get.to(
                  () => ProductFullScreen(),

                  arguments: {
                    'modelId': modelId, // ✅ modelId
                    'productImageUrl': widget.imageUrl,
                    'modelImageUrl': imageUrl, // ✅ model image
                    'brandImage': widget.brandImage,
                    'brandName': widget.brandName,
                    'modelName': modelName,
                    'avgRating': widget.avgRating,
                    // 'orgPrice': widget.orgprice,
                    // 'cutPrice': widget.cutPrice,
                    // 'offer': widget.offer,
                    'serviceId': widget.serviceId,
                    'serviceTitle': widget.serviceTitle,
                    'brandId': widget.brandId,
                  },
                  
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // ---------- MODEL IMAGE ----------
                    Hero(
                      tag: imageUrl.isNotEmpty ? imageUrl : 'models_$modelId',
                      child: Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      loadingProgress
                                                          .expectedTotalBytes!
                                                : null,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                  errorBuilder: (_, __, ___) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.phone_android,
                                        size: 36,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.phone_android,
                                    size: 36,
                                    color: Colors.grey,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // ---------- MODEL INFO ----------
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            modelName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),

                          // Display pricing if available
                          // _buildPriceDisplay(
                          //   widget.orgprice,
                          //   widget.cutPrice,
                          //   widget.offer,
                          // ),
                        ],
                      ),
                    ),

                    // ---------- NAVIGATION ARROW ----------
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  // Widget _buildPriceDisplay(
  //   // String originalPrice,
  //   // String discountedPrice,
  //   String offer,
  // ) {
  //   // final double? original = double.tryParse(originalPrice);
  //   // final double? discounted = double.tryParse(discountedPrice);

  //   if (discounted == null || discounted == 0) {
  //     return const Text(
  //       'Price on request',
  //       style: TextStyle(fontSize: 14, color: Colors.grey),
  //     );
  //   }

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Text(
  //             '₹${discounted.toStringAsFixed(0)}',
  //             style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.bold,
  //               color: Colors.green,
  //             ),
  //           ),
  //           if (original != null && original > discounted)
  //             Padding(
  //               padding: const EdgeInsets.only(left: 8),
  //               child: Text(
  //                 '₹${original.toStringAsFixed(0)}',
  //                 style: TextStyle(
  //                   fontSize: 13,
  //                   color: Colors.grey.shade600,
  //                   decoration: TextDecoration.lineThrough,
  //                 ),
  //               ),
  //             ),
  //         ],
  //       ),

  //       // Show offer if available
  //       if (offer != '0' && offer.isNotEmpty)
  //         Container(
  //           margin: const EdgeInsets.only(top: 4),
  //           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
  //           decoration: BoxDecoration(
  //             color: Colors.green.shade50,
  //             borderRadius: BorderRadius.circular(4),
  //             border: Border.all(color: Colors.green.shade100),
  //           ),
  //           child: Text(
  //             offer.endsWith('%') ? offer : '$offer% OFF',
  //             style: TextStyle(
  //               fontSize: 11,
  //               color: Colors.green.shade700,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //         ),
  //     ],
  //   );
  // }
}
