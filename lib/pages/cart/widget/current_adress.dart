import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:smartfixTech/pages/cart/cart_controller.dart';

class CurrentAddressWidget extends StatefulWidget {
  final CartController cartCtrl;
  const CurrentAddressWidget({super.key, required this.cartCtrl});

  @override
  State<CurrentAddressWidget> createState() => _CurrentAddressWidgetState();
}

class _CurrentAddressWidgetState extends State<CurrentAddressWidget> {
  final RxBool _isLoading = false.obs;
  final RxBool _hasPermission = false.obs;

  final RxString _address = ''.obs;
  final RxDouble _lat = 0.0.obs;
  final RxDouble _lng = 0.0.obs;

  DateTime? _lastFetchedAt;

  static const int _cacheTTLMinutes = 10;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  // ─────────────────────────────────────────────
  // 🔐 PERMISSION + INIT
  // ─────────────────────────────────────────────

  Future<void> _initLocation() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return;

    final permission = await Geolocator.checkPermission();
    _hasPermission.value = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (_hasPermission.value) {
      await _fetchLocationIfNeeded();
    }
  }

  Future<void> _requestPermission() async {
    final permission = await Geolocator.requestPermission();
    _hasPermission.value = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;

    if (_hasPermission.value) {
      await _fetchLocation(force: true);
    }
  }


  Future<void> _fetchLocationIfNeeded() async {
    if (_lastFetchedAt == null ||
        DateTime.now().difference(_lastFetchedAt!) >
            const Duration(minutes: _cacheTTLMinutes)) {
      await _fetchLocation();
    }
  }

  Future<void> _fetchLocation({bool force = false}) async {
    if (_isLoading.value) return;

    try {
      _isLoading.value = true;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 12),
      );

      _lat.value = position.latitude;
      _lng.value = position.longitude;

      await _reverseGeocode(position.latitude, position.longitude);

      _saveCurrentLocationToCart();

      _lastFetchedAt = DateTime.now();
    } catch (_) {
      _address.value = 'Unable to fetch location';
    } finally {
      _isLoading.value = false;
    }
  }


  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final placemarks =
          await placemarkFromCoordinates(lat, lng).timeout(
        const Duration(seconds: 5),
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _address.value = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode
        ].where((e) => e != null && e!.isNotEmpty).join(', ');
      } else {
        _address.value = 'Lat $lat, Lng $lng';
      }
    } catch (_) {
      _address.value = 'Lat $lat, Lng $lng';
    }
  }



  void _saveCurrentLocationToCart() {
    const double businessLat = 28.7041;
    const double businessLng = 77.1025;

    final distanceKm = Geolocator.distanceBetween(
          businessLat,
          businessLng,
          _lat.value,
          _lng.value,
        ) /
        1000;

    final now = DateTime.now();

    final currentAddress = {
      'id': 'current',
      'title': 'Current Location',
      'address': _address.value,
      'type': 'current',
      'lat': _lat.value,
      'lng': _lng.value,
      'distance': distanceKm,
      'createdAt': now,
      'updatedAt': now,
      'lastUsedAt': now,
      'isDefault': false,
    };

    widget.cartCtrl.setCurrentAddress(currentAddress);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (!_hasPermission.value) {
          await _requestPermission();
        } else {
          await _fetchLocation(force: true);
        }
      },
      child: Obx(() {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasPermission.value
                  ? Colors.teal.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _hasPermission.value
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      Icons.my_location,
                      color:
                          _hasPermission.value ? Colors.teal : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Use Current Location',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          !_hasPermission.value
                              ? 'Enable location permission'
                              : _address.value.isEmpty
                                  ? 'Tap to detect your location'
                                  : _address.value,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isLoading.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}
