import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartfixTech/pages/home/navigation_pages/home/product/product_vertical.dart';

class Gridlayout extends StatelessWidget {
  const Gridlayout({super.key, required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final data = docs[index].data();

        return ProductcardVertical(
          id: docs[index].id, // ✅ Correct Firestore doc ID
          title: data['name'] ?? 'No name',
           offer: data['offerto']?.toString() ?? '0',
           price:data['priceto']?.toString() ?? '0',
          // cutPrice: data['cutofferprice']?.toString() ?? '0',
          // orgprice: data['originalprice']?.toString() ?? '0',
          imageUrl: data['imageUrl'] ?? '',
        );
      },
    );
  }
}
