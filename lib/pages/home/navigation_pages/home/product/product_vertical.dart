import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixapp/api_calls/models/shadowstyle.dart';
import 'package:smartfixapp/pages/brands/brands_view.dart';
import 'package:smartfixapp/pages/home/navigation_pages/images/rounded.dart';

class ProductcardVertical extends StatelessWidget {
  const ProductcardVertical({
    super.key,
    required this.id,
    required this.title,
    required this.price,
    // required this.orgprice,
    // required this.cutPrice,
    required this.offer,
    required this.imageUrl,
    this.isVerified = true,
    // required this.brandId,
    // required this.productTitle,
    // required this.title,
  });

  final String id;
  final String title;
  final String price;
  // final String orgprice;
  // final String cutPrice;
  final String offer;
  final String imageUrl;
  final bool isVerified;
  // final String brandId;
  // final String productTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.orange.withOpacity(0.15),
        onTap: () {
          log("serviceId:$id");
          Get.to(
            () => BrandsView(
              // brandId: id,
              // productTitle: productTitle,
              serviceId: id,
              serviceTitle: title,
              // offer: offer,
              // cutPrice: cutPrice,
              // orgprice: orgprice,
              imageUrl: imageUrl,
            ),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 300),
          );
        },
        child: Container(
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 180,
            minHeight: 200,
            maxHeight: 220,
          ),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [Shadowstyle.verticalProductShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// OFFER BADGE
              if (offer.isNotEmpty && offer != '0')
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$offer% OFF',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

              /// IMAGE
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: Colors.grey.shade50,
                    padding: const EdgeInsets.all(8),
                    child: Center(
                      child: Hero(
                        tag: 'product-$id', // ✅ UNIQUE TAG
                        child: Roundedimage(
                          height: 80,
                          width: 80,
                          imageUrl: imageUrl,
                          applyImageRadius: true,
                          isNetworkImage: true,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// TITLE + VERIFIED
              Row(
                children: [
                  if (isVerified)
                    Icon(Icons.verified, size: 16, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              /// SUBTITLE
              Text(
                'Trusted & professional service',
                style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              /// PRICE
              Row(
                children: [
                  Text(
                    '₹$price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                  // const SizedBox(width: 8),
                  // Text(
                  //   '₹$orgprice',
                  //   style: TextStyle(
                  //     fontSize: 12,
                  //     color: Colors.grey.shade600,
                  //     decoration: TextDecoration.lineThrough,
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
