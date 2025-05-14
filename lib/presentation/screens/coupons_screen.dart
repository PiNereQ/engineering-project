import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proj_inz/bloc/coupon/coupon_bloc.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';


class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponBloc(context.read<CouponRepository>())
        ..add(FetchCoupons()),
      child: Scaffold(
        body: BlocBuilder<CouponBloc, CouponState>(
          builder: (context, state) {
            if (state is CouponLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponLoaded) {
              return ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final coupon = state.coupons[index];
                  return CouponHorizontalCard(
                    coupon: coupon
                  );
                },
                itemCount: state.coupons.length,
              );
            }
            
            return const Center(child: Text('No coupons available.'));
          },
        ),
      ),
    );
  }
}