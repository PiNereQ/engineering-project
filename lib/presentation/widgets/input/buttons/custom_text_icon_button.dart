import 'package:flutter/material.dart';

class CustomTextIconButton extends StatefulWidget {
  final double height;
  final double? width;
  final double fontSize;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const CustomTextIconButton({
    super.key,
    this.height = 48,
    this.width,
    this.fontSize = 18,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<CustomTextIconButton> createState() => _CustomTextIconButtonState();
}
  
class _CustomTextIconButtonState extends State<CustomTextIconButton> {
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
            ? const EdgeInsets.only(top: 4, left: 4)
            : const EdgeInsets.only(right: 4, bottom: 4),
        child: Container(
          width: widget.width,
          height: widget.height,
          constraints: const BoxConstraints(minWidth: 132),
          padding: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: _isPressed ? const Color(0xFF646464) : Colors.black,
                  fontSize: widget.fontSize,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 10,),
              Icon(widget.icon)
            ],
          ),
        ),
      ),
    );
  }
}