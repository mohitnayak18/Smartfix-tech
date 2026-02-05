import 'package:flutter/material.dart';

class TAppbar extends StatelessWidget implements PreferredSizeWidget {
  const TAppbar({
    super.key,
    this.title,
    this.actions,
    this.leadingIcon,
    this.leadingOnPressed,
    this.showBackArrow = false,
    required Color backgroundColor,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnPressed;
  //final String? title;
  // final Color backgroundColor;
  // final double elevation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: AppBar(
        toolbarHeight: 50,

        automaticallyImplyLeading: false,
        // leading: showBackArrow
        //     ? IconButton(
        //         onPressed: () => Get.back(),
        //         icon: Icon(Icons.arrow_left),
        //       )
        //     : leadingIcon != null
        //     ? IconButton(onPressed: leadingOnPressed, icon: Icon(leadingIcon))
        //     : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
