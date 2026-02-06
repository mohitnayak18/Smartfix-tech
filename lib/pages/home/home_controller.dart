import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/main.dart';
import 'package:smartfixTech/navigators/routes_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize HomeController globally
  Get.put(HomeController());

  runApp(MyApp());
}

class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final isLoading = false.obs;
  final carouselCurrentIndex = 0.obs;
  final RxList banners = [].obs;

  final RxString userName = "User".obs;
  final RxString phone = "".obs;

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
    //  Get.put(HomeController());
    loadUserData();
  }

  // ---------------- USER DATA ----------------
  void loadUserData() async {
    final user = _auth.currentUser;

    if (user != null) {
      phone.value = user.phoneNumber ?? "";

      /// OPTIONAL: Fetch name from Firestore
      try {
        final snap = await _db.collection("users").doc(user.uid).get();
        if (snap.exists) {
          userName.value = snap.data()?['name'] ?? "User";
        }
      } catch (e) {
        log("Error fetching user profile: $e");
      }
    }
  }

  // ---------------- BANNER LOGIC ----------------
  void updatePageIndicator(int index) {
    carouselCurrentIndex.value = index;
  }

  Future<void> fetchBanners() async {
    try {
      isLoading.value = true;

      final result = await _db.collection('banners').get();

      banners.clear();
      for (var doc in result.docs) {
        banners.add(doc.data());
      }
    } on FirebaseException catch (e) {
      Get.snackbar("Error", e.message ?? "Firebase error");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- LOGOUT ----------------
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      RouteManagement.goOffAllboarding();
    } catch (e) {
      Get.snackbar("Logout Failed", e.toString());
    }
  }
}
