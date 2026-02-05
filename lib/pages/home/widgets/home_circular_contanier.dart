import 'package:flutter/material.dart';

class CircularContainer extends StatelessWidget {
  const CircularContainer({

    super.key,
    this.child,
    this.height=400,
    this.width= 400, 
    this.radius = 400,
    this.margin,
    this.padding = 0,
    this.backgroundcolor,
  });
    

  final double? height;
  final double? width ;
  final double radius;
  final double padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color? backgroundcolor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding:  EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: backgroundcolor ?? Theme.of(context).primaryColor,
      ),
      child: child,
    );
  }
}