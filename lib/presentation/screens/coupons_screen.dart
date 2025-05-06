import 'package:flutter/material.dart';

import 'package:proj_inz/presentation/widgets/coupon.dart';

class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupons'),
      ),
      body: Center(
        child: ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) => Coupon(
            reduction: 50.5, 
            reductionIsPercentage: false, 
            price: 30, 
            pricePoints: 300, 
            shopName: 'MediaMarkt', 
            shopNameColor: Colors.white, 
            shopBgColor: Colors.red, 
            hasLimits: false, 
            reputation: 90, 
            isOnline: true, 
            expiryDate: DateTime(2025, 12, 31)
          ),
          itemCount: 10,
        )
      ),
    );
  }
}