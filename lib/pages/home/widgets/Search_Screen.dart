import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:smartfixTech/pages/brands/brands.dart';
import 'package:smartfixTech/pages/brands/brands_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({
    super.key,
    // required this.id,
    // required this.title,
    // required this.price,
    // required this.orgprice,
    // required this.cutPrice,
    // required this.offer,
    // required this.imageUrl,
    // this.isVerified = true,
  });

  // final String id;
  // final String title;
  // final String price;
  // final String orgprice;
  // final String cutPrice;
  // final String offer;
  // final String imageUrl;
  // final bool isVerified;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // ================= TOP HEADER =================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF0E8F84),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back + Title
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "Search",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ================= SEARCH BAR =================
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    autofocus: true,
                    onChanged: (value) {
                      setState(() {
                        searchText = value.trim().toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        // borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.6,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: "Search in store",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ================= SEARCH RESULTS =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('service')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔹 Show hint until user types
                if (searchText.isEmpty) {
                  return const Center(
                    child: Text(
                      "Search services to see results",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final results = snapshot.data!.docs.where((doc) {
                  final name = doc['name'].toString().toLowerCase();
                  return name.contains(searchText);
                }).toList();

                if (results.isEmpty) {
                  return const Center(child: Text("No service found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final data = results[index].data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.teal.shade50,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            data['imageUrl'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          data['name'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text("₹ ${data['priceto']}"),
                        onTap: () {
                          Get.to(
                            () => BrandsView(
                              serviceId:
                                  results[index].id, // 🔥 correct document id
                              serviceTitle: data['name'], // 🔥 correct name
                              imageUrl: data['imageUrl'], // 🔥 correct image
                            ),
                            transition: Transition.rightToLeft,
                            duration: const Duration(milliseconds: 300),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
