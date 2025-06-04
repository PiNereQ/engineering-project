import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomIconButton extends StatefulWidget {
  final double size;
  final double fontSize;
  final String icon;
  final VoidCallback onTap;

  const CustomIconButton({
    super.key,
    this.size = 48,
    this.fontSize = 18,
    required this.icon,
    required this.onTap,
  });

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
              color: _isPressed ? const Color(0xFFB2B2B2) : Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1000),
              ),
              shadows: _isPressed
                  ? []
                  : [
                      const BoxShadow(
                        color: Color(0xFF000000),
                        blurRadius: 0,
                        offset: Offset(4, 4),
                        spreadRadius: 0,
                      )
                    ],
            ),
            child: Center(
              child: SvgPicture.asset(
                widget.icon,
                colorFilter: ColorFilter.mode(
                  _isPressed ? const Color(0xFF646464) : Colors.black,
                  BlendMode.srcIn
                ),
                height: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}