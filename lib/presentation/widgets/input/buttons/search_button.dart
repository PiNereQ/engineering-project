import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

class SearchButtonWide extends StatelessWidget {
  final double width;
  final double fontSize;
  final String label;
  final GestureTapCallback onTap;

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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: fontSize,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(Icons.search, color: AppColors.textPrimary),
          ],
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