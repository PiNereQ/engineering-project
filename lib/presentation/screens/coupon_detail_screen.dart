import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proj_inz/bloc/coupon/coupon_bloc.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

class CouponDetailsScreen extends StatelessWidget {
  final String couponId;
  
  const CouponDetailsScreen({super.key, required this.couponId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponBloc(context.read<CouponRepository>(), couponId)
        ..add(FetchCouponDetails()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Coupon'),
        ),
        body: BlocBuilder<CouponBloc, CouponState>(
          builder: (context, state) {
            if (state is CouponLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponLoaded) {
              return Center(
                child: Column(
                  children: [
                    Text('Coupon with id: ${state.coupon.id}'),
                    Text('${state.coupon.shopName}'),
                    Text('${state.coupon.price} zł'),
                    Text('${state.coupon.description}'),
                    Text('Seller:'),
                    Text('${state.coupon.sellerUsername} (id: ${state.coupon.sellerId})'),
                  ],
                ));
            }
            else if (state is CouponError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const Center(child: Text('Oops'));
          }
        ),
      ),
    );
  }
}