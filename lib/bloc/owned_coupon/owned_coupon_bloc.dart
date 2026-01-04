import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/core/app_flags.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'owned_coupon_event.dart';
part 'owned_coupon_state.dart';

class OwnedCouponBloc extends Bloc<OwnedCouponEvent, OwnedCouponState> {
  final CouponRepository couponRepository;
  final String couponId;
  Coupon? _currentCoupon;

  OwnedCouponBloc(this.couponRepository, this.couponId) : super(OwnedCouponInitial()) {
    on<FetchCouponDetails>((event, emit) async {
      emit(const OwnedCouponLoadInProgress());
      try {
        final coupon = await couponRepository.fetchOwnedCouponDetailsById(couponId);
        _currentCoupon = coupon;
        emit(OwnedCouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(OwnedCouponLoadFailure(message: e.toString()));
      }
    });

    on<MarkCouponAsUsed>((event, emit) async {
      try {
        print('Marking coupon as used: $couponId');
        emit(OwnedCouponMarkAsUsedInProgress());
        await couponRepository.markOwnedCouponAsUsed(couponId);
        AppFlags.ownedCouponUsed = true;
        // Optionally, refetch the details or update state
        final coupon = await couponRepository.fetchOwnedCouponDetailsById(couponId);
        _currentCoupon = coupon;
        emit(OwnedCouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(OwnedCouponMarkAsUsedFailure(message: e.toString()));
        // Revert to success state with current coupon
        if (_currentCoupon != null) {
          emit(OwnedCouponLoadSuccess(coupon: _currentCoupon!));
        }
      }
    });
  }
}
