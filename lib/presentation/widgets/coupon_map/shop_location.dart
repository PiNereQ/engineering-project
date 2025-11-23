import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:proj_inz/core/theme.dart';

class ShopLocation extends StatelessWidget {
  final bool active;

  const ShopLocation({
    super.key,
    this.active = false,
  });

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
        color: active ? AppColors.notificationDot : AppColors.primaryButtonPressed,
        size: 38,
        fontWeight: FontWeight.w100,
        shadows: const [Shadow(color: Colors.black, offset: Offset(3, 2))],
      ),
    );
  }
}