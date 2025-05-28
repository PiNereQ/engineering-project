import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';


class CouponsScreen extends StatelessWidget {
  const CouponsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CouponListBloc(context.read<CouponRepository>())
        ..add(FetchCoupons()),
      child: Scaffold(
        floatingActionButton: BlocBuilder<CouponListBloc, CouponListState>(
          builder: (context, state) {
              return FloatingActionButton(
                onPressed: () {
                  context.read<CouponListBloc>().add(FetchMoreCoupons());
                },
                tooltip: 'Load More Coupons',
                child: const Icon(Icons.add),
              );
          },
        ),
        body: BlocBuilder<CouponListBloc, CouponListState>(
          builder: (context, state) {
            if (state is CouponListLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CouponListLoadSuccess) {
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
            } else if (state is CouponListLoadFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }
            
            return const Center(child: Text('No coupons available.'));
          },
        ),
      ),
    );
  }
}