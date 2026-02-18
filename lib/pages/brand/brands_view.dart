import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/brand/brands_controller.dart';
import 'package:smartfixTech/pages/phonemodels/models_view.dart';

class BrandsView extends StatelessWidget {
  BrandsView({
    super.key,
    required this.serviceId,
    //  this.title,
    // required this.orgprice,
    // required this.cutPrice,
    // required this.offer,
    required this.imageUrl,
    this.brandImage = '',
    required this.serviceTitle,
  });

  // final String title;
  // final String orgprice;
  // final String cutPrice;
  // final String offer;
  final String imageUrl;
  final String serviceId;
  final String brandImage;
  final String serviceTitle;

  /// ✅ Inject controller ONCE with productId
  final BrandsController controller = Get.put(
    BrandsController(),
    permanent: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Brand'),
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.brands.isEmpty) {
          return const Center(
            child: Text('No brands available', style: TextStyle(fontSize: 16)),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.brands.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final data = controller.brands[index];

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                log("serviceId22:$serviceId");
                Get.to(
                  () => ModelsView(
                    serviceId: serviceId,
                    serviceTitle: serviceTitle,
                    // title: title,
                    // orgprice: orgprice,
                    // cutPrice: cutPrice,
                    // offer: offer,
                    avgRating: data['rating'] ?? 0,
                    imageUrl: imageUrl,
                    brandId: data['id'],
                    brandName: data['name'],
                    brandImage: data['logo'] ?? '',
                  ),
                  transition: Transition.rightToLeft,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /// BRAND LOGO
                    Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          data['logo'] ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.phone_android,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// BRAND NAME
                    Text(
                      data['name'] ?? '',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
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
}
