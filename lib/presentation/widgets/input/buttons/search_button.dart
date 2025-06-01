import 'package:flutter/material.dart';

class SearchButtonWide extends StatelessWidget {
  final double width;
  final double fontSize;
  final String label;
  final VoidCallback onTap;

  const SearchButtonWide({
    super.key,
    this.width = double.infinity,
    this.fontSize = 18,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}




// Container(
//   width: double.infinity,
//   decoration: ShapeDecoration(
//   color: Colors.white,
//     shape: RoundedRectangleBorder(
//       side: const BorderSide(width: 2),
//       borderRadius: BorderRadius.circular(16),
//     ),
//     shadows: const [
//       BoxShadow(
//         color: Color(0xFF000000),
//         blurRadius: 0,
//         offset: Offset(4, 4),
//         spreadRadius: 0,
//       )
//     ],
//   ),
//   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//   child: const Text(
//     'Wyszukaj sklep lub kategorię'
//   ),
// ),