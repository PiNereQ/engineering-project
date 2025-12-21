import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class CustomFollowButton extends StatefulWidget {
  final double _size;
  final VoidCallback onTap;
  final bool isPressed;

  const CustomFollowButton._({
    super.key,
    required double size,
    required this.onTap,
    required this.isPressed,
  }) : _size = size;

  factory CustomFollowButton({
    Key? key,
    required VoidCallback onTap,
    bool isPressed = false,
  }) {
    return CustomFollowButton._(
      key: key,
      onTap: onTap,
      size: 48,
      isPressed: isPressed,
    );
  }

  factory CustomFollowButton.small({
    Key? key,
    required VoidCallback onTap,
    bool isPressed = false,
  }) {
    return CustomFollowButton._(
      key: key,
      onTap: onTap,
      size: 36,
      isPressed: isPressed,
    );
  }

  @override
  State<CustomFollowButton> createState() => _CustomFollowButtonState();
}


class _CustomFollowButtonState extends State<CustomFollowButton> {
  late bool _isPressed;

  @override
  void initState() {
    super.initState();
    _isPressed = widget.isPressed;
  }

  @override
  void didUpdateWidget(covariant CustomFollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isPressed != widget.isPressed) {
      _isPressed = widget.isPressed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
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
              color: _isPressed ? AppColors.notificationDot : AppColors.surface,
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
                    Icons.bookmark,
                    color: _isPressed ? AppColors.surface : AppColors.notificationDot,
                  )
                : SizedBox(
                  width: 18,
                  height: 18,
                  child: FittedBox(
                    child: Icon(
                        Icons.bookmark,
                        color: _isPressed ? AppColors.surface : AppColors.notificationDot,
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