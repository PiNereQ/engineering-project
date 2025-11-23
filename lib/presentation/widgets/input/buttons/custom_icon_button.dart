import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomIconButton extends StatefulWidget {
  final double size;
  final Widget icon;
  final VoidCallback onTap;

  const CustomIconButton._({
    super.key,
    required this.size,
    required this.icon,
    required this.onTap,
  });

  factory CustomIconButton({
    Key? key,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return CustomIconButton._(
      key: key,
      icon: icon,
      onTap: onTap,
      size: 48,
    );
  }

  factory CustomIconButton.small({
    Key? key,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return CustomIconButton._(
      key: key,
      icon: SizedBox(
        width: 18,
        height: 18,
        child: FittedBox(
          child: icon,
        ),
      ),
      onTap: onTap,
      size: 36,
    );
  }

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}
  
class _CustomIconButtonState extends State<CustomIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (TapDownDetails details) => (setState(() =>(_isPressed = true))),
      onTapCancel: () => (setState(() =>(_isPressed = false))),
      onTapUp: (TapUpDetails details) async {
        await Future.delayed(const Duration(milliseconds: 80));
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      child: Container(
        padding: _isPressed
            ? const EdgeInsets.only(top: 3, left: 3)
            : const EdgeInsets.only(right: 3, bottom: 3),
        child: Center(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: ShapeDecoration(
              color: _isPressed ? AppColors.primaryButtonPressed : AppColors.surface,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1000),
              ),
              shadows: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.textPrimary,
                        blurRadius: 0,
                        offset: Offset(widget.size == 36 ? 2 : 3, widget.size == 36 ? 2 : 3),
                        spreadRadius: 0,
                      )
                    ],
            ),
            child: Center(
              child: widget.icon,
            ),
          ),
        ),
      ),
    );
  }
}