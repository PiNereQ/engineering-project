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
  final int limit = 20;

  final List<Coupon> _allCoupons = [];
  Map<String, dynamic>? _cursor;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _userId;

  SavedCouponListBloc(this.couponRepository)
      : super(SavedCouponListInitial()) {
    on<FetchSavedCoupons>(_onFetchCoupons);
    on<FetchMoreSavedCoupons>(_onFetchMoreCoupons);
    on<RefreshSavedCoupons>(_onRefreshCoupons);
  }

  Future<void> _onFetchCoupons(
    FetchSavedCoupons event,
    Emitter<SavedCouponListState> emit,
  ) async {
    emit(const SavedCouponListLoadInProgress());
    _allCoupons.clear();
    _cursor = null;
    _hasMore = true;
    _userId = event.userId;
    add(FetchMoreSavedCoupons());
  }

  Future<void> _onFetchMoreCoupons(
    FetchMoreSavedCoupons event,
    Emitter<SavedCouponListState> emit,
  ) async {
    if (_isFetching || !_hasMore || _userId == null) return;

    _isFetching = true;
    emit(SavedCouponListLoadInProgress(coupons: List.from(_allCoupons)));

    try {
      final result = await couponRepository.fetchSavedCouponsPaginated(
        limit: limit,
        cursor: _cursor,
        userId: _userId!,
      );

      _allCoupons.addAll(result.coupons);
      _cursor = result.cursor;
      _hasMore = result.cursor != null;

      if (_allCoupons.isEmpty) {
        emit(SavedCouponListLoadEmpty());
      } else {
        emit(SavedCouponListLoadSuccess(
          coupons: List.from(_allCoupons),
          hasMore: _hasMore,
        ));
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      emit(SavedCouponListLoadFailure(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefreshCoupons(
    RefreshSavedCoupons event,
    Emitter<SavedCouponListState> emit,
  ) async {
    if (_userId == null) return;
    add(FetchSavedCoupons(userId: _userId!));
  }
}