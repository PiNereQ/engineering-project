import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_event.dart';
part 'coupon_state.dart';

class CouponBloc extends Bloc<CouponEvent, CouponState> {
  final CouponRepository couponRepository;
  final String couponId;

  CouponBloc(this.couponRepository, this.couponId) : super(CouponInitial()) {
    on<FetchCouponDetails>((event, emit) async {
      emit(const CouponLoadInProgress());

      try {
        final coupon = await couponRepository.fetchCouponDetailsById(couponId);
        emit(CouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(CouponLoadFailure(message: e.toString()));
      }
    });

    on<BuyCouponRequested>((event, emit) async {
      emit(const CouponLoadInProgress());

      try {
        final coupon = await couponRepository.fetchCouponDetailsById(couponId);
        await couponRepository.buyCoupon(
          couponId: event.couponId,
          buyerId: event.userId,
        );
        emit(CouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(CouponLoadFailure(message: e.toString()));
      }
    });
  }
}
