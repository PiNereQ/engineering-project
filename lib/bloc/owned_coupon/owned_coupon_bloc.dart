import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'owned_coupon_event.dart';
part 'owned_coupon_state.dart';

class OwnedCouponBloc extends Bloc<OwnedCouponEvent, OwnedCouponState> {
  final CouponRepository couponRepository;
  final String couponId;

  OwnedCouponBloc(this.couponRepository, this.couponId) : super(OwnedCouponInitial()) {
    on<FetchCouponDetails>((event, emit) async {
      emit(const OwnedCouponLoadInProgress());

      try {
        final coupon = await couponRepository.fetchOwnedCouponDetailsById(couponId);
        emit(OwnedCouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(OwnedCouponLoadFailure(message: e.toString()));
      }
    });
  }
}
