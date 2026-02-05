import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarwidget extends StatelessWidget implements PreferredSizeWidget {
  const AppBarwidget({
    super.key,
    this.title,
    this.showBackArrow = false,
    this.actions,
    this.leadingIcon,
    this.onLeadingIconPressed,

  });

  final Widget? title;
  final bool showBackArrow;
  final List<Widget>? actions;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingIconPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: showBackArrow
            ? IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_left),)
            :leadingIcon != null
                ? IconButton(
                    onPressed: onLeadingIconPressed,
                    icon: Icon(leadingIcon),
                  )
                : null,
        actions: actions,
        title: title,
      ),
    );
  }
  
}