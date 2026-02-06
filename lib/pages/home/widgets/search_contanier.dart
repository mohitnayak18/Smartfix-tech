import 'package:smartfixTech/theme/dimens.dart';
import 'package:flutter/material.dart';


class Searchcontainer extends StatelessWidget {
  const Searchcontainer({
    super.key,
    required this.text,
    this.icon = Icons.search,
    this.showBackground = true,
    this.showBorder = true,
  });

  final String text;
  final IconData icon;
  final bool showBackground;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        width: double.infinity,
        padding: Dimens.edgeInsets12,
        decoration: BoxDecoration(
          color: showBackground
              ? (dark ? Colors.black12 : Colors.white)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: showBorder
              ? Border.all(color: Colors.white)
              : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 20),
            Text(
              text,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
