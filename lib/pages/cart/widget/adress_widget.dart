import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location_screen.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:smartfixTech/utils/utils.dart';

class AdressWidget extends StatelessWidget {
  const AdressWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
              // 📍 Modern icon
              Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
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
                onPressed: () {
                  Get.to(() => GetLocationScreen());
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

          const SizedBox(height: 10),

          // 📍 Address text
          const Text(
            'Nuagaon, Vijaya Vihar, Lingipur, Bhubaneswar, Odisha, 751002',
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}
