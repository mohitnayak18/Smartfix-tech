import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/brands/brands.dart';
import 'package:smartfixTech/pages/home/navigation_pages/home/product/product_vertical.dart';
import 'package:smartfixTech/pages/home/navigation_pages/home/widgets/home_appbar.dart';
import 'package:smartfixTech/pages/home/widgets/Search_Screen.dart';
//import 'package:smartfixapp/pages/home/navigation_pages/home/widgets/promoslider.dart';
import 'package:smartfixTech/pages/home/widgets/baneer_view.dart';
import 'package:smartfixTech/pages/home/widgets/gridlayout.dart';
import 'package:smartfixTech/pages/home/widgets/hprimary_header_container.dart';
import 'package:smartfixTech/pages/home/widgets/search_contanier.dart';
import 'package:smartfixTech/pages/home/widgets/section_heading.dart';
import 'package:smartfixTech/pages/home/widgets/vertical_image.dart';
import 'package:smartfixTech/pages/store/store_screen.dart';
import 'package:smartfixTech/theme/dimens.dart';

class HomeDashboard extends StatefulWidget {
  final Service = 'title';
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  //final carousel.CarouselController _controller = carousel.CarouselController();
  final List<Map<String, dynamic>> services = [
    {
      'title': 'Screen Repair',
      'icon': Icons.phone_android,
      'color': Colors.black,
      'onTap': () {
        // this is pass
        //      final data = docs[index].data();

        // Get.to(() => ProductcardVertical(
        //       id: data.id,
        //       title: data['title'],
        //       price: data['price'],
        //       offer: data['offer'],
        //       imageUrl: data['image'],
        //       isVerified: data['isVerified'] ?? false,
        //     ));
        // Navigator.push(
        //             context,
        //             MaterialPageRoute(builder: (context) => SecondScreen()),
        //   );
        print("Screen Repair clicked");
      },
    },
    {
      'title': 'Battery Repair',
      'icon': Icons.battery_charging_full,
      'color': Colors.black,
      'onTap': () {
        print("Battery Repair clicked");
      },
    },
    {
      'title': 'Software Repair',
      'icon': Icons.build,
      'color': Colors.black,
      'onTap': () {
        print("Software Repair clicked");
      },
    },
    {
      'title': 'Camera Repair',
      'icon': Icons.camera_alt,
      'color': Colors.black,
      'onTap': () {
        print("Camera Repair clicked");
      },
    },
    {
      'title': 'Charging Port',
      'icon': Icons.power,
      'color': Colors.black,
      'onTap': () {
        print("Charging Port clicked");
      },
    },
    {
      'title': 'Accessories',
      'icon': Icons.settings_remote,
      'color': Colors.black,
      'onTap': () {
        print("Accessories clicked");
      },
    },
  ];

  @override
  // Source - https://stackoverflow.com/q
  // Posted by wawa, modified by community. See post 'Timeline' for change history
  // Retrieved 2026-01-25, License - CC BY-SA 3.0
  @override
  void initState() {
    log('homeinitstate');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Get.put(BannerController(),
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        // padding: EdgeInsets.all(200),
        child: Column(
          children: [
            HomePrimaryHeaderContainer(
              // Dimens.edgeInsets16_36_16_10
              child: Padding(
                padding: EdgeInsets.only(top: 31, bottom: 8, left: 0, right: 2),
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
                      padding: EdgeInsets.only(right: 4, left: 20, top: 2),
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
                            height: Dimens
                                .seventyEight, // Increased height to accommodate title
                            child: ListView.builder(
                              padding: EdgeInsets.only(right: 10),
                              shrinkWrap: true,
                              itemCount: services.length,
                              physics: const AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (_, index) {
                                final item = services[index];
                                return Verticalimage(item: item);
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
                  BaneerView(),
                  Dimens.boxHeight25,
                  Sectionheading(
                    textstyle: FontSize.larger.toString(),
                    title: 'recommended Products'.tr,
                    onPressed: () {
                      Get.to(() => StoreScreen());
                    },
                    textColor: Colors.black,
                    showActionButton: false,
                  ),
                  // Dimens.boxHeight,
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
