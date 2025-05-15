import 'package:flutter/material.dart';

class CouponDetailsScreen extends StatelessWidget {
  const CouponDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Coupon Details'),
      ),
      body: const Center(
        child: Text(
          'Coupon Details',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}