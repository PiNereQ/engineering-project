import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:proj_inz/bloc/coupon_list/coupon_list_bloc.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';
import 'package:proj_inz/presentation/widgets/coupon_card.dart';
import 'package:proj_inz/presentation/widgets/input/buttons/search_button.dart';


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
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                width: double.infinity,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2),
                    borderRadius: BorderRadius.circular(24),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SearchButtonWide(
                  label: 'Wyszukaj sklep lub kategorię',
                  onTap: () {}
                )
              ),
            ),
            BlocBuilder<CouponListBloc, CouponListState>(
              builder: (context, state) {
                if (state is CouponListLoadInProgress) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CouponListLoadSuccess) {
                  return Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final coupon = state.coupons[index];
                        return CouponCardHorizontal(
                          coupon: coupon
                        );
                      },
                      itemCount: state.coupons.length,
                    ),
                  );
                } else if (state is CouponListLoadFailure) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                
                return const Center(child: Text('No coupons available.'));
              },
            ),
          ],
        ),
      ),
    );
  }
}