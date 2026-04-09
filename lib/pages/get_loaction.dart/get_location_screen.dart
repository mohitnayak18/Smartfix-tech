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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    searchCtrl.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild to show/hide clear button
      }
    });
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // Show snackbar helper
  void _showSnackbar(String message, {bool isError = true}) {
    Get.snackbar(
      isError ? "Error" : "Success",
      message,
      backgroundColor: isError ? Colors.red : Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 50, color: Colors.red),
              SizedBox(height: 16),
              Text("Please login to continue"),
            ],
          ),
        ),
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
      body: Stack(
        children: [
          Column(
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

                  boxDecoration: BoxDecoration(
                    color: Colors.white,
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
                            ? Colors.grey.shade50
                            : Colors.white,
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
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
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey.shade400,
                            size: 12,
                          ),
                        ],
                      ),
                    );
                  },

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
                            icon: Icon(
                              Icons.clear,
                              color: Colors.grey.shade500,
                            ),
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
              // ==================== USE CURRENT LOCATION ====================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            setState(() => _isLoading = true);

                            // Navigate to map and wait for result
                            final result = await Get.to(
                              () => const MapLocationScreen(),
                            );

                            setState(() => _isLoading = false);

                            // If we got a result with all details, save directly
                            if (result != null) {
                              // Check if result has phone (means it came from dialog)
                              if (result["phone"] != null &&
                                  result["phone"].isNotEmpty) {
                                // Save directly to Firebase
                                await FirebaseFirestore.instance
                                    .collection("users")
                                    .doc(uid)
                                    .collection("addresses")
                                    .add({
                                      "address": result["address"],
                                      "lat": result["lat"],
                                      "lng": result["lng"],
                                      "label": result["label"] ?? "Home",
                                      "phone": result["phone"],
                                      "name": result["name"] ?? "",
                                      "address_title": result["title"] ?? "",
                                      "createdAt": FieldValue.serverTimestamp(),
                                    });

                                _showSnackbar(
                                  "Address saved successfully",
                                  isError: false,
                                );
                              } else {
                                // Show bottom sheet to collect additional details
                                _showSaveAddressBottomSheet(
                                  uid: uid,
                                  address: result["address"],
                                  lat: result["lat"],
                                  lng: result["lng"],
                                );
                              }
                            }
                          },
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.location_searching_outlined),
                    label: Text(
                      _isLoading ? "Loading..." : "Use Current Location",
                    ),
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

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Saved addresses",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text("Add New"),
                      style: TextButton.styleFrom(foregroundColor: Colors.teal),
                    ),
                  ],
                ),
              ),

              // ================= SAVED ADDRESS LIST =================
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
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No saved addresses",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Add your first delivery address",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: docs.length,
                      itemBuilder: (_, index) {
                        final map = docs[index].data() as Map<String, dynamic>;

                        final String address = map["address"] ?? "";
                        final String type = map["label"] ?? "Other";
                        final String phone = map["phone"] ?? "";
                        final String docId = docs[index].id;
                        final bool isSelected = selectedAddressId == docId;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedAddressId = docId;
                            });
                            Get.back(
                              result: {
                                "id": docId,
                                "address": map["address"],
                                "address_title": map["address_title"],
                                "lat": map["lat"],
                                "lng": map["lng"],
                                "label": map["label"],
                                "phone": map["phone"],
                                "name": map["name"],
                              },
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.teal
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.teal.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Icon with colored background
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: _getIconColor(
                                            type,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: _buildIcon(type),
                                      ),
                                      const SizedBox(width: 12),

                                      // Address details
                                      // Address details
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
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                if (isSelected) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.teal
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            12,
                                                          ),
                                                    ),
                                                    child: const Text(
                                                      "SELECTED",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.teal,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),

                                            // Address title (if exists)
                                            if (map["address_title"] != null &&
                                                map["address_title"]
                                                    .toString()
                                                    .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 2,
                                                  top: 2,
                                                ),
                                                child: Text(
                                                  map["address_title"],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.teal.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),

                                            // Full address
                                            const SizedBox(height: 2),
                                            Text(
                                              address,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            // Phone number
                                            if (phone.isNotEmpty) ...[
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.phone_outlined,
                                                    size: 14,
                                                    color: Colors.grey.shade500,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    phone,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Menu button
                                      PopupMenuButton<String>(
                                        color: Colors.white,
                                        icon: const Icon(
                                          Icons.more_vert,
                                          size: 20,
                                        ),
                                        onSelected: (value) async {
                                          if (value == 'edit') {
                                            _showEditAddressBottomSheet(
                                              uid: uid,
                                              docId: docId,
                                              data: map,
                                            );
                                          } else if (value == 'delete') {
                                            _showDeleteConfirmation(uid, docId);
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
                                    decoration: const BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        bottomRight: Radius.circular(16),
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

          // Loading overlay
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text("Processing..."),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ================= HELPER METHODS =================

  Color _getIconColor(String type) {
    switch (type) {
      case "Home":
        return Colors.blue;
      case "Work":
        return Colors.black54;
      default:
        return Colors.teal;
    }
  }

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

  Future<void> _showDeleteConfirmation(String uid, String docId) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Delete Address"),
        content: const Text("Are you sure you want to delete this address?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .collection("addresses")
          .doc(docId)
          .delete();
      setState(() => _isLoading = false);
      _showSnackbar("Address deleted successfully", isError: false);
    }
  }

  // ================= SAVE ADDRESS BOTTOM SHEET =================
  // ================= SAVE ADDRESS BOTTOM SHEET =================
  // ================= SAVE ADDRESS BOTTOM SHEET =================
  void _showSaveAddressBottomSheet({
    required String uid,
    required String address,
    required double lat,
    required double lng,
  }) {
    String addressType = "Home";
    final phoneCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final addressTitleCtrl = TextEditingController();
    bool isSaving = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Save Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Address preview - make it shorter if address is long
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.teal.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          address,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1, // CHANGED: from 2 to 1
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Wrap the form fields in a SingleChildScrollView
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Address type chips
                      const Text(
                        "Address Label",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ["Home", "Work", "Other"].map((type) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: addressType == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => addressType = type);
                                  }
                                },
                                selectedColor: Colors.teal.shade100,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(
                                  color: addressType == type
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: addressType == type
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Address Title
                      TextField(
                        controller: addressTitleCtrl,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Area/Locality name",
                          hintText: "e.g. Lingipur, Kharvel Nagar",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.location_city,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED vertical padding
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Name
                      TextField(
                        controller: nameCtrl,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Your name",
                          hintText: "Enter your full name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED vertical padding
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Phone number
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone number",
                          hintText: "Enter your phone number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED vertical padding
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16), // REDUCED from 20 to 16
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isSaving ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // REDUCED from 14 to 12
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (phoneCtrl.text.trim().isEmpty) {
                                  _showSnackbar("Please enter phone number");
                                  return;
                                }
                                if (nameCtrl.text.trim().isEmpty) {
                                  _showSnackbar("Please enter your name");
                                  return;
                                }

                                setState(() => isSaving = true);

                                try {
                                  String addressTitle = addressTitleCtrl.text
                                      .trim();
                                  if (addressTitle.isEmpty) {
                                    final parts = address.split(',');
                                    addressTitle = parts.isNotEmpty
                                        ? parts[0].trim()
                                        : "Address";
                                  }
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid)
                                      .collection("addresses")
                                      .add({
                                        "address": address,
                                        "address_title": addressTitle,
                                        "lat": lat,
                                        "lng": lng,
                                        "label": addressType,
                                        "phone": phoneCtrl.text.trim(),
                                        "name": nameCtrl.text.trim(),
                                        "createdAt":
                                            FieldValue.serverTimestamp(),
                                      });

                                  Get.back();
                                  _showSnackbar(
                                    "Address saved successfully",
                                    isError: false,
                                  );

                                  Get.back(
                                    result: {
                                      "address": address,
                                      "address_title": addressTitle,
                                      "lat": lat,
                                      "lng": lng,
                                      "label": addressType,
                                      "phone": phoneCtrl.text.trim(),
                                      "name": nameCtrl.text.trim(),
                                    },
                                  );
                                } catch (e) {
                                  _showSnackbar("Failed to save address");
                                  setState(() => isSaving = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // REDUCED from 14 to 12
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Save Address"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: false,
    );
  }

  // ================= EDIT ADDRESS BOTTOM SHEET =================
  // ================= EDIT ADDRESS BOTTOM SHEET =================
  void _showEditAddressBottomSheet({
    required String uid,
    required String docId,
    required Map<String, dynamic> data,
  }) {
    String addressType = data["label"] ?? "Home";
    final phoneCtrl = TextEditingController(text: data["phone"] ?? "");
    final nameCtrl = TextEditingController(text: data["name"] ?? "");
    final addressTitleCtrl = TextEditingController(
      text: data["address_title"] ?? "",
    );
    bool isUpdating = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  "Edit Address",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Address preview - reduced maxLines
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.teal.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data["address"] ?? "",
                          style: const TextStyle(fontSize: 14),
                          maxLines: 1, // CHANGED: from 2 to 1
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Wrap form fields in SingleChildScrollView
                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Address Label
                      const Text(
                        "Address Label",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ["Home", "Work", "Other"].map((type) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: ChoiceChip(
                                label: Text(type),
                                selected: addressType == type,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() => addressType = type);
                                  }
                                },
                                selectedColor: Colors.teal.shade100,
                                backgroundColor: Colors.grey.shade100,
                                labelStyle: TextStyle(
                                  color: addressType == type
                                      ? Colors.teal.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: addressType == type
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),

                      // Address Title
                      TextField(
                        controller: addressTitleCtrl,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          labelText: "Area/Locality name",
                          hintText: "e.g. Lingipur, Kharvel Nagar",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.location_city,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED padding
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Name
                      TextField(
                        controller: nameCtrl,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: "Your name",
                          hintText: "Enter your full name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED padding
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Phone
                      TextField(
                        controller: phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Phone number",
                          hintText: "Enter your phone number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.teal.shade400,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: Colors.teal.shade400,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12, // REDUCED padding
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16), // REDUCED from 20 to 16
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // REDUCED from 14 to 12
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isUpdating
                            ? null
                            : () async {
                                if (phoneCtrl.text.trim().isEmpty) {
                                  _showSnackbar("Please enter phone number");
                                  return;
                                }
                                if (nameCtrl.text.trim().isEmpty) {
                                  _showSnackbar("Please enter your name");
                                  return;
                                }

                                setState(() => isUpdating = true);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection("users")
                                      .doc(uid)
                                      .collection("addresses")
                                      .doc(docId)
                                      .update({
                                        "label": addressType,
                                        "phone": phoneCtrl.text.trim(),
                                        "name": nameCtrl.text.trim(),
                                        "address_title": addressTitleCtrl.text
                                            .trim(),
                                      });

                                  Get.back();
                                  _showSnackbar(
                                    "Address updated successfully",
                                    isError: false,
                                  );
                                } catch (e) {
                                  _showSnackbar("Failed to update address");
                                  setState(() => isUpdating = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ), // REDUCED from 14 to 12
                        ),
                        child: isUpdating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Update Address"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
      enableDrag: false,
    );
  }
}
