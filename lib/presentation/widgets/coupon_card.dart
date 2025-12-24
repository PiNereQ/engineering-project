import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:icon_decoration/icon_decoration.dart';

import 'package:proj_inz/core/utils/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/presentation/screens/bought_coupon_detail_screen.dart';
import 'package:proj_inz/presentation/screens/coupon_detail_screen.dart';
import 'package:proj_inz/presentation/widgets/dashed_separator.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/custom_follow_button.dart';
import 'package:proj_inz/core/theme.dart';

class CouponCardHorizontal extends StatelessWidget {
  final Coupon coupon;
  final bool isBought;

  const CouponCardHorizontal._({
    super.key,
    required this.coupon,
    this.isBought = false,
  });

  factory CouponCardHorizontal({Key? key, required Coupon coupon}) {
    return CouponCardHorizontal._(key: key, coupon: coupon, isBought: false);
  }

  factory CouponCardHorizontal.bought({Key? key, required Coupon coupon}) {
    return CouponCardHorizontal._(key: key, coupon: coupon, isBought: true);
  }

  @override
  Widget build(BuildContext context) {
    final String couponId = coupon.id;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final int price = coupon.price;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final Color shopBgColor = coupon.shopBgColor;
    final bool hasLimits = coupon.hasLimits;
    final int? sellerReputation = coupon.sellerReputation;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime? expiryDate = coupon.expiryDate;
    final bool isSaved = coupon.isSaved ?? false;
    final bool hasExpiryDate = expiryDate != null;
    
    final reductionText =
        formatReduction(reduction.toDouble(), reductionIsPercentage);

    final titleText = Text(
        reductionIsPercentage
            ? '-$reductionText'
            : reductionText,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 1.0,
        forceStrutHeight: true,
      ),
    );

    final limitsText = Text(
      hasLimits ? 'z ograniczeniami' : 'na wszystko',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 0.7,
        forceStrutHeight: true,
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
          text: "${formatPrice(price)} zł",
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontFamily: 'Itim',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );

