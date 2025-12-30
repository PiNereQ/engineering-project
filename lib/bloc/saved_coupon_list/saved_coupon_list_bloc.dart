import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'saved_coupon_list_event.dart';
part 'saved_coupon_list_state.dart';

class SavedCouponListBloc
    extends Bloc<SavedCouponListEvent, SavedCouponListState> {
  final CouponRepository couponRepository;

  SavedCouponListBloc(this.couponRepository)
      : super(SavedCouponListInitial()) {
    on<FetchSavedCoupons>(_onFetchSavedCoupons);
    on<RefreshSavedCoupons>(_onRefreshSavedCoupons);
  }

  Future<void> _onFetchSavedCoupons(
    FetchSavedCoupons event,
    Emitter<SavedCouponListState> emit,
  ) async {
    emit(SavedCouponListLoadInProgress());

    try {
      final coupons = await couponRepository.fetchSavedCouponsFromApi(event.userId);

      if (coupons.isEmpty) {
        emit(SavedCouponListLoadEmpty());
      } else {
        emit(SavedCouponListLoadSuccess(coupons: coupons));
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      emit(SavedCouponListLoadFailure(message: e.toString()));
    }
  }

  Future<void> _onRefreshSavedCoupons(
    RefreshSavedCoupons event,
    Emitter<SavedCouponListState> emit,
  ) async {
    add(FetchSavedCoupons(userId: event.userId));
  }
}
