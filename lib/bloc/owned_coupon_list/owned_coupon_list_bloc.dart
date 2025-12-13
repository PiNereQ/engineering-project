import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/models/owned_coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'owned_coupon_list_event.dart';
part 'owned_coupon_list_state.dart';

class OwnedCouponListBloc extends Bloc<OwnedCouponListEvent, OwnedCouponListState> {
  final CouponRepository couponRepository;
  final int limit = 50;
  
  final List<OwnedCoupon> _allCoupons = [];
  int? _lastOffset;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _userId;

  OwnedCouponListBloc(this.couponRepository) : super(OwnedCouponListInitial()) {
    on<FetchCoupons>(_onFetchCoupons);
    on<FetchMoreCoupons>(_onFetchMoreCoupons);
    on<RefreshCoupons>(_onRefreshCoupons);
  }

    Future<void> _onFetchCoupons(FetchCoupons event, Emitter<OwnedCouponListState> emit) async {
    emit(OwnedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastOffset = null;
    _hasMore = true;
    _userId = event.userId;
    add(FetchMoreCoupons());
  }

  Future<void> _onFetchMoreCoupons(FetchMoreCoupons event, Emitter<OwnedCouponListState> emit) async {
    if (_isFetching) {
      debugPrint("Still loading");
      return;
    }
    if (!_hasMore) {
      debugPrint("No more coupons to load.");
      return;
    }
    if (_userId == null) {
      debugPrint("No user ID provided");
      emit(OwnedCouponListLoadFailure(message: 'User ID required'));
      return;
    }

    _isFetching = true;
    emit(OwnedCouponListLoadInProgress());

    try {
      // final result = await couponRepository.fetchOwnedCouponsPaginated(
      //   limit,
      //   _lastOffset ?? 0,
      //   _userId!,
      // );
      // final ownedCoupons = result.coupons;
      // debugPrint('Fetched ${ownedCoupons.length} coupons: $ownedCoupons');

      // _hasMore = ownedCoupons.length == limit;
      // _allCoupons.addAll(ownedCoupons);
      // _lastOffset = result.lastOffset;

      
      // emit(OwnedCouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore));

      // if (_allCoupons.isEmpty) {
      //   emit(OwnedCouponListLoadEmpty());
      // }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      emit(OwnedCouponListLoadFailure(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefreshCoupons(RefreshCoupons event, Emitter<OwnedCouponListState> emit) async {
    emit(OwnedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastOffset = null;
    _hasMore = true;
    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
  }
}
