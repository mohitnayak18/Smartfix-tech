import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_places_autocomplete_widgets/address_autocomplete_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';

const GOOGLE_MAPS_API_KEY = 'AIzaSyCipNHTns2IzWUpepl1zH-cOBAAaRq297s';

class LocationManagerPage extends StatefulWidget {
  final CartController cartCtrl = Get.find<CartController>();
  // final CartController cartCtrl;
   LocationManagerPage({super.key});
  
  @override
  State<LocationManagerPage> createState() => _LocationManagerPageState();
}

class _LocationManagerPageState extends State<LocationManagerPage> {
  // Current Location State
  final RxBool _isLoadingLocation = false.obs;
  final RxString _currentAddress = ''.obs;
  final RxBool _hasLocationPermission = false.obs;
  final RxDouble _currentLat = 0.0.obs;
  final RxDouble _currentLng = 0.0.obs;

  // Search State
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  String _selectedType = 'home';
  bool _isDefaultAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _contactPersonController.dispose();
    _contactPhoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    await _checkLocationPermission();
  }

  // ========== Location Permission Methods ==========
  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _hasLocationPermission.value = false;
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      _hasLocationPermission.value =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      print('Error checking permission: $e');
      _hasLocationPermission.value = false;
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      _isLoadingLocation.value = true;

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLoadingLocation.value = false;
        _showLocationServiceDialog();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.deniedForever) {
        _isLoadingLocation.value = false;
        _showPermanentlyDeniedDialog();
        return;
      }

      if (permission == LocationPermission.denied) {
        bool shouldRequest = await _showPermissionRationaleDialog();
        if (!shouldRequest) {
          _isLoadingLocation.value = false;
          return;
        }

        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _isLoadingLocation.value = false;
          Get.snackbar(
            'Permission Required',
            'Location permission is required to get your current address',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        _hasLocationPermission.value = true;
        await _getCurrentLocation();
      }

      _isLoadingLocation.value = false;
    } catch (e) {
      _isLoadingLocation.value = false;
      Get.snackbar(
        'Error',
        'Failed to request location permission',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== Location Fetch Methods ==========
  Future<void> _getCurrentLocation() async {
    try {
      _isLoadingLocation.value = true;
      _currentAddress.value = '';

      Position position;
      try {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        ).timeout(const Duration(seconds: 15));
      } on TimeoutException {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          position = lastPosition;
        } else {
          throw Exception('Unable to get location');
        }
      }

      _currentLat.value = position.latitude;
      _currentLng.value = position.longitude;

      // Get readable address
      await _getAddressFromLatLng(position.latitude, position.longitude);

      // Save to cart controller
      await _saveCurrentLocationToCart();
    } catch (e) {
      print('Error getting location: $e');
      _currentAddress.value = 'Error: ${e.toString()}';
      Get.snackbar(
        'Error',
        'Failed to get location',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoadingLocation.value = false;
    }
  }

  Future<void> _getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        _currentAddress.value = _formatAddress(place);
      } else {
        _currentAddress.value = 'Location at ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }
    } catch (e) {
      _currentAddress.value = 'Location at ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
    }
  }

  String _formatAddress(Placemark placemark) {
    List<String> addressComponents = [];

    if (placemark.street != null && placemark.street!.isNotEmpty) {
      addressComponents.add(placemark.street!);
    }
    if (placemark.subLocality != null && placemark.subLocality!.isNotEmpty) {
      addressComponents.add(placemark.subLocality!);
    } else if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressComponents.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null && placemark.administrativeArea!.isNotEmpty) {
      addressComponents.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      addressComponents.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressComponents.add(placemark.country!);
    }

    return addressComponents.isNotEmpty ? addressComponents.join(', ') : 'Unknown Location';
  }

  Future<void> _saveCurrentLocationToCart() async {
    try {
      // Calculate distance from business (example coordinates)
      const double businessLat = 28.7041;
      const double businessLng = 77.1025;
      double distance = Geolocator.distanceBetween(
        businessLat,
        businessLng,
        _currentLat.value,
        _currentLng.value,
      );
      double distanceInKm = distance / 1000;

      // Save using the controller's method
      final success = await widget.cartCtrl.saveAddress(
        title: 'Current Location',
        address: _currentAddress.value,
        type: 'current',
        lat: _currentLat.value,
        lng: _currentLng.value,
        distance: distanceInKm,
        note: 'Auto-detected location',
      );

      if (success) {
        Get.snackbar(
          'Location Updated',
          'Your location is ${distanceInKm.toStringAsFixed(1)} km away',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving location: $e');
      Get.snackbar(
        'Error',
        'Failed to save location',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ========== UI Components ==========
  Widget _buildCurrentLocationCard() {
    return GestureDetector(
      onTap: () async {
        if (!_hasLocationPermission.value) {
          await _requestLocationPermission();
        } else {
          await _getCurrentLocation();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _hasLocationPermission.value
                ? Colors.teal.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Obx(() => Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _hasLocationPermission.value
                        ? Colors.teal.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location,
                    size: 22,
                    color: _hasLocationPermission.value ? Colors.teal : Colors.grey,
                  ),
                )),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Use Current Location",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _hasLocationPermission.value
                              ? Colors.teal
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                        _hasLocationPermission.value
                            ? (_currentAddress.value.isEmpty
                                ? "Tap to detect your location"
                                : "Tap to refresh location")
                            : "Enable location access for accurate delivery",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      )),
                    ],
                  ),
                ),
                Obx(() => _buildLocationActionButton()),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() => _buildLocationStatus()),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationActionButton() {
    if (_isLoadingLocation.value) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.teal),
      );
    }

    if (_currentAddress.value.isNotEmpty &&
        !_currentAddress.value.startsWith('Error:')) {
      return IconButton(
        onPressed: _getCurrentLocation,
        icon: const Icon(Icons.refresh, color: Colors.teal, size: 20),
        tooltip: 'Refresh Location',
      );
    }

    return const Icon(Icons.chevron_right, color: Colors.teal);
  }

  Widget _buildLocationStatus() {
    if (_currentAddress.value.isEmpty) return const SizedBox.shrink();

    if (_currentAddress.value.startsWith('Error:')) {
      return _buildErrorStatus();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Found',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentAddress.value,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorStatus() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentAddress.value.replaceFirst('Error: ', ''),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 2,
            ),
          ),
          TextButton(
            onPressed: _requestLocationPermission,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            ),
            child: const Text('Fix', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Search Address",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: AddressAutocompleteTextField(
              mapsApiKey: GOOGLE_MAPS_API_KEY,
              language: 'en',
              componentCountry: 'in',
              decoration: const InputDecoration(
                hintText: "Search area, street, or landmark...",
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onSuggestionClick: (place) async {
                await _handlePlaceSelection(place);
              },
              buildItem: (suggestion, index) => _buildSuggestionItem(suggestion),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionItem(dynamic suggestion) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 20, color: Colors.teal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getSuggestionText(suggestion),
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getSuggestionText(dynamic suggestion) {
    try {
      return suggestion.description?.toString() ?? 
             suggestion.formattedAddress?.toString() ?? 
             suggestion.toString();
    } catch (_) {
      return suggestion.toString();
    }
  }

  Future<void> _handlePlaceSelection(dynamic place) async {
    try {
      String address = _getPlaceAddress(place) ?? '';
      double? lat = place.geometry?.location?.lat;
      double? lng = place.geometry?.location?.lng;
      String placeId = place.placeId ?? '';

      _clearControllers();
      await _showAddressFormDialog(
        address: address,
        lat: lat,
        lng: lng,
        placeId: placeId,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to process address');
    }
  }

  String? _getPlaceAddress(dynamic place) {
    return place.formattedAddress ??
           place.streetAddress ??
           place.name ??
           place.vicinity ??
           place.label;
  }

  void _clearControllers() {
    _titleController.clear();
    _noteController.clear();
    _contactPersonController.clear();
    _contactPhoneController.clear();
    _selectedType = 'home';
    _isDefaultAddress = false;
  }

  Future<void> _showAddressFormDialog({
    required String address,
    double? lat,
    double? lng,
    required String placeId,
  }) async {
    await Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: const Text('Save Address'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAddressPreview(address),
                  const SizedBox(height: 20),
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildTypeDropdown(setState),
                  const SizedBox(height: 16),
                  _buildContactPersonField(),
                  const SizedBox(height: 16),
                  _buildContactPhoneField(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                  const SizedBox(height: 16),
                  _buildDefaultCheckbox(setState),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _saveAddress(
                  address: address,
                  lat: lat,
                  lng: lng,
                  placeId: placeId,
                  setAsDefault: _isDefaultAddress,
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Save Address', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildAddressPreview(String address) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.teal, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              address,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: InputDecoration(
        labelText: 'Address Title *',
        hintText: 'e.g., Home, Office',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.title),
      ),
    );
  }

  Widget _buildTypeDropdown(StateSetter setState) {
    return DropdownButtonFormField<String>(
      value: _selectedType,
      items: const [
        DropdownMenuItem(value: 'home', child: Text('Home')),
        DropdownMenuItem(value: 'work', child: Text('Work')),
        DropdownMenuItem(value: 'other', child: Text('Other')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedType = value;
          });
        }
      },
      decoration: InputDecoration(
        labelText: 'Address Type',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.category),
      ),
    );
  }

  Widget _buildContactPersonField() {
    return TextFormField(
      controller: _contactPersonController,
      decoration: InputDecoration(
        labelText: 'Contact Person (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.person),
      ),
    );
  }

  Widget _buildContactPhoneField() {
    return TextFormField(
      controller: _contactPhoneController,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: 'Contact Phone (Optional)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.phone),
      ),
    );
  }

  Widget _buildNotesField() {
    return TextFormField(
      controller: _noteController,
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Delivery Notes (Optional)',
        hintText: 'e.g., Ring bell twice, Leave at gate',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.note),
      ),
    );
  }

  Widget _buildDefaultCheckbox(StateSetter setState) {
    return Row(
      children: [
        Checkbox(
          value: _isDefaultAddress,
          onChanged: (value) {
            setState(() {
              _isDefaultAddress = value ?? false;
            });
          },
          activeColor: Colors.teal,
        ),
        const SizedBox(width: 8),
        const Text('Set as default address'),
      ],
    );
  }

  Future<void> _saveAddress({
    required String address,
    double? lat,
    double? lng,
    required String placeId,
    bool setAsDefault = false,
  }) async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter address title');
      return;
    }

    try {
      final success = await widget.cartCtrl.saveAddress(
        title: _titleController.text.trim(),
        address: address,
        type: _selectedType,
        lat: lat,
        lng: lng,
        fullAddress: {},
        note: _noteController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        placeId: placeId,
        setAsDefault: setAsDefault,
        phone: _contactPhoneController.text.trim().isNotEmpty
            ? _contactPhoneController.text.trim()
            : '',
        distance: 0.0,
      );

      if (success) {
        Get.back();
        Get.snackbar('Success', 'Address saved successfully');
        _clearControllers();
      } else {
        Get.snackbar('Error', 'Failed to save address');
      }
    } catch (e) {
      print('Error saving address: $e');
      Get.snackbar('Error', 'Failed to save address: ${e.toString()}');
    }
  }

  Widget _buildAddressList() {
    return Expanded(
      child: Obx(() {
        if (widget.cartCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.teal));
        }

        if (widget.cartCtrl.addresses.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: widget.cartCtrl.addresses.length,
          itemBuilder: (context, index) {
            final address = widget.cartCtrl.addresses[index];
            final isSelected = widget.cartCtrl.selectedAddress['id'] == address['id'];
            return _buildAddressItem(address, isSelected, index);
          },
        );
      }),
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address, bool isSelected, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? Colors.teal.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.teal : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isSelected ? 0.1 : 0.05),
            blurRadius: 8,
            spreadRadius: isSelected ? 2 : 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.cartCtrl.getAddressIcon(address['type'] ?? 'other'),
                  size: 20,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address['title'] ?? 'Address',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.teal.shade800 : Colors.black87,
                            ),
                          ),
                        ),
                        if (address['isDefault'] == true) ...[
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address['address'],
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address['distance'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions, size: 12, color: Colors.teal),
                          const SizedBox(width: 4),
                          Text(
                            '${address['distance'].toStringAsFixed(1)} km away',
                            style: TextStyle(fontSize: 12, color: Colors.teal),
                          ),
                        ],
                      ),
                    ],
                    if (address['note']?.toString().isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Note: ${address['note']}',
                        style: TextStyle(
                          fontSize: 12, 
                          color: Colors.grey.shade600, 
                          fontStyle: FontStyle.italic
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
                onSelected: (value) => _handleAddressOption(value, address),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  if (address['isDefault'] != true)
                    const PopupMenuItem(
                      value: 'set_default',
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 18, color: Colors.amber),
                          SizedBox(width: 8),
                          Text('Set as Default'),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isSelected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Selected',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _handleAddressOption(String value, Map<String, dynamic> address) {
    switch (value) {
      case 'edit':
        _editAddress(address);
        break;
      case 'set_default':
        _setAddressAsDefault(address['id']);
        break;
      case 'delete':
        _deleteAddress(address);
        break;
    }
  }

  void _editAddress(Map<String, dynamic> address) {
    _titleController.text = address['title'] ?? '';
    _noteController.text = address['note'] ?? '';
    _contactPersonController.text = address['contactPerson'] ?? '';
    _contactPhoneController.text = address['contactPhone'] ?? '';
    _selectedType = address['type'] ?? 'home';

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Address'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitleField(),
                  const SizedBox(height: 16),
                  _buildTypeDropdown(setState),
                  const SizedBox(height: 16),
                  _buildContactPersonField(),
                  const SizedBox(height: 16),
                  _buildContactPhoneField(),
                  const SizedBox(height: 16),
                  _buildNotesField(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back();
                  _clearControllers();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => _updateAddress(address['id']),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                child: const Text('Update', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _updateAddress(String addressId) async {
    if (_titleController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please enter address title');
      return;
    }

    try {
      final success = await widget.cartCtrl.updateAddress(
        addressId: addressId,
        updates: {
          'title': _titleController.text.trim(),
          'type': _selectedType,
          'note': _noteController.text.trim(),
          'contactPerson': _contactPersonController.text.trim(),
          'contactPhone': _contactPhoneController.text.trim(),
          'updatedAt': DateTime.now(),
        },
      );

      if (success) {
        Get.back();
        Get.snackbar('Success', 'Address updated');
        _clearControllers();
      } else {
        Get.snackbar('Error', 'Failed to update address');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update address');
    }
  }

  Future<void> _setAddressAsDefault(String addressId) async {
    final success = await widget.cartCtrl.setAddressAsDefault(addressId);
    if (success) {
      Get.snackbar('Success', 'Default address updated');
    } else {
      Get.snackbar('Error', 'Failed to set default address');
    }
  }

  void _deleteAddress(Map<String, dynamic> address) {
    Get.defaultDialog(
      title: 'Delete Address',
      middleText: 'Are you sure you want to delete "${address['title']}"?',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back();
        final success = await widget.cartCtrl.deleteAddress(address['id']);
        if (success) {
          Get.snackbar('Success', 'Address deleted');
        } else {
          Get.snackbar('Error', 'Failed to delete address');
        }
      },
      onCancel: () => Get.back(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_searching,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            "No saved addresses",
            style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              "Search or use current location to add addresses",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ========== Dialog Methods ==========
  Future<bool> _showPermissionRationaleDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.location_on, color: Colors.teal),
            SizedBox(width: 12),
            Text('Location Access Required'),
          ],
        ),
        content: const Text(
          'To provide accurate delivery estimates, we need access to your location.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Allow Access', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _showLocationServiceDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Services Required'),
        content: const Text('Please enable location services to get your current address.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  void _showPermanentlyDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text('Location permission has been permanently denied. Please enable it in app settings.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              openAppSettings();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildCurrentLocationCard(),
            _buildSearchSection(),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, size: 20, color: Colors.teal),
                  const SizedBox(width: 8),
                  const Text(
                    "Saved Addresses",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    '${widget.cartCtrl.addresses.length} addresses',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  )),
                ],
              ),
            ),
            _buildAddressList(),
          ],
        ),
      ),
    );
  }
}