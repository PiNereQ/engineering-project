import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';

void showCustomSnackBar(BuildContext context, String message) {
  final snackBar = SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    duration:const  Duration(milliseconds: 2500),
    content: _CustomSnackBarContent(message: message,),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class _CustomSnackBarContent extends StatelessWidget {
  final String message;

  const _CustomSnackBarContent({
    required this.message
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2),
          borderRadius: BorderRadius.circular(24),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            blurRadius: 0,
            offset: Offset(4, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontFamily: 'Itim',
        ),
      ),
    );
  }
}