import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/brand/brands_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ServiceResultScreen extends StatelessWidget {
  final String serviceName;

  const ServiceResultScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    // Get first 4 letters of the service name
    final String firstFourLetters = serviceName.length >= 4
        ? serviceName.substring(0, 4).toLowerCase()
        : serviceName.toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          serviceName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 2,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('service').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text("Error: ${snapshot.error}"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Loading services..."),
                ],
              ),
            );
          }

          // Filter services where first 4 letters match
          final allServices = snapshot.data!.docs
              .cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

          final matchingServices = allServices.where((doc) {
            final data = doc.data();
            final name = data['name']?.toString().toLowerCase() ?? '';

            // Get first 4 letters of the service name
            final serviceFirstFour = name.length >= 4
                ? name.substring(0, 4)
                : name;

            // Check if first 4 letters match
            return serviceFirstFour == firstFourLetters;
          }).toList();

          if (matchingServices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No services starting with '$firstFourLetters'",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Header with info
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${matchingServices.length} Services',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Related to "$serviceName"',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: matchingServices.length,
                  itemBuilder: (context, index) {
                    final data = matchingServices[index].data();
                    final serviceId = matchingServices[index].id;
                    final title = data['name'] ?? 'Unknown';
                    final price = data['priceto']?.toString() ?? '0';
                    final imageUrl = data['imageUrl'] ?? '';
                    final offer = data['offerto']?.toString();
                    final description = data['description'] ?? '';

                    return Container(
                      // color: Colors.teal.shade50,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          Get.to(
                            () => BrandsView(
                              serviceId: serviceId,
                              serviceTitle: title,
                              imageUrl: imageUrl,
                            ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                        child: Container(
                          // color: Colors.red,
                          decoration: BoxDecoration(
                            color: Colors.teal.shade500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image Section
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  bottomLeft: Radius.circular(16),
                                ),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey.shade100,
                                  child: imageUrl.isNotEmpty
                                      ? CachedNetworkImage(
                                          imageUrl: imageUrl,
                                          fit: BoxFit.cover,
                                          width: 100,
                                          height: 100,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child: SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                ),
                                              ),
                                          errorWidget: (context, url, error) =>
                                              const Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Colors.grey,
                                              ),
                                        )
                                      : const Icon(
                                          Icons.build,
                                          size: 40,
                                          color: Colors.grey,
                                        ),
                                ),
                              ),

                              // Content Section
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),

                                      // Description
                                      if (description.isNotEmpty)
                                        Text(
                                          description,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                      const SizedBox(height: 8),

                                      // Price and Offer Row - FIXED OVERFLOW
                                      Row(
                                        children: [
                                          // Price
                                          Flexible(
                                            child: Text(
                                              "₹ $price",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green.shade700,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: false,
                                            ),
                                          ),
                                          const SizedBox(width: 8),

                                          // Offer Badge
                                          if (offer != null &&
                                              offer.isNotEmpty &&
                                              offer != '0')
                                            Flexible(
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.red.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.red.shade200,
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child: Text(
                                                  '$offer% OFF',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        Colors.orange.shade700,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  softWrap: false,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      
                                     
                                      // Verified Badge
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.verified,
                                            size: 12,
                                            color: Colors.blue.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "Verified Service",
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Arrow Indicator
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade800,
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
          );
        },
      ),
    );
  }
}
