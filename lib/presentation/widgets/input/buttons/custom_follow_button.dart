import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomFollowButton extends StatefulWidget {
  final double _size;
  final VoidCallback onTap;

  const CustomFollowButton._({
    super.key,
    required double size,
    required this.onTap,
  }) : _size = size;

  factory CustomFollowButton({
    Key? key,
    required VoidCallback onTap,
  }) {
    return CustomFollowButton._(
      key: key,
      onTap: onTap,
      size: 48,
    );
  }

  factory CustomFollowButton.small({
    Key? key,
    required VoidCallback onTap,
  }) {
    return CustomFollowButton._(
      key: key,
      onTap: onTap,
      size: 36,
    );
  }

  @override
  State<CustomFollowButton> createState() => _CustomFollowButtonState();
}

class _CustomFollowButtonState extends State<CustomFollowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (TapDownDetails details) => (setState(() => (_isPressed = true))),
      onTapCancel: () => (setState(() => (_isPressed = false))),
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
            width: widget._size,
            height: widget._size,
            decoration: ShapeDecoration(
              color: _isPressed ? AppColors.checkIcon : AppColors.surface,
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
                        offset: Offset(widget._size == 36 ? 2 : 3, widget._size == 36 ? 2 : 3),
                        spreadRadius: 0,
                      )
                    ],
            ),
            child: Center(
              child: widget._size == 48
                ? Icon(
                    Icons.favorite,
                    color: _isPressed ? AppColors.surface : AppColors.checkIcon,
                  )
                : SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(
                    child: Icon(
                        Icons.favorite,
                        color: _isPressed ? AppColors.surface : AppColors.checkIcon,
                      ),
                  ),
                )
            ),
          ),
        ),
      ),
    );
  }
}