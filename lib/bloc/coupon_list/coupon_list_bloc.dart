import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_list_event.dart';
part 'coupon_list_state.dart';


class CouponListBloc extends Bloc<CouponListEvent, CouponListState> {
  final CouponRepository couponRepository;

  CouponListBloc(this.couponRepository) : super(CouponListInitial()) {
    on<FetchCoupons>((event, emit) async{
      emit(const CouponListLoading());

      try {
        final coupons = await couponRepository.fetchCoupons();
        debugPrint('Fetched coupons: $coupons'); // Debugging line
        emit(CouponListLoaded(coupons: coupons));
      } catch (e) {
        emit(CouponListError(message: e.toString()));
      }

    });
  }
}
