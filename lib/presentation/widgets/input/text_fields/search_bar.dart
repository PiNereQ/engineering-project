import 'package:flutter/material.dart';

class SearchBarWide extends StatelessWidget {
  final double width;
  final double fontSize;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSubmitted;

  const SearchBarWide({
    super.key,
    this.width = double.infinity,
    this.fontSize = 18,
    this.hintText = 'Wyszukaj...',
    this.controller,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0xFF000000),
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          )
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Itim',
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 5),
        ),
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
