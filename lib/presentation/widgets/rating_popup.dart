import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class RatingDialog extends StatefulWidget {
  final VoidCallback onCancel;
  final void Function(int stars, String? comment) onSubmit;

  const RatingDialog({
    super.key,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int selectedStars = 5;
  final TextEditingController commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(width: 2, color: AppColors.textPrimary),
      ),
      child: SizedBox(
        width: 420,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Oceń transakcję',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 22,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Twoja ocena',
                style: TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return GestureDetector(
                    onTap: () => setState(() => selectedStars = star),
                    child: Icon(
                      Icons.star_rounded,
                      size: 36,
                      color: selectedStars >= star
                          ? Colors.amber
                          : AppColors.textSecondary,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 16),

              TextField(
                controller: commentController,
                maxLines: 3,
                style: const TextStyle(
                  fontFamily: 'Itim',
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Komentarz (opcjonalnie)',
                  hintStyle: const TextStyle(
                    fontFamily: 'Itim',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      width: 2,
                      color: AppColors.primaryButton,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomTextButton.small(
                    label: 'Anuluj',
                    width: 100,
                    onTap: widget.onCancel,
                  ),
                  const SizedBox(width: 12),
                  CustomTextButton.primarySmall(
                    label: 'Wyślij',
                    width: 100,
                    onTap: () {
                      widget.onSubmit(
                        selectedStars,
                        commentController.text.trim().isEmpty
                            ? null
                            : commentController.text.trim(),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
