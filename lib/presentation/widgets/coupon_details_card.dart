import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_text_button.dart';

class CouponDetailsCard extends StatelessWidget {
  final Coupon coupon;

  final bool showCloseButton;
  final VoidCallback? onClose;

  const CouponDetailsCard({
    super.key,
    required this.coupon,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Color shopBgColor = coupon.shopBgColor;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final num price = coupon.price;
    final bool hasLimits = coupon.hasLimits;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime expiryDate = coupon.expiryDate;
    final String? description = coupon.description;

    final reductionText =
        isInteger(reduction)
            ? reduction.toString()
            : reductionIsPercentage
                ? reduction.toString().replaceAll('.', ',')
                : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text: reductionIsPercentage
          ? 'Kupon -$reductionText%'
          : 'Kupon na $reductionText zł',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 30,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1,
      ),
    );

    final priceText = TextSpan(
      children: [
        const TextSpan(
          text: "Cena: ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
        TextSpan(
          text: "$price zł",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
            height: 1,
          ),
        ),
      ],
    );

    final limitsText = Text(
      hasLimits ? 'tak (w opisie)' : 'nie',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final locationText = Text(
      worksInStore && worksOnline
          ? 'stacjonarnie i online'
          : worksOnline
              ? 'w sklepach internetowych'
              : 'w sklepach stacjonarnych',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    final expiryDateText = Text(
      '${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.',
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 0.83,
      ),
    );

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // shop banner
                Container(
                  width: double.infinity,
                  height: 90.0,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: ShapeDecoration(
                    color: shopBgColor,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    shopName,
                    style: TextStyle(
                      color: shopNameColor,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(titleText),
                ),

                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text.rich(priceText),
                ),

                const Divider(color: AppColors.textPrimary, thickness: 2),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Szczegóły',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    _infoRow("Gdzie działa:", locationText),
                    _separator(),
                    _infoRow("Ograniczenia:", limitsText),
                    _separator(),
                    _infoRow("Ważny do:", expiryDateText),
                    _separator(),

                    const Text(
                      "Opis:",
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontFamily: 'Itim',
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    Text(
                      (description == null || description.isEmpty)
                          ? "brak"
                          : description,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontFamily: 'Itim',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (showCloseButton) ...[
            DashedSeparator(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomTextButton.primary(
                label: "Zamknij",
                onTap: onClose ?? () {},
              ),
            )
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, Widget value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontFamily: 'Itim',
          ),
        ),
        value,
      ],
    );
  }

  Widget _separator() => const Divider(
        height: 8,
        color: AppColors.textPrimary,
        thickness: 1,
      );
}