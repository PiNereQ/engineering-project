import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onTap;

  const GoogleSignInButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isIOS = false;

    if (Platform.isIOS) isIOS = true;

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(1000),
        child: Container(
          height: isIOS ? 44 : 40,
          padding: EdgeInsets.symmetric(horizontal: isIOS ? 16 : 12),
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              side: const BorderSide(width: 1, color: AppColors.textSecondary),
              borderRadius: BorderRadius.circular(1000),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              SvgPicture.asset('assets/icons/google.svg'),
              const Text(
                'Zaloguj się z Google',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
