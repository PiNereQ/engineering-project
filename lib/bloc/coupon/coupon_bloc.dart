import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository couponRepository;
  final String couponId;

  CouponBloc(this.couponRepository, this.couponId) : super(CouponInitial()) {
    on<FetchCouponDetails>((event, emit) async {
      emit(const CouponLoading());
      await Future.delayed(const Duration(milliseconds: 100));

      try {
        final coupon = await couponRepository.fetchCouponDetailsById(couponId);
        debugPrint('Fetched coupon with id: $couponId'); // Debugging line
        emit(CouponLoaded(coupon: coupon));
      } catch (e) {
        emit(CouponError(message: e.toString()));
      }
    });
  }
}
