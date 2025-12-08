import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class ChatReportPopup extends StatelessWidget {
  final VoidCallback onShowCoupon;
  final VoidCallback onReport;
  final VoidCallback onBlock;
  final VoidCallback onClose;

  const ChatReportPopup({
    super.key,
    required this.onShowCoupon,
    required this.onReport,
    required this.onBlock,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
              side: const BorderSide(width: 2, color: AppColors.textPrimary),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.textPrimary,
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 20,
            children: [

              // pokaz kupon
              CustomTextButton(
                label: "Kupon",
                onTap: onShowCoupon,
                backgroundColor: AppColors.surface,
                icon: Icon(Icons.sell_outlined,
                    color: AppColors.textPrimary, size: 20),
                width: 150,
                height: 52,
              ),

              // zglos
              CustomTextButton(
                label: "Zgłoś",
                onTap: onReport,
                backgroundColor: AppColors.alertButton,
                icon: Icon(Icons.report_gmailerrorred_rounded,
                    color: Colors.red.shade900, size: 20),
                width: 150,
                height: 52,
              ),

              // zablokuj
              CustomTextButton(
                label: "Zablokuj",
                onTap: onBlock,
                backgroundColor: AppColors.primaryButtonPressed,
                icon: Icon(Icons.block, color: AppColors.textSecondary, size: 20),
                width: 150,
                height: 52,
              ),

              // separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DashedSeparator(length: 180),
              ),

              // wroc
              CustomTextButton(
                label: "Wróć",
                onTap: onClose,
                backgroundColor: AppColors.surface,
                icon: SvgPicture.asset(
                  'assets/icons/back.svg',
                  height: 20,
                  width: 20,
                ),
                width: 150,
                height: 52,
              ),
            ],
          ),
        ),
      ),
    );
  }
}