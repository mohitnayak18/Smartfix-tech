import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapLocationScreen extends StatefulWidget {
  const MapLocationScreen({super.key});

  @override
  State<MapLocationScreen> createState() => _MapLocationScreenState();
}

class _MapLocationScreenState extends State<MapLocationScreen> {
  late GoogleMapController mapController;
  LocationPermission? permission;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  getLocation() async {
    permission = await Geolocator.requestPermission();

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    double lat = position.latitude;
    double long = position.longitude;

    LatLng location = LatLng(lat, long);
    log('${location}');
    setState(() {
      _currentPosition = location;
    });
  }

  // static const CameraPosition _kGoogleplex = CameraPosition(
  //   target: LatLng(28.3949, 84.124),
  //   // 37.42796133580664, -122.08832357078792),
  //   zoom: 14.4746,
  //   bearing: 192.8334901395799,
  //   tilt: 59.440717697143555,
  // );
  // static const CameraPosition _kLake = CameraPosition(
  //   bearing: 192.8334901395799,
  //   target: LatLng(37.43296265331129, -122.08832357078792),
  //   tilt: 59.440717697143555,
  //   zoom: 19.151926040649414,
  // );
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Select Location"),
      ),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 16.0,
              ),
              myLocationEnabled: true, // ✅ blue dot
              myLocationButtonEnabled: true,
              // onCameraMove: (position) => _kGoogleplex,
              onMapCreated: _onMapCreated,

              //
              //onMapCreated: ,
              // floatingActionButton: FloatingActionButton.extended(
              //   onPressed: _goToTheLake,
              //   label: const Text('To the lake!'),
              //   icon: const Icon(Icons.directions_boat),
            ),
    );
  }
}

//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
// }
