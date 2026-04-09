import 'package:smartfixTech/pages/home/widgets/curved_edges.dart';
import 'package:flutter/material.dart';

class HomeCurvedEdgeWidget extends StatelessWidget {
  const HomeCurvedEdgeWidget({
    super.key,
    this.child,
    this.curveHeight = 30,
    this.borderRadius = 30,
  });

  final Widget? child;
  final double curveHeight;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: HomeCustomClipper(
        // curveHeight: curveHeight,
        // borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}

// Enhanced Custom Clipper with more control
// class HomeCustomClipper extends CustomClipper<Path> {
//   final double curveHeight;
//   final double borderRadius;

//   HomeCustomClipper({
//     this.curveHeight = 30,
//     this.borderRadius = 30,
//   });

//   @override
//   Path getClip(Size size) {
//     final path = Path();

//     // Start from top-left with rounded corner
//     path.moveTo(0, borderRadius);
//     path.quadraticBezierTo(0, 0, borderRadius, 0);

//     // Top edge
//     path.lineTo(size.width - borderRadius, 0);
//     path.quadraticBezierTo(size.width, 0, size.width, borderRadius);

//     // Right edge
//     path.lineTo(size.width, size.height - borderRadius);

//     // Bottom edge with curved design
//     final firstControlPoint = Offset(size.width * 0.75, size.height);
//     final firstEndPoint = Offset(size.width * 0.5, size.height - curveHeight);
    
//     path.quadraticBezierTo(
//       firstControlPoint.dx,
//       firstControlPoint.dy,
//       firstEndPoint.dx,
//       firstEndPoint.dy,
//     );

//     final secondControlPoint = Offset(size.width * 0.25, size.height - curveHeight * 2);
//     final secondEndPoint = Offset(0, size.height - borderRadius);
    
//     path.quadraticBezierTo(
//       secondControlPoint.dx,
//       secondControlPoint.dy,
//       secondEndPoint.dx,
//       secondEndPoint.dy,
//     );

//     // Left edge
//     path.lineTo(0, borderRadius);

//     path.close();
//     return path;
//   }

//   @override
//   bool shouldReclip(covariant HomeCustomClipper oldClipper) {
//     return oldClipper.curveHeight != curveHeight || 
//            oldClipper.borderRadius != borderRadius;
//   }
// }