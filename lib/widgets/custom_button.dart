import 'package:flutter/material.dart';

import 'package:smartfixTech/theme/theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    
    required this.height,
    required this.width,
    required this.title,
    required this.onPress,
  });

  final double height;
  final double width;
  final String title;
  final Function() onPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: TextButton(
        
        onPressed: onPress,
        child: Text(
          title,
          style: TextStyle(
            fontSize: Dimens.sixteen,
            color: Colors.white,
            
          ),
          
        ),
      ),
    );
  }
}
