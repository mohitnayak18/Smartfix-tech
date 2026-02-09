import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/Map_Location/Map_Location_screen.dart';
import 'package:smartfixTech/utils/utils.dart' show AssetConstants;

class GetLocationScreen extends StatefulWidget {
  const GetLocationScreen({super.key});

  @override
  State<GetLocationScreen> createState() => _GetLocationScreenState();
}

class _GetLocationScreenState extends State<GetLocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal.shade50,

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

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextFormField(
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
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

                prefixIconConstraints: const BoxConstraints(
                  minWidth: 44,
                  minHeight: 44,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.blueGrey,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Colors.teal, width: 1.6),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // 📍 Use current location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.to(() => MapLocationScreen());
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
        ],
      ),
    );
  }
}
