import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  const CircularContainer({
    super.key,
    this.width = 400,
    this.height = 400,
    this.radius = 400,
    this.padding = 0,
    this.backgroundcolor,
    this.borderColor,
    this.borderWidth = 0,
    this.gradient,
    this.child,
    this.boxShadow,
  });

  final double width;
  final double height;
  final double radius;
  final double padding;
  final Color? backgroundcolor;
  final Color? borderColor;
  final double borderWidth;
  final Gradient? gradient;
  final Widget? child;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundcolor,
        gradient: gradient,
        border: borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color: (backgroundcolor ?? Colors.white).withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
      ),
      child: child,
    );
  }
}
