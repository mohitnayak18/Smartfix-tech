import 'package:smartfixTech/pages/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/profile/profile_view.dart';
import 'package:smartfixTech/pages/store/store_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final homeController = Get.find<HomeController>();

  final Rx<int> selectedIndex = 0.obs;

  final screens = [HomeDashboard(), StoreScreen(), ProfileScreen()];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<HomeController>(
    id: 'home',
    builder: (controller) {
      return Scaffold(
        
        // appBar: AppBar(),
        bottomNavigationBar: Obx(
          () => BottomNavigationBar(
            elevation: 0,
            currentIndex: selectedIndex.value,
            onTap: (index) => selectedIndex.value = index,
            // backgroundColor: darkMode ? Colors.black : Colors.white,
            iconSize: 25,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            selectedIconTheme: IconThemeData(size: 20),
            selectedLabelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
            unselectedItemColor: Colors.grey,
            unselectedFontSize: 12,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined, size: 25),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.storefront, size: 25),
                label: 'Store',
              ),
             
              BottomNavigationBarItem(
                icon: Icon(Icons.person, size: 25),
                label: 'Account',
              ),
            ],
          ),
        ),

        body: Obx(() => screens[selectedIndex.value]),
      );
    },
  );
}
