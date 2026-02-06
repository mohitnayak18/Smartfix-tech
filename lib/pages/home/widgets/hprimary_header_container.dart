import 'package:smartfixTech/pages/home/widgets/curved_edge_widget.dart';
import 'package:smartfixTech/pages/home/widgets/home_circular_contanier.dart';
import 'package:flutter/material.dart';

class HomePrimaryHeaderContainer extends StatelessWidget {
  const HomePrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height = 360,
    this.backgroundColor,
  });

  final Widget child;
  final double height;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = backgroundColor ?? theme.primaryColor;

    return HomeCurvedEdgeWidget(
      child: Container(
        color: color,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              // Large background circle
              Positioned(
                top: -height * 0.416, // -150/360 ≈ 0.416
                right: -height * 0.794, // -250/360 ≈ 0.694
                child: CircularContainer(
                  backgroundcolor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.2),
                ),
              ),
              // Medium background circle
              Positioned(
                top: height * 0.278, // 100/360 ≈ 0.278
                right: -height * 0.833, // -300/360 ≈ 0.833
                child: CircularContainer(
                  backgroundcolor: Theme.of(
                    context,
                  ).colorScheme.surface.withOpacity(0.1),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
