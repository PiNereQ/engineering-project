import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:proj_inz/data/models/listed_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'listed_coupon_event.dart';
part 'listed_coupon_state.dart';

class ListedCouponBloc extends Bloc<ListedCouponEvent, ListedCouponState> {
  final CouponRepository couponRepository;
  final String couponId;

  ListedCouponBloc(this.couponRepository, this.couponId) : super(ListedCouponInitial()) {
    on<FetchCouponDetails>((event, emit) async {
      emit(const ListedCouponLoadInProgress());

      try {
        final coupon = await couponRepository.fetchListedCouponDetailsById(couponId);
        emit(ListedCouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(ListedCouponLoadFailure(message: e.toString()));
      }
    });
  }
}