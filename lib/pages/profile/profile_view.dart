import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/get_loaction.dart/get_location_screen.dart';
import 'package:smartfixTech/pages/home/home_controller.dart';
import 'package:smartfixTech/pages/order/order_listscreen.dart';
import 'package:smartfixTech/pages/profile/widget/about_screen.dart';
import 'package:smartfixTech/pages/profile/widget/legal_screen.dart';
import 'package:smartfixTech/pages/profile/widget/support_screen.dart';
import 'package:url_launcher/url_launcher.dart';

const _appBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  letterSpacing: 0.5,
);

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  final HomeController controller = Get.find<HomeController>();

  // Create a scroll controller
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        controller: _scrollController, // Assign the controller
        child: Column(
          children: [
            const SizedBox(height: 12),

            _profileHeader(context),
            const SizedBox(height: 12),

            _quickActions(context),
            const SizedBox(height: 12),

            _sectionTile(
              title: "My Account",
              children: [
                _listItem(Icons.star_rate, "Rating App", () async {
                  await _launchPlayStore();
                }),

                _listItem(Icons.location_on, "Delivery Addresses", () {
                  Get.to(() => const GetLocationScreen());
                }),
              ],
            ),
            _sectionTile(
              title: "Service Availability",
              children: [
                _listItem(Icons.location_city, "Available Locations", () {
                  Get.bottomSheet(
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          Text(
                            "Available Locations",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 10),

                          // 👉 Kolkata
                          // ExpansionTile(
                          //   leading: Icon(Icons.location_city),
                          //   title: Text("Kolkata"),
                          //   children: [
                          //     ListTile(title: Text("Salt Lake")),
                          //     ListTile(title: Text("New Town")),
                          //     ListTile(title: Text("Howrah")),
                          //     ListTile(title: Text("Dum Dum")),
                          //   ],
                          // ),

                          // 👉 Delhi
                          ExpansionTile(
                            leading: Icon(Icons.location_city),
                            title: Text("Bhubaneswar"),
                            children: [
                              // ListTile(title: Text("Khandagiri")),
                              ListTile(title: Text("Nuagan")),
                              ListTile(title: Text("Patia")),
                            ],
                          ),

                          // 👉 Mumbai
                          // ExpansionTile(
                          //   leading: Icon(Icons.location_city),
                          //   title: Text("Mumbai"),
                          //   children: [
                          //     ListTile(title: Text("Andheri")),
                          //     ListTile(title: Text("Bandra")),
                          //     ListTile(title: Text("Thane")),
                          //   ],
                          // ),

                          // SizedBox(height: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Get.back(),
                            child: Text("Close"),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // _listItem(Icons.my_location, "Check Availability", () {
                //   Get.snackbar(
                //     "Coming Soon",
                //     "Auto location detection coming soon",
                //     snackPosition: SnackPosition.BOTTOM,
                //     backgroundColor: Colors.teal,
                //     colorText: Colors.white,
                //   );
                // }),
              ],
            ),

            _sectionTile(
              title: "Help & Support",
              children: [
                _listItem(Icons.support_agent, "Customer Support", () {
                  Get.to(() => const SupportScreen());
                }),
                _listItem(Icons.assignment_return, "Returns & Refunds", () {
                  Get.to(() => const LegalScreen());
                }),
              ],
            ),

            // _sectionTile(
            //   title: "Offer & Discounts",
            //   children: [
            //     _listItem(Icons.local_offer, "Available Offers", () {
            //       Get.snackbar(
            //         "Coming Soon",
            //         "Offers feature coming soon",
            //         snackPosition: SnackPosition.BOTTOM,
            //         backgroundColor: Colors.teal,
            //         colorText: Colors.white,
            //       );
            //     }),
            //   ],
            // ),
            _sectionTile(
              title: "More Information",
              children: [
                _listItem(Icons.info, "About App", () {
                  Get.to(() => const AboutScreen());
                }),
                _listItem(Icons.policy, "Legal Information", () {
                  Get.to(() => const LegalScreen());
                }),
              ],
            ),

            const SizedBox(height: 8),

            _logoutTile(context),

            const SizedBox(height: 30),
            const Text(
              "App Version 1.0.8",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: _buildAppBarTitle(),
      iconTheme: const IconThemeData(color: Colors.white),
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  Future<void> _launchPlayStore() async {
    final Uri url = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.flutter.smartfixapp&pcampaignid=web_share",
    );

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch Play Store';
    }
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, size: 22, color: Colors.white),
        ),
        const SizedBox(width: 12),

        // Clickable My Account text
        GestureDetector(
          onTap: _scrollToTop, // Call method to scroll to top
          child: const Text("My Account", style: _appBarTitleStyle),
        ),
      ],
    );
  }

  // Method to scroll to top
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Optional: Show a small feedback
      Get.snackbar(
        "Profile",
        "Scrolled to top",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.teal,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    }
  }

  // ---------------- PROFILE HEADER ----------------
  Widget _profileHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: Theme.of(context).primaryColor,
            child: const Icon(Icons.person, color: Colors.white, size: 36),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.userName.value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    controller.phone.value,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 6),
                  // GestureDetector(
                  //   onTap: () {
                  //     Get.snackbar(
                  //       "Coming Soon",
                  //       "Edit profile feature coming soon",
                  //       snackPosition: SnackPosition.BOTTOM,
                  //       backgroundColor: Colors.teal,
                  //       colorText: Colors.white,
                  //     );
                  //   },
                  //   child: Text(
                  //     "Edit Profile",
                  //     style: TextStyle(
                  //       color: Theme.of(context).primaryColor,
                  //       fontSize: 13,
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          // const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _quickActions(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _quickItem(context, Icons.shopping_bag, "Orders", () {
            Get.to(() => OrdersListScreen());
          }),
          _quickItem(context, Icons.home_outlined, "Saved Addresses", () {
            Get.to(() => const GetLocationScreen());
          }),
          _quickItem(context, Icons.help, "Help", () {
            Get.to(() => const SupportScreen());
          }),
        ],
      ),
    );
  }

  Widget _quickItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 28, color: Theme.of(context).primaryColor),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _sectionTile({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(color: Colors.white),
      child: ExpansionTile(
        shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        iconColor: Colors.teal,
        collapsedIconColor: Colors.teal,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: children,
      ),
    );
  }

  Widget _listItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.power_settings_new, color: Colors.teal),
        title: const Text(
          "Sign Out",
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        onTap: () {
          Get.defaultDialog(
            backgroundColor: Colors.white,
            title: "Logout",
            titleStyle: const TextStyle(fontWeight: FontWeight.bold),
            middleText: "Are you sure you want to logout?",
            textConfirm: "Yes",
            textCancel: "No",
            confirmTextColor: Colors.white,
            buttonColor: Theme.of(context).primaryColor,
            onConfirm: () {
              Get.back();
              controller.signOut();
            },
          );
        },
      ),
    );
  }
}
