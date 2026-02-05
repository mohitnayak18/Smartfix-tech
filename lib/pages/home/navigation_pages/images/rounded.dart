import 'package:flutter/material.dart';

class Roundedimage extends StatelessWidget {
  const Roundedimage({
    super.key,
    this.width,
    this.height ,  
    required this.imageUrl,
    this.applyImageRadius = true,
    this.border,
    this.backgroundColor = Colors.transparent,
    this.fit = BoxFit.contain,
    this.padding,
    this.isNetworkImage = false,
    this.onpressed,
    this.borderRadius = 12,
  });

  final double? width, height;
  final String? imageUrl; 
  final bool applyImageRadius;
  final BoxBorder? border;
  final Color backgroundColor;
  final BoxFit fit;
  final EdgeInsetsGeometry? padding;
  final bool isNetworkImage;
  final VoidCallback? onpressed;
  final double borderRadius ;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onpressed,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: border,
        borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: ClipRRect(
          borderRadius: applyImageRadius? BorderRadius.circular(borderRadius) : BorderRadius.zero,
          child: Image(
            fit: fit,image: isNetworkImage? NetworkImage(imageUrl!) :AssetImage(imageUrl!) as ImageProvider ,
            //image: AssetImage('assets/images/borderimg3.png'),
            
            //fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
