import 'package:flutter/material.dart';

class Verticalimage extends StatelessWidget {
  const Verticalimage({
    super.key,
    required this.item,
  });

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        right: 8.0,
      ),
      child: InkWell(
        onTap: () => item['onTap'](),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          //mainAxisSize: MainAxisSize.min,
          //spacing: 0,
          children: [
            Container(
              width: 56,
              height: 56,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  item['icon'],
                  color: item['color'],
                ),
              ),
            ),
            SizedBox(height: 4),
            Text(
              item['title'],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textWidthBasis:
                  TextWidthBasis.longestLine,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
