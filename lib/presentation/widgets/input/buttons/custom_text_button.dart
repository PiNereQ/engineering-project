import 'package:flutter/material.dart';

class CustomTextButton extends StatefulWidget {
  final double? height;
  final double? width;
  final double fontSize;
  final String label;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double minWidth;

  const CustomTextButton({
    super.key,
    this.height,
    this.width,
    this.fontSize = 18,
    required this.label,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.minWidth = 132,
  });

  factory CustomTextButton.small({
    Key? key,
    double? height,
    double? width,
    double fontSize = 14,
    required String label,
    required VoidCallback onTap,
  }) {
    return CustomTextButton(
      key: key,
      height: height,
      width: width,
      fontSize: fontSize,
      label: label,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      minWidth: 95,
    );
  }

  factory CustomTextButton.icon({
    Key? key,
    double? height,
    double? width,
    double fontSize = 18,
    required String label,
    required VoidCallback onTap,
    required Widget icon,
    double iconSize = 24,
  }) {
    return _CustomTextButtonWithIcon(
      key: key,
      height: height,
      width: width,
      fontSize: fontSize,
      label: label,
      onTap: onTap,
      icon: icon,
      iconSize: iconSize,
    );
  }

  factory CustomTextButton.iconSmall({
    Key? key,
    double? height,
    double? width,
    double fontSize = 14,
    required String label,
    required VoidCallback onTap,
    required Widget icon,
    double iconSize = 16,
  }) {
    return _CustomTextButtonWithIcon(
      key: key,
      height: height,
      width: width,
      fontSize: fontSize,
      label: label,
      onTap: onTap,
      icon: icon,
      iconSize: iconSize,
      spacing: 6,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      minWidth: 95
    );
  }

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 80));
          if (mounted) setState(() => _isPressed = false);
        },
        child: Container(
          padding: _isPressed
              ? const EdgeInsets.only(top: 4, left: 4)
              : const EdgeInsets.only(right: 4, bottom: 4),
          child: Container(
            height: widget.height,
            width: widget.width,
            constraints: const BoxConstraints(minWidth: 132),
            padding: widget.padding,
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

class _CustomTextButtonWithIcon extends CustomTextButton {
  final Widget icon;
  final double? iconSize;
  final double spacing;

  const _CustomTextButtonWithIcon({
    super.key,
    super.height,
    super.width,
    super.fontSize,
    required super.label,
    required super.onTap,
    required this.icon,
    this.iconSize,
    this.spacing = 10,
    super.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    super.minWidth = 132,
  });

  @override
  State<CustomTextButton> createState() => _CustomTextButtonWithIconState();
}

class _CustomTextButtonWithIconState extends State<_CustomTextButtonWithIcon> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) async {
          await Future.delayed(const Duration(milliseconds: 80));
          if (mounted) setState(() => _isPressed = false);
        },
        child: Container(
          padding: _isPressed
              ? const EdgeInsets.only(top: 4, left: 4)
              : const EdgeInsets.only(right: 4, bottom: 4),
          child: Container(
            height: widget.height,
            width: widget.width,
            constraints: const BoxConstraints(minWidth: 132),
            padding: widget.padding,
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
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: widget.spacing,
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
                SizedBox(
                  width: widget.iconSize,
                  height: widget.iconSize,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: widget.icon,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}