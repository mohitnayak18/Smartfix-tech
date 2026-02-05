import 'package:smartfixapp/pages/home/widgets/curved_edges.dart';
import 'package:flutter/material.dart';

class HomeCurvedEdgeWidget extends StatelessWidget {
  const HomeCurvedEdgeWidget({
    super.key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HomeCustomClipper(),
      child: child,
    );
  }
}