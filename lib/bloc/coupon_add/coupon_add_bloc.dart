import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/coupon_offer_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_add_event.dart';
part 'coupon_add_state.dart';

class CouponAddBloc extends Bloc<CouponAddEvent, CouponAddState> {
  final CouponRepository couponRepository;
  
  CouponAddBloc(this.couponRepository) : super(CouponAddInitial()) {
    on<AddCouponOffer>((event, emit) async {
      emit(const CouponAddInProgress());

      try {
        couponRepository.postCouponOffer(event.offer);
        emit(CouponAddSuccess());
      } catch (e) {
        emit(CouponAddFailure(message: e.toString()));
      }
    });
  }
}
