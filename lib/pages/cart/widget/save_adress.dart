import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../cart/cart_controller.dart';

/// 🔐 Move this to --dart-define in production
const GOOGLE_MAPS_API_KEY = String.fromEnvironment('AIzaSyCipNHTns2IzWUpepl1zH-cOBAAaRq297s');

class SaveAddressPage extends StatefulWidget {
  final CartController cartCtrl;

  const SaveAddressPage({super.key, required this.cartCtrl});

  @override
  State<SaveAddressPage> createState() => _SaveAddressPageState();
}

class _SaveAddressPageState extends State<SaveAddressPage> {
  final RxDouble _currentLat = 0.0.obs;
  final RxDouble _currentLng = 0.0.obs;
  final RxString _currentAddress = ''.obs;

  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  // ─────────────────────────────────────────────────────────────
  // 📍 CURRENT LOCATION (LOCAL ONLY)
  // ─────────────────────────────────────────────────────────────

  Future<void> _fetchCurrentLocation() async {
    try {
      _isLoading.value = true;

      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar('Permission denied', 'Location permission is required');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _currentLat.value = position.latitude;
      _currentLng.value = position.longitude;

      // ⚠️ Replace with reverse-geocoding if needed
      _currentAddress.value =
          'Lat ${position.latitude}, Lng ${position.longitude}';

    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch location');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> _saveCurrentLocationToCart() async {
    const double businessLat = 28.7041;
    const double businessLng = 77.1025;

    final distanceInKm = Geolocator.distanceBetween(
      businessLat,
      businessLng,
      _currentLat.value,
      _currentLng.value,
    ) / 1000;

    final now = DateTime.now();

    final currentAddress = {
      'id': 'current',
      'title': 'Current Location',
      'address': _currentAddress.value,
      'type': 'current',
      'lat': _currentLat.value,
      'lng': _currentLng.value,
      'distance': distanceInKm,
      'createdAt': now,
      'updatedAt': now,
      'lastUsedAt': now,
      'isDefault': false,
    };

    widget.cartCtrl.setCurrentAddress(currentAddress);

    Get.back();

    Get.snackbar(
      'Location Selected',
      'Your location is ${distanceInKm.toStringAsFixed(1)} km away',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 🏠 SAVE NORMAL ADDRESS (FIRESTORE)
  // ─────────────────────────────────────────────────────────────

  Future<void> _saveNormalAddress({
    required String title,
    required String address,
    required double lat,
    required double lng,
  }) async {
    final success = await widget.cartCtrl.saveAddress(
      title: title,
      address: address,
      lat: lat,
      lng: lng,
      type: 'saved',
    );

    if (success) {
      Get.back();
      Get.snackbar('Saved', 'Address saved successfully');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // 🧠 HELPERS
  // ─────────────────────────────────────────────────────────────

  DateTime parseDate(dynamic v) {
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return DateTime.now();
  }

  // ─────────────────────────────────────────────────────────────
  // 🖥 UI
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Address')),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ───────── CURRENT LOCATION CARD ─────────
            Card(
              child: ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('Use Current Location'),
                subtitle: Obx(() => Text(
                      _currentAddress.value.isEmpty
                          ? 'Detecting...'
                          : _currentAddress.value,
                    )),
                onTap: _saveCurrentLocationToCart,
              ),
            ),

            const SizedBox(height: 20),

            // ───────── SAVED ADDRESSES ─────────
            const Text(
              'Saved Addresses',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            Obx(() {
              final addresses = widget.cartCtrl.addresses;

              if (addresses.isEmpty) {
                return const Text('No saved addresses');
              }

              return Column(
                children: addresses.map((address) {
                  final distance =
                      (address['distance'] as num?)?.toDouble();

                  return Card(
                    child: ListTile(
                      title: Text(address['title'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(address['address'] ?? ''),
                          if (distance != null)
                            Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.teal),
                            ),
                        ],
                      ),
                      onTap: () {
                        widget.cartCtrl.setCurrentAddress(address);
                        Get.back();
                      },
                    ),
                  );
                }).toList(),
              );
            }),
          ],
        );
      }),
    );
  }
}
