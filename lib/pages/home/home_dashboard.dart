import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/home/navigation_pages/home/widgets/home_appbar.dart';
import 'package:smartfixTech/pages/home/widgets/Search_Screen.dart';
import 'package:smartfixTech/pages/home/widgets/baneer_view.dart';
import 'package:smartfixTech/pages/home/widgets/gridlayout.dart';
import 'package:smartfixTech/pages/home/widgets/hprimary_header_container.dart';
import 'package:smartfixTech/pages/home/widgets/search_contanier.dart';
import 'package:smartfixTech/pages/home/widgets/section_heading.dart';
import 'package:smartfixTech/pages/home/widgets/serviceresult.dart';
import 'package:smartfixTech/pages/home/widgets/vertical_image.dart';
import 'package:smartfixTech/theme/dimens.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  // Fixed services list - all have onTap
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Screen Repair',
      'icon': Icons.phone_android,
      'color': Colors.black,
      'onTap': () {
        print("Screen Repair clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Screen Repair'));
      },
    },
    {
      'title': 'Battery Repair',
      'icon': Icons.battery_charging_full,
      'color': Colors.black,
      'onTap': () {
        print("Battery Repair clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Battery Repair'));
      },
    },
    {
      'title': 'Software Repair',
      'icon': Icons.build,
      'color': Colors.black,
      'onTap': () {
        print("Software Repair clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Software Repair'));
      },
    },
    {
      'title': 'Camera Repair',
      'icon': Icons.camera_alt,
      'color': Colors.black,
      'onTap': () {
        print("Camera Repair clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Camera Repair'));
      },
    },
    {
      'title': 'Charging Port',
      'icon': Icons.power,
      'color': Colors.black,
      'onTap': () {
        print("Charging Port clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Charging Port'));
      },
    },
    {
      'title': 'Accessories',
      'icon': Icons.settings_remote,
      'color': Colors.black,
      'onTap': () {
        print("Accessories clicked");
        Get.to(() => ServiceResultScreen(serviceName: 'Accessories'));
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    log('homeinitstate');
    _startAutoScroll();
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _scrollTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_scrollController.hasClients) {
        final double maxScroll = _scrollController.position.maxScrollExtent;
        final double currentScroll = _scrollController.position.pixels;

        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.animateTo(
            currentScroll + 1,
            duration: const Duration(milliseconds: 16),
            curve: Curves.linear,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            HomePrimaryHeaderContainer(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 31,
                  bottom: 8,
                  left: 0,
                  right: 2,
                ),
                child: Column(
                  children: [
                    const Homeappbar(),
                    Dimens.boxHeight15,
                    Searchcontainer(
                      text: "Searchinstore",
                      onTap: () {
                        Get.to(() => const SearchScreen());
                      },
                      icon: Icons.search,
                    ),
                    Dimens.boxHeight20,
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 4,
                        left: 20,
                        top: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Sectionheading(
                            textstyle: FontSize.larger.toString(),
                            title: 'popularServices'.tr,
                            textColor: Colors.white,
                            showActionButton: false,
                          ),
                          Dimens.boxHeight15,
                          SizedBox(
                            height: Dimens.seventyEight,
                            child: ListView.builder(
                              padding: const EdgeInsets.only(right: 10),
                              shrinkWrap: true,
                              itemCount: services.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                final item = services[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Safe call - check if onTap exists
                                    final onTap = item['onTap'];
                                    if (onTap != null &&
                                        onTap is VoidCallback) {
                                      onTap();
                                    } else {
                                      // Fallback navigation
                                      Get.to(
                                        () => ServiceResultScreen(
                                          serviceName: item['title'] as String,
                                        ),
                                      );
                                    }
                                  },
                                  child: Verticalimage(item: item),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  // _buildScrollingAdBanner(),
                  // Dimens.boxHeight20,
                  const BaneerView(),
                  Dimens.boxHeight10,
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 50.0),
                    child: Text(
                      'recommended Products'.tr.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('service')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No Products Found"));
                      }

                      return Gridlayout(
                        docs: snapshot.data!.docs
                            .cast<
                              QueryDocumentSnapshot<Map<String, dynamic>>
                            >(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
