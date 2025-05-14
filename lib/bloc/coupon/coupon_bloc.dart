import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';


class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository couponRepository;

  CouponBloc(this.couponRepository) : super(CouponInitial()) {
    on<FetchCoupons>((event, emit) async{
      emit(CouponLoading());
      await Future.delayed(const Duration(seconds: 1));

      emit(const CouponLoaded(coupons: <Coupon>[]));


      try {
        final coupons = await couponRepository.fetchCoupons();
        debugPrint('Fetched coupons: $coupons'); // Debugging line
        emit(CouponLoaded(coupons: coupons));
      } catch (e) {
        emit(CouponError(message: e.toString()));
      }

    });
  }
}
