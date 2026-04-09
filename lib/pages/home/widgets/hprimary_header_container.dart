import 'package:smartfixTech/pages/home/widgets/curved_edge_widget.dart';
import 'package:smartfixTech/pages/home/widgets/home_circular_contanier.dart';
import 'package:flutter/material.dart';

class HomePrimaryHeaderContainer extends StatelessWidget {
  const HomePrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height = 388,
    this.backgroundColor,
    this.gradientColors,
  });

  final Widget child;
  final double height;
  final Color? backgroundColor;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default gradient colors if not provided
    final List<Color> colors =
        gradientColors ??
        [
          const Color(0xFF4158D0), // Purple Blue
          const Color(0xFFC850C0), // Pink
          const Color(0xFFFFCC70), 
          // Golden
        ];

    return HomeCurvedEdgeWidget(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
            stops: const [0.0, 0.5, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.3),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated background circles
            ..._buildBackgroundCircles(context),

            // Content
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildBackgroundCircles(BuildContext context) {
    return [
      // Large glowing circle - top right
      Positioned(
        top: -height * 0.25,
        right: -height * 0.15,
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 3),
          tween: Tween<double>(begin: 0.8, end: 1.2),
          curve: Curves.easeInOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                width: height * 0.6,
                height: height * 0.6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),

      // Medium circle - bottom left
      Positioned(
        bottom: -height * 0.15,
        left: -height * 0.2,
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 4),
          tween: Tween<double>(begin: 1.0, end: 1.4),
          curve: Curves.easeInOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: CircularContainer(
                width: height * 0.4,
                height: height * 0.4,
                backgroundcolor: Colors.white.withOpacity(0.1),
                borderColor: Colors.white.withOpacity(0.15),
                borderWidth: 2,
              ),
            );
          },
        ),
      ),

      // Small circle - middle right
      Positioned(
        top: height * 0.3,
        right: -height * 0.1,
        child: TweenAnimationBuilder(
          duration: const Duration(seconds: 5),
          tween: Tween<double>(begin: 0.6, end: 1.0),
          curve: Curves.easeInOut,
          builder: (context, double scale, child) {
            return Transform.scale(
              scale: scale,
              child: CircularContainer(
                width: height * 0.25,
                height: height * 0.25,
                backgroundcolor: Colors.white.withOpacity(0.15),
                borderColor: Colors.white.withOpacity(0.2),
                borderWidth: 3,
              ),
            );
          },
        ),
      ),

      // Tiny decorative circles
      Positioned(
        top: height * 0.1,
        left: height * 0.1,
        child: CircularContainer(
          width: 8,
          height: 8,
          backgroundcolor: Colors.white.withOpacity(0.4),
        ),
      ),
      Positioned(
        bottom: height * 0.2,
        right: height * 0.15,
        child: CircularContainer(
          width: 12,
          height: 12,
          backgroundcolor: Colors.white.withOpacity(0.3),
        ),
      ),
    ];
  }
}
