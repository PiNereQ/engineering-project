import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class NavbarItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool hasBadge;
  final VoidCallback? onTap;

  const NavbarItem({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.hasBadge,
    this.onTap,
  });

  @override
  State<NavbarItem> createState() => _NavbarItemState();
}

class _NavbarItemState extends State<NavbarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (TapDownDetails details) =>
          setState(() => _isPressed = true),
      onTapCancel: () => setState(() => _isPressed = false),
      onTapUp: (TapUpDetails details) async {
        await Future.delayed(const Duration(milliseconds: 80));
        if (mounted) {
          setState(() {
            _isPressed = false;
          });
        }
      },
      child: SizedBox(
        width: 65,
        child: Column(
          spacing: 6,
          children: [
            Stack(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color:
                        widget.isSelected
                            ? AppColors.primaryButton
                            : (_isPressed
                                ? AppColors.primaryButton
                                : AppColors.surface),
                    borderRadius: BorderRadius.circular(1000),
                    border: Border.all(color: AppColors.textPrimary, width: 2),
                    boxShadow:
                        widget.isSelected || _isPressed
                            ? []
                        : [
                            const BoxShadow(
                              color: AppColors.textPrimary,
                              offset: Offset(2, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Icon(
                      widget.icon,
                      color:
                          widget.isSelected
                              ? AppColors.primaryButtonDark
                              : (_isPressed
                                  ? AppColors.primaryButtonDark
                                  : AppColors.textPrimary),
                      size: 20,
                    ),
                  ),
                ),
                if (widget.hasBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.notificationDot,
                        borderRadius: BorderRadius.circular(1000),
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              widget.label,
              style: const TextStyle(fontSize: 14, fontFamily: 'Itim'),
              strutStyle: const StrutStyle(forceStrutHeight: true, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}
