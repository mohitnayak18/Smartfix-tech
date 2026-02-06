import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/home/home_controller.dart';
import 'package:smartfixTech/pages/order/order_listscreen.dart';

const _appBarTitleStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: Colors.white,
  letterSpacing: 0.5,
);

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});
  // final CartController cartController = Get.put(CartController());
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      //  AppBar(
      //   automaticallyImplyLeading: true,
      //   toolbarHeight: 80,
      //   backgroundColor: Theme.of(context).primaryColor,
      //   title: Text("My Account"),
      //   titleTextStyle: TextStyle(
      //     height: 2.8,
      //     fontWeight: FontWeight.bold,
      //     fontSize: 18,
      //   ),
      // ),
      body: SingleChildScrollView(
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
                _listItem(Icons.notifications, "My Notifications (1)"),
                _listItem(Icons.list_alt, "My List"),
                _listItem(Icons.location_on, "Delivery Addresses"),
                _listItem(Icons.credit_card, "PAN Card Information"),
              ],
            ),

            _sectionTile(
              title: "Payment Modes",
              children: [
                _listItem(Icons.account_balance_wallet, "Saved Wallets"),
                _listItem(Icons.credit_card, "Saved Cards"),
              ],
            ),

            _sectionTile(
              title: "Help & Support",
              children: [
                _listItem(Icons.support_agent, "Customer Support"),
                _listItem(Icons.assignment_return, "Returns & Refunds"),
              ],
            ),

            _sectionTile(
              title: "Offer & Discounts",
              children: [_listItem(Icons.local_offer, "Available Offers")],
            ),

            _sectionTile(
              title: "More Information",
              children: [
                _listItem(Icons.info, "About App"),
                _listItem(Icons.policy, "Legal Information"),
              ],
            ),

            const SizedBox(height: 8),

            _logoutTile(context),

            const SizedBox(height: 30),
            const Text(
              "App Version 1.0.0",
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
      // actions: [_buildClearCartButton(cartCtrl)],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
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
        const Text("My Account", style: _appBarTitleStyle),
      ],
    );
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
            color: const Color.fromARGB(255, 16, 15, 15).withOpacity(0.05),
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
                  GestureDetector(
                    onTap: () {
                      Dialog();
                      // TODO: Navigate to Edit Profile Screen
                    },
                    child: Text(
                      "Edit Profile",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
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
            // Get.toNamed('/OrderDetails',arguments: Order);
          }),

          _quickItem(context, Icons.discount, "Coupons", () {
            Get.snackbar("Coming Soon", "Coupons feature coming soon");
          }),

          _quickItem(context, Icons.help, "Help", () {
            Get.snackbar("Help", "Customer support coming soon");
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
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(color: Colors.white24),
      child: ExpansionTile(
        shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        // collapsedShape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        iconColor: Colors.teal,
        // backgroundColor: Colors.teal.shade100,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: children,
      ),
    );
  }

  Widget _listItem(IconData icon, String text) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(text),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {},
    );
  }

  Widget _logoutTile(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        leading: const Icon(Icons.power_settings_new, color: Colors.teal),
        title: const Text("Sign Out"),
        onTap: () {
          Get.defaultDialog(
            backgroundColor: Colors.white,
            title: "Logout",
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
