import 'package:flutter/material.dart';

class CouponDetailsScreen extends StatelessWidget {
  final String couponId;
  
  const CouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Details'),
      ),
      body: Center(
        child: Text(
          'Details of coupon with id: $couponId',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}