import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/theme/dimens.dart';
import 'package:smartfixTech/utils/asset_constants.dart';

import 'splash.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _bottomTextFade;
  
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Logo animations
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    
    // Title slide animation
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOutBack),
      ),
    );
    
    // Subtitle fade animation
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.8, curve: Curves.easeIn),
      ),
    );
    
    // Bottom text fade animation
    _bottomTextFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 0.9, curve: Curves.easeIn),
      ),
    );
    
    _isInitialized = true;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (controller) {
        if (!_isInitialized) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AssetConstants.splashLogo, width: 200, height: 200),
                  const SizedBox(height: 30),
                  const Text(
                    'SmartFixTech',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Professional Repair Services',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Quality Service · Fast Response · Best Price',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AssetConstants.splashLogo,
                            width: 180,
                            height: 180,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),
                
                // Animated Title - SmartFixTech
                AnimatedBuilder(
                  animation: _titleSlide,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _titleSlide.value,
                      child: Column(
                        children: [
                          const Text(
                            'SmartFix Technology',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A237E),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 60,
                            height: 2,
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Animated Subtitle - Professional Repair Services
                AnimatedBuilder(
                  animation: _subtitleFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _subtitleFade.value,
                      child: const Text(
                        'Professional Repair Services',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 12),
                
                // Animated Bottom Text - Quality Service · Fast Response · Best Price
                AnimatedBuilder(
                  animation: _bottomTextFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _bottomTextFade.value,
                      child: const Text(
                        'Quality Service · Fast Response · Best Price',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 50),
                
                // Optional subtle loading indicator
                AnimatedBuilder(
                  animation: _bottomTextFade,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _bottomTextFade.value * 0.6,
                      child: const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 126, 26, 101)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}