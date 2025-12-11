import 'package:flutter/material.dart';
import 'package:proj_inz/core/theme.dart';
import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/listed_coupon_model.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';

class ListedCouponCardHorizontal extends StatelessWidget {
  final ListedCoupon coupon;

  const ListedCouponCardHorizontal({
    super.key,
    required this.coupon,
  });

  @override
  Widget build(BuildContext context) {
    final reduction = coupon.reduction;
    final reductionIsPercentage = coupon.reductionIsPercentage;
    final price = coupon.price;
    final shopName = coupon.shopName;
    final shopNameColor = coupon.shopNameColor;
    final shopBgColor = coupon.shopBgColor;
    final expiryDate = coupon.expiryDate;
    final listingDate = coupon.listingDate;
    final isSold = coupon.isSold;

    final reductionText =
        isInteger(reduction)
            ? reduction.toString()
            : reductionIsPercentage
            ? reduction.toString().replaceAll('.', ',')
            : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = TextSpan(
      text: reductionIsPercentage
          ? "Kupon -$reductionText%\n"
          : "Kupon na $reductionText zł\n",
      style: TextStyle(
        color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
        fontSize: 20,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
    );

    final priceText = TextSpan(
      children: [
        const TextSpan(
          text: "Cena: ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
        TextSpan(
          text: "$price zł",
          style: TextStyle(
            color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    final expiryDateText = TextSpan(
      text:
          "ważny do ${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.",
      style: TextStyle(
        color: isSold ? AppColors.textSecondary : AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        height: 1.0,
      ),
    );

    final listingDateText = TextSpan(
      text:
          "wystawiono ${listingDate.day}.${listingDate.month}.${listingDate.year} r.",
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontFamily: 'Itim',
        height: 1.0,
      ),
    );

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(width: 2, color: AppColors.textPrimary),
            boxShadow: const [
              BoxShadow(
                color: AppColors.textPrimary,
                blurRadius: 0,
                offset: Offset(4, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 12,
            children: [
              // shop
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                child: Container(
                  width: 110,
                  height: 80,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: ShapeDecoration(
                    color: isSold
                        ? AppColors.primaryButtonPressed
                        : shopBgColor,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    shopName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isSold ? AppColors.textSecondary : shopNameColor,
                      fontSize: 15,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: SizedBox(
                    width: 150,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(titleText),
                        const SizedBox(height: 2),
                        Text.rich(priceText),
                        const SizedBox(height: 2),
                        Text.rich(expiryDateText),
                        Text.rich(listingDateText),
                      ],
                    ),
                  ),
                ),
              ),

              DashedSeparator.vertical(length: 146),

              // status icon
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(4, 10, 16, 10),
                child: Center(
                  child: Icon(
                    isSold ? Icons.done_all_rounded : Icons.store_rounded,
                    size: 36,
                  ),
                ),
              ),
            ],
          ),
        ),

        // sold badge
        if (isSold)
          Positioned(
            bottom: 16,
            right: 128,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(width: 3, color: AppColors.notificationDot),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: const Text(
                'Sprzedany',
                style: TextStyle(
                  color: AppColors.notificationDot,
                  fontSize: 16,
                  fontFamily: 'Itim',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}