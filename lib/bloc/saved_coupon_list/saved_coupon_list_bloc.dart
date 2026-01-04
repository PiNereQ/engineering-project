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

  Map<String, dynamic>? _cursor;
  bool _isFetching = false;
  String? _userId;
  final List<Coupon> _allCoupons = [];
  final int _limit = 20;
  bool _hasMore = true;

  // filters
  bool? _reductionIsPercentage;
  bool? _reductionIsFixed;
  String? _shopId;
  double? _minPrice;
  double? _maxPrice;
  double? _minReputation;

  SavedCouponsOrdering _ordering = SavedCouponsOrdering.saveDateDesc;

  SavedCouponListBloc(this.couponRepository)
      : super(SavedCouponListInitial()) {
    on<FetchSavedCoupons>(_onFetch);
    on<FetchMoreSavedCoupons>(_onMore);
    on<RefreshSavedCoupons>(_onRefresh);
    on<ApplySavedCouponFilters>(_onApplyFilters);
    on<ClearSavedCouponFilters>(_onClearFilters);
    on<ReadSavedCouponFilters>(_onReadFilters);
    on<ApplySavedCouponOrdering>(_onApplyOrdering);
    on<ReadSavedCouponOrdering>(_onReadOrdering);
  }

  Future<void> _onFetch(FetchSavedCoupons event, Emitter emit) async {
    emit(SavedCouponListLoadInProgress());
    _allCoupons.clear();
    _cursor = null;
    _hasMore = true;
    _userId = event.userId;
    add(FetchMoreSavedCoupons());
  }

  Future<void> _onMore(FetchMoreSavedCoupons event, Emitter emit) async {
    if (_isFetching) {
      if (kDebugMode) print("Still loading");
      return;
    }
    if (!_hasMore) {
      if (kDebugMode) print("No more coupons to load.");
      return;
    }
    if (_userId == null) {
      if (kDebugMode) print("No user ID provided");
      emit(SavedCouponListLoadFailure(message: "User ID required"));
      return;
    }

    _isFetching = true;
    emit(SavedCouponListLoadInProgress(coupons: List.from(_allCoupons)));

    try {
      // Map ordering enum to backend sort string
      String? sort;
      switch (_ordering) {
        case SavedCouponsOrdering.saveDateAsc:
          sort = 'save+asc';
          break;
        case SavedCouponsOrdering.saveDateDesc:
          sort = 'save+desc';
          break;
        case SavedCouponsOrdering.creationDateAsc:
          sort = 'creation+asc';
          break;
        case SavedCouponsOrdering.creationDateDesc:
          sort = 'creation+desc';
          break;
        case SavedCouponsOrdering.expiryDateAsc:
          sort = 'expiry+asc';
          break;
        case SavedCouponsOrdering.expiryDateDesc:
          sort = 'expiry+desc';
          break;
        case SavedCouponsOrdering.priceAsc:
          sort = 'price+asc';
          break;
        case SavedCouponsOrdering.priceDesc:
          sort = 'price+desc';
          break;
        case SavedCouponsOrdering.reputationAsc:
          sort = 'reputation+asc';
          break;
        case SavedCouponsOrdering.reputationDesc:
          sort = 'reputation+desc';
          break;
      }

      final result = await couponRepository.fetchSavedCouponsPaginated(
        limit: _limit,
        cursor: _cursor,
        userId: _userId!,
        reductionIsPercentage: _reductionIsPercentage,
        reductionIsFixed: _reductionIsFixed,
        shopId: _shopId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minReputation: _minReputation,
        sort: sort,
      );
      final savedCoupons = result.coupons;
      if (kDebugMode) print('Fetched ${savedCoupons.length} saved coupons: $savedCoupons');

      _hasMore = result.cursor != null;
      _allCoupons.addAll(savedCoupons);
      _cursor = result.cursor;

      emit(SavedCouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore));
      if (_allCoupons.isEmpty) {
        emit(SavedCouponListLoadEmpty());
      }
    } catch (e) {
      emit(SavedCouponListLoadFailure(message: e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh(RefreshSavedCoupons event, Emitter emit) async {
    if (_userId != null) {
      add(FetchSavedCoupons(userId: _userId!));
    } else {
      emit(SavedCouponListLoadFailure(message: "User ID required"));
    }
  }

  void _onApplyFilters(ApplySavedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = event.reductionIsPercentage;
    _reductionIsFixed = event.reductionIsFixed;
    _shopId = event.shopId;
    _minPrice = event.minPrice;
    _maxPrice = event.maxPrice;
    _minReputation = event.minReputation;
    if (_userId != null) {
      add(FetchSavedCoupons(userId: _userId!));
    }
  }

  void _onClearFilters(ClearSavedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = null;
    _reductionIsFixed = null;
    _shopId = null;
    _minPrice = null;
    _maxPrice = null;
    _minReputation = null;
    if (_userId != null) {
      add(FetchSavedCoupons(userId: _userId!));
    }
  }

  void _onReadFilters(ReadSavedCouponFilters event, Emitter emit) {
    emit(SavedCouponFilterRead(
      reductionIsPercentage: _reductionIsPercentage,
      reductionIsFixed: _reductionIsFixed,
      shopId: _shopId,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minReputation: _minReputation,
    ));
  }

  void _onApplyOrdering(ApplySavedCouponOrdering event, Emitter emit) {
    _ordering = event.ordering;
    if (_userId != null) {
      add(FetchSavedCoupons(userId: _userId!));
    }
  }

  void _onReadOrdering(ReadSavedCouponOrdering event, Emitter emit) {
    emit(SavedCouponOrderingRead(_ordering));
  }
}
