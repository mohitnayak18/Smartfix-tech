import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/cart/cart_controller.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location_screen.dart';
import 'package:smartfixTech/theme/dimens.dart';

class AddressWidget extends StatefulWidget {
  const AddressWidget({super.key});

  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  final CartController cartCtrl = Get.find<CartController>();

  @override
  void initState() {
    super.initState();
    // Load saved addresses when widget initializes
    cartCtrl.loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Get selected address from controller
      final selectedAddress = cartCtrl.selectedAddress;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top row
            Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getAddressIcon(selectedAddress),
                    color: Colors.teal,
                    size: 20,
                  ),
                ),
                Dimens.boxWidth10,
                const Text(
                  'Delivery to',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final result = await Get.to(() => const GetLocationScreen());
                    if (result != null && result["address"] != null) {
                      // Save to controller instead of local state
                      await cartCtrl.saveAddress(
                        title: result["type"] ?? "Address",
                        address: result["address"],
                        type: result["type"] ?? "Other",
                        lat: result["lat"],
                        lng: result["lng"],
                        distance: result["distance"],
                      );
                    }
                  },
                  child: const Text(
                    'Change',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 📍 Selected Address Card
            if (selectedAddress.isNotEmpty && selectedAddress['address'] != null) ...[
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.teal.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _buildIcon(selectedAddress["type"] ?? "Other"),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      selectedAddress["title"] ?? selectedAddress["type"] ?? "Address",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        "SELECTED",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.teal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  selectedAddress["address"] ?? "",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (selectedAddress["distance"] != null) ...[
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.directions_bike,
                                        size: 14,
                                        color: Colors.teal.shade400,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${selectedAddress["distance"].toStringAsFixed(1)} km away',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.teal.shade600,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Teal bottom indicator
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Show saved addresses if available
              if (cartCtrl.addresses.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    "Saved Addresses",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...cartCtrl.addresses.map((address) {
                  final isSelected = cartCtrl.selectedAddress['id'] == address['id'];
                  return GestureDetector(
                    onTap: () {
                      cartCtrl.selectAddress(address);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.teal.withOpacity(0.05) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.teal : Colors.grey.shade200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          _buildIcon(address["type"] ?? "Other"),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      address["title"] ?? address["type"] ?? "Address",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (address["isDefault"] == true) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Text(
                                          "DEFAULT",
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  address["address"] ?? "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.teal,
                              size: 20,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 8),
              ],

              // Add new address option
              InkWell(
                onTap: () async {
                  final result = await Get.to(() => const GetLocationScreen());
                  if (result != null && result["address"] != null) {
                    await cartCtrl.saveAddress(
                      title: result["type"] ?? "Address",
                      address: result["address"],
                      type: result["type"] ?? "Other",
                      lat: result["lat"],
                      lng: result["lng"],
                      distance: result["distance"],
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.teal.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_location_alt,
                        color: Colors.teal.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add New Address',
                        style: TextStyle(
                          color: Colors.teal.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildIcon(String type) {
    Color color = Colors.teal;
    IconData icon = Icons.location_on;

    switch (type.toLowerCase()) {
      case "home":
        color = Colors.blue;
        icon = Icons.home;
        break;
      case "work":
        color = Colors.black54;
        icon = Icons.work;
        break;
      case "other":
        color = Colors.teal;
        icon = Icons.location_on;
        break;
      default:
        color = Colors.teal;
        icon = Icons.location_on;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }

  IconData _getAddressIcon(Map<String, dynamic>? address) {
    if (address == null || address.isEmpty) return Icons.location_on_outlined;

    final type = address["type"]?.toString().toLowerCase() ?? '';

    switch (type) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }
}