    final reputationText = Text(
      sellerReputation != null ? 'Reputacja: $sellerReputation' : 'Brak ocen',
      style: TextStyle(
        color: sellerReputation != null ? AppColors.textPrimary : AppColors.textSecondary,
        fontSize: 13,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
    );

    final locationText = Text(
      worksInStore && worksOnline
          ? 'Stacjonarnie i online'
          : worksOnline
          ? 'Online'
          : 'Stacjonarnie',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );


    return Container(
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
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 12,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (kDebugMode) {
                  print('Tapping coupon: id=${coupon.id}');
                }
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            isBought
                                ? BoughtCouponDetailsScreen(couponId: couponId)
                                : CouponDetailsScreen(coupon: coupon),
                  ),
                );
              },
              child: Container(
                color: Colors.transparent, // To make the entire area tappable
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    // Shop
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 0.0, 10.0),
                      child: Container(
                        width: 110.0,
                        height: 80.0,
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
                            fontSize: 15,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Details
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: SizedBox(
                          width: 150,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  Icon(Icons.local_offer_outlined, size: 20),
                                  titleText,
                                ],
                              ),
                              const SizedBox(height: 1.0),
                              limitsText,
                              const SizedBox(height: 2.0),
                              Text.rich(priceText),
                              const SizedBox(height: 2.0),
                              Row(
                                children: [
                                  Icon(Icons.speed, size: 14),
                                  SizedBox(width: 4),
                                  reputationText,
                                  SizedBox(width: 2),
                                  sellerReputation != null && sellerReputation >= 75
                                      ? DecoratedIcon(
                                        decoration: IconDecoration(
                                          border: IconBorder(width: 2.0),
                                        ),
                                        icon: const Icon(
                                          Icons.star,
                                          size: 13,
                                          color: Colors.amber,
                                        ),
                                      )
                                      : sellerReputation != null && sellerReputation < 50
                                      ? DecoratedIcon(
                                        decoration: IconDecoration(
                                          border: IconBorder(width: 2.0),
                                        ),
                                        icon: const Icon(
                                          Icons.warning,
                                          size: 13,
                                          color: AppColors.alertText,
                                        ),
                                      )
                                      : const SizedBox.shrink(),
                                ],
                              ),
                              const SizedBox(height: 1.0),
                              Row(
                                spacing: 4,
                                children: [
                                  Icon(Icons.location_on_outlined, size: 14),
                                  Expanded(child: locationText),
                                ],
                              ),
                              const SizedBox(height: 2.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.calendar_today, size: 14),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final bool isTight = constraints.maxWidth < 110;

                                        final String text = hasExpiryDate
                                            ? 'Do ${formatDate(expiryDate)}'
                                            : isTight
                                                ? 'Bez daty ważn.'
                                                : 'Bez daty ważności';

                                        return Text(
                                          text,
                                          maxLines: 1,
                                          overflow: hasExpiryDate
                                              ? TextOverflow.ellipsis
                                              : TextOverflow.visible,
                                          style: const TextStyle(
                                            color: AppColors.textPrimary,
                                            fontSize: 13,
                                            fontFamily: 'Itim',
                                            fontWeight: FontWeight.w400,
                                            height: 1.0,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          DashedSeparator.vertical(length: 146),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
            child: Center(
              child: isBought
              ? const Icon(Icons.check_rounded, size: 36)
              : CustomFollowButton.small(
                onTap: () {},
                isPressed: isSaved
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CouponCardVertical extends StatelessWidget {
  final Coupon coupon;
  final bool isBought;

  const CouponCardVertical._({
    super.key,
    required this.coupon,
    this.isBought = false,
  });

  factory CouponCardVertical({Key? key, required Coupon coupon}) {
    return CouponCardVertical._(key: key, coupon: coupon, isBought: false);
  }

  factory CouponCardVertical.bought({Key? key, required Coupon coupon}) {
    return CouponCardVertical._(key: key, coupon: coupon, isBought: true);
  }

  @override
  Widget build(BuildContext context) {
    final String couponId = coupon.id;
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final int price = coupon.price;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final Color shopBgColor = coupon.shopBgColor;
    final bool hasLimits = coupon.hasLimits;
    final int? sellerReputation = coupon.sellerReputation;
    final bool worksOnline = coupon.worksOnline;
    final bool worksInStore = coupon.worksInStore;
    final DateTime? expiryDate = coupon.expiryDate;

    final reductionText =
        formatReduction(reduction.toDouble(), reductionIsPercentage);

    final titleText = Text(
        reductionIsPercentage
            ? '-$reductionText'
            : reductionText,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 1.0,
        forceStrutHeight: true,
      ),
    );

    final limitsText = Text(
      hasLimits ? 'z ograniczeniami' : 'na wszystko',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 0.7,
        forceStrutHeight: true,
      ),
    );

    final priceText = Text(
      "${formatPrice(price)} zł",
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 22,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
      strutStyle: const StrutStyle(
        height: 1.0,
        forceStrutHeight: true,
      ),
    );

    final reputationText = Text(
      '${sellerReputation ?? 'Brak ocen'}',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
      ),
    );

    final locationText = Text(
      worksInStore && worksOnline
          ? 'Stacjonarnie i online'
          : worksOnline
          ? 'Online'
          : 'Stacjonarnie',
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    final expiryDateText = Text(
      expiryDate == null
          ? 'Bez daty ważn.'
          : formatDate(expiryDate),
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 12,
        fontFamily: 'Itim',
        fontWeight: FontWeight.w400,
        height: 1.0,
      ),
    );

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    isBought
                        ? BoughtCouponDetailsScreen(couponId: couponId)
                        : CouponDetailsScreen(coupon: coupon),
          ),
        );
      },
      child: Container(
        width: 134,
        height: 190,
        padding: const EdgeInsets.all(8),
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
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            // Shop
            Container(
              width: 110.0,
              height: 50.0,
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
                  fontSize: 15,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 4,
                        children: [
                          Icon(Icons.local_offer_outlined, size: 16,),
                          titleText,
                        ],
                      ), 
                      limitsText
                    ],
                  ),
                  SizedBox(height: 10.0),
                  priceText,
                  SizedBox(height: 4.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Column(
                      children: [
                        Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.speed, size: 12,),
                            reputationText,
                          ],
                        ),
                        Row(
                          spacing: 4,
                          children: [
                            Icon(Icons.location_on_outlined, size: 12),
                            Expanded(child: locationText),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            Icon(Icons.calendar_today, size: 12,),
                            expiryDateText,
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
