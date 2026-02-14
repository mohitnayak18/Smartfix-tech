import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location_controller.dart';

void showSaveAddressDialog(String address) {
  final GetLocationController controller = Get.find<GetLocationController>();

  final phoneCtrl = TextEditingController();
  String selectedLabel = 'Home';

  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text("Save address as"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LABELS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Home', 'Work', 'Other'].map((label) {
              return ChoiceChip(
                label: Text(label),
                selected: selectedLabel == label,
                onSelected: (_) {
                  selectedLabel = label;
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          TextField(
            controller: phoneCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: "Phone number"),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: () async {
            await controller.saveAddress(
              address: address,
              label: selectedLabel,
              phone: phoneCtrl.text,
            );
            Get.back();
            Get.back(); // close get location screen
          },
          child: const Text("Save"),
        ),
      ],
    ),
  );
}
