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
    on<_PreloadCoupon>((event, emit) {
      emit(CouponLoadSuccess(coupon: event.coupon));
    });

    on<FetchCouponDetails>((event, emit) async {
      emit(const CouponLoadInProgress());

      try {
        final coupon = await couponRepository.fetchCouponDetailsById(couponId);

        if (coupon == null) {
          emit(const CouponDeleted());
          return;
        }

        emit(CouponLoadSuccess(coupon: coupon));
      } catch (e) {
        emit(CouponLoadFailure(message: e.toString()));
      }
    });

  }

  /// Factory constructor that creates a bloc with preloaded coupon data
  /// Use this when you already have the coupon object and don't need to fetch it
  factory CouponBloc.withCoupon(Coupon coupon) {
    final bloc = CouponBloc(
      CouponRepository(), 
      coupon.id,
    );
    // Immediately emit the coupon data
    bloc.add(_PreloadCoupon(coupon));
    return bloc;
  }
}

class _PreloadCoupon extends CouponEvent {
  final Coupon coupon;
  const _PreloadCoupon(this.coupon);
  
  @override
  List<Object> get props => [coupon];
}
