import 'package:flutter/material.dart';

class CustomTextButton extends StatefulWidget {
  final double height;
  final double? width;
  final double fontSize;
  final String label;
  final VoidCallback onTap;

  const CustomTextButton({
    super.key,
    this.height = 48,
    this.width,
    this.fontSize = 18,
    required this.label,
    required this.onTap,
  });

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}
  
class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (TapDownDetails details) {
        setState(() {
          _isPressed = true;
        });
      },
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
            ? const EdgeInsets.only(top: 4, left: 4)
            : const EdgeInsets.only(right: 4, bottom: 4),
        child: Center(
          child: Container(
            width: widget.width,
            height: widget.height,
            constraints: const BoxConstraints(minWidth: 132),
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
              child: Text(
                widget.label,
                style: TextStyle(
                  color: _isPressed ? const Color(0xFF646464) : Colors.black,
                  fontSize: widget.fontSize,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}