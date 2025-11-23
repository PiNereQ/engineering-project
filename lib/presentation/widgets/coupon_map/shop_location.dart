import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';

class ShopLocation extends StatelessWidget {
  const ShopLocation({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedIcon(
      decoration: IconDecoration(
        border: IconBorder(
          color: Colors.black,
          width: 4,
        ),
      ),
      icon: Icon(
        Icons.location_on_rounded,
        color: Colors.red,
        size: 38,
        fontWeight: FontWeight.w100,
        shadows: [Shadow(color: Colors.black, offset: Offset(3, 2))],
      ),
    );
  }
}