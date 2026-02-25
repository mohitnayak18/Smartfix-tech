import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key});

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  GoogleMapController? _mapController;

  LatLng _centerLatLng = const LatLng(20.2961, 85.8245);
  String _title = "Fetching location...";
  String _fullAddress = "";
  bool _loadingAddress = false;

  // Move these to StatefulWidget to prevent rebuild issues
  String _selectedLabel = "Home";
  final List<String> _labels = ["Home", "Work", "Other"];
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ================= LOCATION =================

  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    _centerLatLng = LatLng(position.latitude, position.longitude);

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_centerLatLng, 18),
    );

    _getAddress(_centerLatLng);
  }

  // ================= ADDRESS =================

  Future<void> _getAddress(LatLng latLng) async {
    try {
      setState(() => _loadingAddress = true);

      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isEmpty) return;

      final p = placemarks.first;

      setState(() {
        _title = p.subLocality?.isNotEmpty == true
            ? p.subLocality!
            : p.locality ?? "";

        _fullAddress = [
          p.thoroughfare,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
          p.country,
        ].where((e) => e != null && e!.isNotEmpty).join(", ");

        _loadingAddress = false;
      });
    } catch (e) {
      log("Address error: $e");
      setState(() => _loadingAddress = false);
    }
  }

  // ================= FIRESTORE SAVE =================

  Future<void> _saveAddressWithExtra() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docId = FirebaseFirestore.instance.collection("tmp").doc().id;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("addresses")
        .doc(docId)
        .set({
          "label": _selectedLabel,
          "lat": _centerLatLng.latitude,
          "lng": _centerLatLng.longitude,
          "title": _titleCtrl.text.trim(),
          "phone": _phoneCtrl.text.trim(),
          "address": _fullAddress,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // ================= CONFIRM (OPTIMIZED) =================

  Future<void> _confirm() async {
    _titleCtrl.text = _title; // prefill

    // Use StatefulBuilder for better performance in dialog
    String tempSelectedLabel = _selectedLabel; // Local state for dialog

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("Save address"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LABEL CHOICES - OPTIMIZED
                    Wrap(
                      spacing: 8,
                      children: _labels.map((label) {
                        final selected = tempSelectedLabel == label;
                        return ChoiceChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (selected) {
                            if (selected) {
                              setStateDialog(() {
                                tempSelectedLabel =
                                    label; // Update local state only
                              });
                            }
                          },
                          selectedColor: Colors.teal,
                          backgroundColor: Colors.grey.shade200,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          pressElevation: 0, // Reduce animation
                          elevation: 0, // Reduce animation
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // ADDRESS TITLE
                    TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(4.0)),
                          borderSide: BorderSide(color: Colors.teal, width: 2),
                        ),
                        labelText: "Address title",
                        hintText: "e.g. Flat, House name",
                      ),
                    ),

                    const SizedBox(height: 12),

                    // PHONE
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.teal, width: 2),
                        ),
                        labelText: "Phone number",
                        hintText: "Enter your phone number",
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ADDRESS PREVIEW
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _fullAddress,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_phoneCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter phone number"),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Update the actual state with dialog selection
                    setState(() {
                      _selectedLabel = tempSelectedLabel;
                    });

                    await _saveAddressWithExtra();

                    Navigator.pop(context); // close dialog
                    Navigator.pop(context, {
                      "lat": _centerLatLng.latitude,
                      "lng": _centerLatLng.longitude,
                      "label": _selectedLabel,
                      "title": _titleCtrl.text.trim(),
                      "phone": _phoneCtrl.text.trim(),
                      "address": _fullAddress,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerLatLng,
              zoom: 18,
            ),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _centerLatLng = position.target;
            },
            onCameraIdle: () {
              _getAddress(_centerLatLng);
            },
          ),

          // 📍 CENTER PIN
          const Center(
            child: Icon(Icons.location_pin, size: 50, color: Colors.red),
          ),

          // 📍 CURRENT LOCATION BUTTON
          Positioned(
            right: 16,
            bottom: 210,
            child: FloatingActionButton.extended(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.my_location),
              label: const Text("Current location"),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // 📦 BOTTOM SHEET
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Place the pin at exact delivery location",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.teal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _loadingAddress
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.teal,
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _fullAddress,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loadingAddress ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Confirm & proceed",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
