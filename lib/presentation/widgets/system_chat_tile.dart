import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class SystemChatTile extends StatelessWidget {
  final String text;
  final VoidCallback onRate;

  const SystemChatTile({
    super.key,
    required this.text,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: ShapeDecoration(
        color: AppColors.background,
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 2, color: AppColors.textPrimary),
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.textPrimary,
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, size: 20),
              SizedBox(width: 8),
              Text(
                'Informacja systemowa',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            text,
            style: const TextStyle(
              fontFamily: 'Itim',
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 16),

          Align(
            alignment: Alignment.centerRight,
            child: CustomTextButton.primarySmall(
              label: 'Oceń kupującego',
              onTap: onRate,
            ),
          ),
        ],
      ),
    );
  }
}