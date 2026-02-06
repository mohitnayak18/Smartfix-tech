
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import 'package:smartfixTech/navigators/navigators.dart';
import 'package:smartfixTech/utils/asset_constants.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late LiquidController liquidController;
  int page = 0;

  final List<OnboardingContainer> _list = [
    OnboardingContainer(
      image: AssetConstants.onboarding1,
      color: Colors.greenAccent.shade100,
      title: 'onboard1'.tr,
       text: 'textonb1'.tr,
    ),
    OnboardingContainer(
      image: AssetConstants.onboarding2,
      color: Colors.green.shade100,
      title: 'onboard2'.tr,
       text: 'textonb2'.tr,
    ),
    OnboardingContainer(
      image: AssetConstants.onboarding3,
      color: Colors.blue.shade100,
      title: 'onboard3'.tr,
       text: 'textonb3'.tr,
    ),
  ];

  @override
  void initState() {
    super.initState();
    liquidController = LiquidController();
  }

  void pageChangeCallback(int lpage) {
    setState(() {
      page = lpage;
    });
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: page == index ? 12 : 8,
      height: page == index ? 12 : 8,
      decoration: BoxDecoration(
        color: page == index ? Colors.black : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  void _nextPage() {
    if (page == _list.length - 1) {
      RouteManagement.goToLogin();
    } else {
      liquidController.animateToPage(
        page: page + 1,
        duration: 500,
      );
    }
  }

  void _skip() {
    RouteManagement.goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _list[page].color,
      body: Stack(
        children: [
          LiquidSwipe.builder(
            itemCount: _list.length,
            itemBuilder: (context, index) {
              return Container(
                color: _list[index].color,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Lottie.asset(_list[index].image),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Text(
                            _list[index].title,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _list[index].text,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            onPageChangeCallback: pageChangeCallback,
            waveType: WaveType.circularReveal,
            liquidController: liquidController,
            enableLoop: false,
          ),

          // Dots Indicator
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_list.length, _buildDot),
            ),
          ),

          // Skip Button
          Positioned(
            bottom: 40,
            left: 24,
            child: TextButton(
              onPressed: _skip,
              child: Text(
                "Skip".tr,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),

          // Next/Login Button
          Positioned(
            bottom: 40,
            right: 24,
            child: TextButton(
              onPressed: _nextPage,
              child: Text(
                page == _list.length - 1 ? "Login".tr : "Next".tr,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingContainer {
  OnboardingContainer({
    required this.image,
    required this.text,
    required this.title,
    required this.color,
  });

  final String image;
  final String text;
  final String title;
  final Color color;
}
