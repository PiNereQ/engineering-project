import 'package:flutter/material.dart';
import 'package:icon_decoration/icon_decoration.dart';
import 'package:proj_inz/core/theme.dart';

class ShopLocationPin extends StatefulWidget {
  final bool active;
  final bool selected;

  const ShopLocationPin({
    super.key,
    this.active = false,
    this.selected = false,
  });

  @override
  State<ShopLocationPin> createState() => _ShopLocationPinState();
}

class _ShopLocationPinState extends State<ShopLocationPin>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pinAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pinAnimation = Tween<double>(
      begin: 0.0,
      end: 3.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.selected) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ShopLocationPin oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pinAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_pinAnimation.value),
          child: DecoratedIcon(
            decoration: IconDecoration(
              border: IconBorder(
                color: Colors.black,
                width: 4,
              ),
            ),
            icon: Icon(
              Icons.location_on_rounded,
              color: widget.active
                  ? AppColors.notificationDot
                  : AppColors.primaryButtonPressed,
              size: 38,
              fontWeight: FontWeight.w100,
                shadows: [
                Shadow(
                  color: Colors.black,
                  offset: widget.selected
                    ? Offset(1 + _pinAnimation.value, _pinAnimation.value)
                    : const Offset(3, 2),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}