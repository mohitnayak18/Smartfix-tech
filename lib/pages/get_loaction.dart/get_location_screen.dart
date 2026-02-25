import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:smartfixTech/pages/Map_Location/Map_Location_screen.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:smartfixTech/utils/utils.dart'
    show AssetConstants, AppConstants;

class GetLocationScreen extends StatefulWidget {
  const GetLocationScreen({super.key});

  @override
  State<GetLocationScreen> createState() => _GetLocationScreenState();
}

class _GetLocationScreenState extends State<GetLocationScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  String? selectedAddressId;

  // @override
  // void initState() {
  //   super.initState();
  //   searchCtrl.addListener(() {
  //     if (mounted) {
  //       setState(() {}); // Rebuild to show/hide clear button
  //     }
  //   });
  // }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login to continue")),
      );
    }

    final uid = user.uid;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,

      // ==================== APP BAR ====================
      appBar: AppBar(
        backgroundColor: Colors.teal.shade50,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            child: const Icon(Icons.location_on_outlined, color: Colors.teal),
          ),
        ),
        title: const Text(
          'Set Delivery Location',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close, color: Colors.teal),
              ),
            ),
          ),
        ],
      ),

      // ==================== BODY ====================
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ==================== GOOGLE SEARCH ====================
          // ==================== GOOGLE SEARCH ====================
          Padding(
            padding: const EdgeInsets.all(12),
            child: GooglePlaceAutoCompleteTextField(
              googleAPIKey: AppConstants.GAPI,
              textEditingController: searchCtrl,
              debounceTime: 600,
              isLatLngRequired: true,
              countries: const ["in"],

              boxDecoration: BoxDecoration(
                color: Colors.white, // Background color of dropdown
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              // Custom styling for each search result item
              itemBuilder: (context, index, prediction) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: index.isEven
                        ? Colors
                              .grey
                              .shade50 // Light grey for even rows
                        : Colors.white, // White for odd rows
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Location icon with teal color
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.teal.shade400,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Address text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prediction.description ?? '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (prediction
                                    .structuredFormatting
                                    ?.secondaryText !=
                                null)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(
                                  prediction
                                      .structuredFormatting!
                                      .secondaryText!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Optional: Add arrow icon
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.grey.shade400,
                        size: 12,
                      ),
                    ],
                  ),
                );
              },

              // Custom text style for the input field
              textStyle: const TextStyle(color: Colors.black, fontSize: 16),

              inputDecoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search your location',
                hintStyle: const TextStyle(color: Colors.blueGrey),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Image.asset(
                    AssetConstants.search,
                    height: 20,
                    width: 20,
                    color: Colors.blueGrey,
                  ),
                ),
                suffixIcon: searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade500),
                        onPressed: () {
                          searchCtrl.clear();
                          setState(() {});
                        },
                      )
                    : null,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.blueGrey,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.teal.shade400,
                    width: 1.5,
                  ),
                ),
              ),

              /// 🔥 USER SELECTS LOCATION
              itemClick: (prediction) {
                if (prediction.description == null) return;

                // Get lat/lng from the prediction
                final lat = double.tryParse(prediction.lat ?? '0');
                final lng = double.tryParse(prediction.lng ?? '0');

                if (lat != null && lng != null) {
                  _showSaveAddressBottomSheet(
                    uid: uid,
                    address: prediction.description!,
                    lat: lat,
                    lng: lng,
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 6),

          // ==================== USE CURRENT LOCATION ====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => const MapLocationScreen());

                  if (result != null) {
                    _showSaveAddressBottomSheet(
                      uid: uid,
                      address: result["address"],
                      lat: result["lat"],
                      lng: result["lng"],
                    );
                  }
                },
                icon: const Icon(Icons.location_searching_outlined),
                label: const Text("Use Current Location"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade400,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),

          Divider(height: 23, color: Colors.teal.shade200),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Text(
              "Saved addresses",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),

          // ================= SAVED ADDRESS LIST - SELECT ON TAP =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("users")
                  .doc(uid)
                  .collection("addresses")
                  .orderBy("createdAt", descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No saved addresses"));
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (_, index) {
                    final map = docs[index].data() as Map<String, dynamic>;

                    final String address = map["address"] ?? "";
                    final String type = map["label"] ?? "Other";
                    final String docId = docs[index].id;
                    final bool isSelected = selectedAddressId == docId;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedAddressId = docId;
                        });
                        // Return selected address immediately
                        Get.back(
                          result: {
                            "address": address,
                            "lat": map["lat"],
                            "lng": map["lng"],
                            "type": type,
                          },
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.teal
                                : Colors.grey.shade200,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        _buildIcon(type),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    type,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (isSelected) ...[
                                                    const SizedBox(width: 8),
                                                    const Text(
                                                      "SELECTED",
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.teal,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                address,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    color: Colors.white,
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        _showEditAddressBottomSheet(
                                          uid: uid,
                                          docId: docId,
                                          data: map,
                                        );
                                      } else if (value == 'delete') {
                                        await FirebaseFirestore.instance
                                            .collection("users")
                                            .doc(uid)
                                            .collection("addresses")
                                            .doc(docId)
                                            .delete();
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Edit'),
                                          ],
                                        ),
                                      ),
                                      // Dimens.boxHeight10,
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete,
                                              size: 18,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Text('Delete'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.teal,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                              ),
                          ],
                        ),
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

  // ================= ICON BUILDER =================
  Widget _buildIcon(String type) {
    switch (type) {
      case "Home":
        return const Icon(Icons.home, color: Colors.blue, size: 22);
      case "Work":
        return const Icon(Icons.work, color: Colors.black54, size: 22);
      case "Other":
      default:
        return const Icon(Icons.location_on, color: Colors.teal, size: 22);
    }
  }

  // ================= SINGLE BOTTOM SHEET FOR SAVING ADDRESS =================
  void _showSaveAddressBottomSheet({
    required String uid,
    required String address,
    required double lat,
    required double lng,
  }) {
    String addressType = "Home";
    final phoneCtrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                Row(
                  children: ["Home", "Work", "Other"].map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: addressType == type,
                          onSelected: (_) => setState(() => addressType = type),
                          selectedColor: Colors.teal.shade200,
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone, size: 20),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (phoneCtrl.text.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please enter phone number",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("addresses")
                              .add({
                                "address": address,
                                "lat": lat,
                                "lng": lng,
                                "label": addressType,
                                "phone": phoneCtrl.text.trim(),
                                "createdAt": Timestamp.now(),
                              });

                          Get.back();
                          Get.back(
                            result: {
                              "address": address,
                              "lat": lat,
                              "lng": lng,
                              "type": addressType,
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Save & Continue"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ================= BOTTOM SHEET FOR EDITING ADDRESS =================
  void _showEditAddressBottomSheet({
    required String uid,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    String addressType = data["label"] ?? "Home";
    final phoneCtrl = TextEditingController(text: data["phone"] ?? "");

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data["address"] ?? "",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 14),

                Row(
                  children: ["Home", "Work", "Other"].map((type) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(type),
                          selected: addressType == type,
                          onSelected: (_) => setState(() => addressType = type),
                          selectedColor: Colors.teal.shade200,
                          backgroundColor: Colors.grey.shade100,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.phone, size: 20),
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (phoneCtrl.text.trim().isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please enter phone number",
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                            return;
                          }

                          await FirebaseFirestore.instance
                              .collection("users")
                              .doc(uid)
                              .collection("addresses")
                              .doc(docId)
                              .update({
                                "label": addressType,
                                "phone": phoneCtrl.text.trim(),
                              });

                          Get.back();
                          Get.snackbar(
                            "Success",
                            "Address updated successfully",
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Update Address"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
