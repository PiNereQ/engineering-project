import 'package:flutter/material.dart';
import 'package:proj_inz/core/utils.dart';

class Coupon extends StatelessWidget {
  final num reduction;
  final bool reductionIsPercentage; 
  final num price;
  final num pricePoints;
  final String shopName;
  final Color shopNameColor;
  final Color shopBgColor;
  final bool hasLimits;
  final int reputation;
  final bool isOnline;
  final DateTime expiryDate;

  const Coupon({
    super.key,
    required this.reduction,
    required this.reductionIsPercentage,
    required this.price,
    required this.pricePoints,
    required this.shopName,
    required this.shopNameColor,
    required this.shopBgColor,
    required this.hasLimits,
    required this.reputation,
    required this.isOnline,
    required this.expiryDate,
  });

  @override
  Widget build(BuildContext context) {
    
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

    final priceText = 'Cena: ${price}zł/${pricePoints}pkt';

    final reputationText = 'Reputacja: $reputation';
    
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