import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:smartfixTech/pages/Map_Location/Map_Location_screen.dart';
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: GooglePlaceAutoCompleteTextField(
              googleAPIKey: AppConstants.GAPI,
              textEditingController: searchCtrl,
              debounceTime: 600,
              isLatLngRequired: true,
              countries: const ["in"],

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
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.blueGrey,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.blueGrey,
                    width: 1.2,
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
                  showSaveAddressDialog(
                    address: prediction.description!,
                    lat: lat,
                    lng: lng,
                    uid: uid,
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
                    _openSaveBottomSheet(
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
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (value) async {
                                      if (value == 'edit') {
                                        _openEditBottomSheet(
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

  // ================= SHOW SAVE ADDRESS DIALOG =================
  void showSaveAddressDialog({
    required String address,
    required double lat,
    required double lng,
    required String uid,
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
                      child: ChoiceChip(
                        label: Text(type),
                        selected: addressType == type,
                        onSelected: (_) => setState(() => addressType = type),
                        selectedColor: Colors.teal.shade200,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: "Phone number",
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Save & Continue"),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ================= SAVE ADDRESS BOTTOM SHEET =================
  void _openSaveBottomSheet({
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
                ),

                const SizedBox(height: 14),

                Row(
                  children: ["Home", "Work", "Other"].map((type) {
                    return Expanded(
                      child: ChoiceChip(
                        label: Text(type),
                        selected: addressType == type,
                        onSelected: (_) => setState(() => addressType = type),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: "Phone number"),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
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
                    child: const Text("Save & Continue"),
                  ),
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

void _openEditBottomSheet({
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
                data["address"],
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: ["Home", "Work", "Other"].map((type) {
                  return Expanded(
                    child: ChoiceChip(
                      label: Text(type),
                      selected: addressType == type,
                      onSelected: (_) => setState(() => addressType = type),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Phone number"),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
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
                  },
                  child: const Text("Update Address"),
                ),
              ),
            ],
          );
        },
      ),
    ),
    isScrollControlled: true,
  );
}
