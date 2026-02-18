import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smartfixTech/pages/pages.dart';
import 'package:smartfixTech/utils/asset_constants.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.05),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.05, end: 0.95),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.9, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.9), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _rotation = Tween<double>(
      begin: -0.01,
      end: 0.01,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (_) {
        return Scaffold(
          body: Stack(
            children: [
              // Animated gradient background
              AnimatedContainer(
                duration: const Duration(seconds: 2),
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    center: Alignment.center,
                    colors: [
                      const Color(0xFF1DB9AE).withOpacity(0.9),
                      const Color(0xFF0F8F87).withOpacity(0.95),
                      const Color(0xFF0A6E69).withOpacity(0.9),
                      const Color(0xFF1DB9AE).withOpacity(0.9),
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                    transform: GradientRotation(_controller.value * 6.28),
                  ),
                ),
              ),

              // Subtle floating particles
              Positioned.fill(
                child: CustomPaint(
                  painter: _ParticlePainter(animation: _controller),
                ),
              ),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (_, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..scale(_scale.value)
                        ..rotateZ(_rotation.value),
                      alignment: Alignment.center,
                      child: Opacity(opacity: _opacity.value, child: child),
                    );
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing logo container
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow effect
                          Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.05),
                                  Colors.transparent,
                                ],
                                stops: const [0.1, 0.5, 1.0],
                              ),
                            ),
                          ),

                          // Logo container with shadow and border
                          Container(
                            width: 180,
                            height: 180,
                            padding: const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0A6E69,
                                  ).withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: const Offset(0, 15),
                                ),
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: -5,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: _buildLogo(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // App name with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Colors.white, Color(0xFFE6F7F5)],
                          ).createShader(bounds);
                        },
                        child: Text(
                          'smartfixnm'.tr.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: const Color.fromARGB(
                                  255,
                                  245,
                                  243,
                                  243,
                                ).withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tagline with fade animation
                      FadeTransition(
                        opacity: Tween<double>(begin: 0, end: 1).animate(
                          CurvedAnimation(
                            parent: _controller,
                            curve: const Interval(
                              0.3,
                              0.7,
                              curve: Curves.easeIn,
                            ),
                          ),
                        ),
                        child: Text(
                          'Technology'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 3,
                          ),
                        ),
                      ),

                      // Loading indicator
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withOpacity(0.8),
                          ),
                          borderRadius: BorderRadius.circular(10),
                          minHeight: 3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo() {
    return Image.asset(AssetConstants.splashLogo);
  }
}

// Particle background painter
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  _ParticlePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 15; i++) {
      final x = (i * 67.3 + animation.value * 100) % size.width;
      final y = (i * 42.7 + animation.value * 50) % size.height;
      final radius = 1.0 + (animation.value * 2);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
