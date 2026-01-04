import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class SearchBarWide extends StatelessWidget {
  final double width;
  final double fontSize;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  const SearchBarWide({
    super.key,
    this.width = double.infinity,
    this.fontSize = 18,
    this.hintText = 'Wyszukaj...',
    this.controller,
    this.focusNode,
    this.onSubmitted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: TextStyle(
                fontSize: fontSize,
                fontFamily: 'Itim',
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 5),
              ),
              onSubmitted: onSubmitted,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
            ),
          ),
          Icon(
            Icons.search,
            color: AppColors.textPrimary,
          ),
        ],
      ),
    );
  }
}
