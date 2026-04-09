import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
// import 'package:smartfixTech/controllers/cart_controller.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
// import 'package:uuid/uuid.dart';

class CheckoutController extends GetxController {
  final TextEditingController phoneCtrl = TextEditingController();

  // State
  RxBool useSavedAddress = true.obs;
  String? selectedAddressId;
// Add these to your CheckoutController class

final TextEditingController noteCtrl = TextEditingController();
final RxString customerNote = "".obs;
final RxBool hasNote = false.obs;

String getCustomerNote() {
  return noteCtrl.text.trim();
}

void clearNote() {
  noteCtrl.clear();
  customerNote.value = "";
  hasNote.value = false;
}

void setNote(String note) {
  customerNote.value = note;
  hasNote.value = note.isNotEmpty;
}

// Update onClose method
@override
void onClose() {
  phoneCtrl.dispose();
  // phoneCtrl.dispose();
    super.onClose();
  noteCtrl.dispose(); // Add this line
  super.onClose();
}

// Get cart controller
CartController get cartCtrl => Get.find<CartController>();

  @override
  void onInit() {
    super.onInit();
    _initializeAddress();
    fetchTermsAndConditions();
  }

  void _initializeAddress() {
    if (cartCtrl.selectedAddress.isNotEmpty) {
      selectedAddressId = cartCtrl.selectedAddress['id'];
      phoneCtrl.text = cartCtrl.selectedAddress['phone'] ?? '';
    }
  }

  String getDeliveryDate() {
    final now = DateTime.now();
    final deliveryDate = now.add(const Duration(minutes: 45));
    return DateFormat('MMM dd, EEEE').format(deliveryDate);
  }

  String formatCurrency(double amount) {
    return '₹${NumberFormat('#,##0').format(amount)}';
  }

  bool validatePhone() {
    String phone = phoneCtrl.text.trim().replaceAll(RegExp(r'\D'), '');
    return phone.length == 10;
  }

  Map<String, dynamic> getAddressData() {
    if (cartCtrl.selectedAddress.isNotEmpty) {
      return {
        'title': cartCtrl.selectedAddress['title'] ?? 'Address',
        'address': cartCtrl.selectedAddress['address'] ?? '',
        'phone': cartCtrl.selectedAddress['phone'] ?? '',
        'type': cartCtrl.selectedAddress['type'] ?? 'home',
        'latitude': cartCtrl.selectedAddress['lat'],
        'longitude': cartCtrl.selectedAddress['lng'],
        'customer': cartCtrl.selectedAddress['name'] ?? 'Customer',
        'distance': cartCtrl.selectedAddress['distance'] ?? 0.0,
      };
    }
    return {'title': 'No Address', 'address': '', 'type': 'other'};
  }

  void selectAddressFromList(Map<String, dynamic> address) {
    cartCtrl.selectAddress(address);
    selectedAddressId = address['id'];
    phoneCtrl.text = address['phone'] ?? '';
    update();
  }

  // Terms & Conditions
  final RxBool isTermsAccepted = false.obs;
  final RxString termsContent = "Loading terms & conditions...".obs;
  final RxString privacyContent = "Loading privacy policy...".obs;
  final RxBool isLoadingTerms = false.obs;

  // Fetch Terms & Conditions from Firestore settings collection
  Future<void> fetchTermsAndConditions() async {
    try {
      isLoadingTerms.value = true;

      // Get terms_conditions document from settings collection
      final DocumentSnapshot termDoc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('term_conditions')
          .get();

      if (termDoc.exists) {
        final data = termDoc.data() as Map<String, dynamic>;

        // Fetch terms content
        termsContent.value =
            data['terms'] ?? data['terms_condition'] ?? data['content'] ?? '';

        // Fetch privacy policy content
        privacyContent.value =
            data['privacy'] ??
            data['privacy_policy'] ??
            data['privacyContent'] ??
            '';

        print("Terms loaded successfully from Firestore");
      } else {
        print("term_conditions document not found, using defaults");
        // termsContent.value = _getDefaultTerms();
        // privacyContent.value = _getDefaultPrivacy();
      }
    } catch (e) {
      print('Error fetching terms from Firestore: $e');
      // termsContent.value = _getDefaultTerms();
      // privacyContent.value = _getDefaultPrivacy();
    } finally {
      isLoadingTerms.value = false;
    }
  }

  // Validate terms before placing order
  bool validateTerms() {
    if (!isTermsAccepted.value) {
      Get.snackbar(
        "Accept Terms Required",
        "Please accept the Terms & Conditions and Privacy Policy to continue",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
      return false;
    }
    return true;
  }

  void showTermsDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // FIXED: Row with Flexible to prevent overflow
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.description, color: Colors.teal.shade700),
                  ),
                  const SizedBox(width: 12),
                  // Use Flexible instead of direct Text
                  Flexible(
                    child: Text(
                      "Terms & Conditions",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (isLoadingTerms.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Text(
                      termsContent.value,
                      style: const TextStyle(height: 1.6, fontSize: 14),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Show Privacy Dialog
  void showPrivacyDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: Get.width * 0.9,
          height: Get.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // FIXED: Row with Flexible to prevent overflow
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.privacy_tip, color: Colors.teal.shade700),
                  ),
                  const SizedBox(width: 12),
                  // Use Flexible instead of direct Text
                  Flexible(
                    child: Text(
                      "Privacy Policy",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),
              Expanded(
                child: Obx(() {
                  if (isLoadingTerms.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SingleChildScrollView(
                    child: Text(
                      privacyContent.value,
                      style: const TextStyle(height: 1.6, fontSize: 14),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
