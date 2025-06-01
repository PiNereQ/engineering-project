import 'package:flutter/material.dart';

class SimpleButton extends StatelessWidget {
  final double height;
  final double width;
  final double fontSize;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SimpleButton({
    super.key,
    required this.height,
    required this.width,
    required this.fontSize,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: isSelected
            ? const EdgeInsets.only(top: 4, left: 4)
            : const EdgeInsets.only(right: 4, bottom: 4),
        child: Center(
          child: Container(
            width: double.infinity,
            decoration: ShapeDecoration(
              color: isSelected ? const Color(0xFFB2B2B2) : Colors.white,
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2),
                borderRadius: BorderRadius.circular(1000),
              ),
              shadows: isSelected
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
                label,
                style: TextStyle(
                  color: isSelected ? const Color(0xFF646464) : Colors.black,
                  fontSize: fontSize,
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