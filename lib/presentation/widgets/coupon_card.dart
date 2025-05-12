import 'package:flutter/material.dart';

import 'package:proj_inz/core/utils.dart';
import 'package:proj_inz/data/models/coupon_model.dart';

class CouponHorizontalCard extends StatelessWidget {
  final Coupon coupon;

  const CouponHorizontalCard({
    super.key,
    required this.coupon
  });

  @override
  Widget build(BuildContext context) {
    final num reduction = coupon.reduction;
    final bool reductionIsPercentage = coupon.reductionIsPercentage;
    final num price = coupon.price;
    final String shopName = coupon.shopName;
    final Color shopNameColor = coupon.shopNameColor;
    final Color shopBgColor = coupon.shopBgColor;
    final bool hasLimits = coupon.hasLimits;
    final int sellerReputation = coupon.sellerReputation;
    final bool isOnline = coupon.isOnline;
    final DateTime expiryDate = coupon.expiryDate;


    final reductionText = isInteger(reduction)
      ? reduction.toString()
      : reductionIsPercentage
        ? reduction.toString().replaceAll('.', ',')
        : reduction.toStringAsFixed(2).replaceAll('.', ',');

    final titleText = reductionIsPercentage 
      ? 'Kupon -$reductionText%'
      : 'Kupon na $reductionText zł';

    final limitsText = hasLimits
      ? 'z ograniczeniami'
      : 'na wszystko';

    final priceText = 'Cena: ${price}zł';

    final reputationText = 'Reputacja: $sellerReputation';
    
    final locationText = 'Do wykorzystania w sklepach ${isOnline ? 'intenetowych' : 'stacjonarnych'}';

    final expiryDateText = '${expiryDate.day}.${expiryDate.month}.${expiryDate.year} r.';

    return Container(
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleText),
          Text(limitsText),
          Text(priceText),
          Text(reputationText),
          Text(locationText),
          Text(expiryDateText),
        ],
      )
    );
  }
}