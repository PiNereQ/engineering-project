import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import 'package:proj_inz/data/models/coupon_model.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

part 'coupon_list_event.dart';
part 'coupon_list_state.dart';

enum Ordering {creationDateAsc, creationDateDesc,
                priceAsc, priceDesc,
                reputationAsc, reputationDesc,
                expiryDateAsc, expiryDateDesc}

class CouponListBloc extends Bloc<CouponListEvent, CouponListState> {
  final CouponRepository couponRepository;
  CouponListState _previousListState = CouponListInitial();

  final int _limit = 50;
  
  final List<Coupon> _allCoupons = [];
  int? _lastOffset;
  bool _hasMore = true;
  bool _isFetching = false;
  String? _userId;

  // filters
  bool? _reductionIsFixed;
  bool? _reductionIsPercentage; 
  double? _minPrice; 
  double? _maxPrice; 
  int? _minReputation; 
  String? _shopId;

  // sorting
  Ordering _ordering = Ordering.creationDateDesc;

  CouponListBloc(this.couponRepository) : super(CouponListInitial()) {
    on<FetchCoupons>(_onFetchCoupons);
    on<FetchMoreCoupons>(_onFetchMoreCoupons);
    on<RefreshCoupons>(_onRefreshCoupons);
    on<ApplyCouponFilters>(_onApplyCouponFilters);
    on<ClearCouponFilters>(_onClearCouponFilters);
    on<ReadCouponFilters>(_onReadCouponFilters);
    on<LeaveCouponFilterPopUp>(_onLeaveCouponFilterPopUp);
    on<ApplyCouponOrdering>(_onApplyCouponOrdering);
    on<ReadCouponOrdering>(_onReadCouponOrdering);
    on<LeaveCouponSortPopUp>(_onLeaveCouponSortPopUp);
  }

  // helpers to check active filters and ordering
  bool get hasActiveFilters =>
      _reductionIsFixed != null ||
      _reductionIsPercentage != null ||
      _minPrice != null ||
      _maxPrice != null ||
      _minReputation != null;

  bool get hasActiveOrdering =>
      _ordering != Ordering.creationDateDesc;


  Future<void> _onFetchCoupons(FetchCoupons event, Emitter<CouponListState> emit) async {
    emit(CouponListLoadInProgress());
    _allCoupons.clear();
    _lastOffset = null;
    _hasMore = true;
    _userId = event.userId;
    _shopId = event.shopId;
    add(FetchMoreCoupons());
  }

  Future<void> _onFetchMoreCoupons(FetchMoreCoupons event, Emitter<CouponListState> emit) async {
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
      emit(CouponListLoadFailure(message: 'User ID required'));
      return;
    }

    _isFetching = true;
    emit(CouponListLoadInProgress());

    // Map Ordering enum to backend sort string
    String? sort;
    switch (_ordering) {
      case Ordering.creationDateAsc:
        sort = 'listing+asc';
        break;
      case Ordering.creationDateDesc:
        sort = 'listing+desc';
        break;
      case Ordering.priceAsc:
        sort = 'price+asc';
        break;
      case Ordering.priceDesc:
        sort = 'price+desc';
        break;
      case Ordering.reputationAsc:
        sort = 'rep+asc';
        break;
      case Ordering.reputationDesc:
        sort = 'rep+desc';
        break;
      case Ordering.expiryDateAsc:
        sort = 'expiry+asc';
        break;
      case Ordering.expiryDateDesc:
        sort = 'expiry+desc';
        break;
    }

    try {
      final result = await couponRepository.fetchCouponsPaginated(
        limit: _limit,
        offset: _lastOffset ?? 0,
        shopId: null,
        userId: _userId!,
        reductionIsPercentage: _reductionIsPercentage,
        reductionIsFixed: _reductionIsFixed,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minReputation: _minReputation,
        sort: sort,
      );
      debugPrint('Fetched ${result.ownedCoupons.length} coupons with proper mapping');

      _hasMore = result.lastOffset != null;
      _allCoupons.addAll(result.ownedCoupons);
      _lastOffset = result.lastOffset;

      // Restore client-side shop filtering
      List<Coupon> filtered = _shopId != null
          ? _allCoupons.where((c) => c.shopId == _shopId).toList()
          : _allCoupons;

      var successState = CouponListLoadSuccess(coupons: filtered, hasMore: _hasMore);
      _previousListState = successState;
      emit(successState);

      if (filtered.isEmpty) {
        var emptyState = CouponListLoadEmpty();
        _previousListState = emptyState;
        emit(emptyState);
      }
    } catch (e) {
      if (kDebugMode) debugPrint(e.toString());
      var failureState = CouponListLoadFailure(message: e.toString());
      _previousListState = failureState;
      emit(failureState);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefreshCoupons(RefreshCoupons event, Emitter<CouponListState> emit) async {
    _allCoupons.clear();
    _lastOffset = null;
    _hasMore = true;
    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }
  }

  void _onApplyCouponFilters(ApplyCouponFilters event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Applied filters:\n\t%:${event.reductionIsFixed}\tzł:${event.reductionIsPercentage}\n\tminPrice:${event.minPrice}\tmaxPrice:${event.maxPrice}\n\trep:${event.minReputation}');
    emit(CouponListFilterApplyInProgress());
    final isDefaultReduction =
        (event.reductionIsFixed == true &&
        event.reductionIsPercentage == true);

    _reductionIsFixed =
        isDefaultReduction ? null : event.reductionIsFixed;

    _reductionIsPercentage =
        isDefaultReduction ? null : event.reductionIsPercentage;

    _minPrice = event.minPrice;
    _maxPrice = event.maxPrice;
    
    _minReputation =
        (event.minReputation == null || event.minReputation == 0)
            ? null
            : event.minReputation;

    emit(CouponListFilterApplySuccess(
      _reductionIsPercentage,
      _reductionIsFixed,
      _minPrice,
      _maxPrice,
      _minReputation
    ));

    if (_userId != null) {
      add(FetchCoupons(userId: _userId!, shopId: _shopId));
    }

    emit(CouponListMetaState(
      hasFilters: hasActiveFilters,
      hasOrdering: hasActiveOrdering,
    ));
  }

  void _onClearCouponFilters(ClearCouponFilters event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Filters cleared.');
    _reductionIsFixed = null;
    _reductionIsPercentage = null;
    _minPrice = null;
    _maxPrice = null;
    _minReputation = null;
    emit(CouponListFilterApplySuccess(
      _reductionIsPercentage,
      _reductionIsFixed,
      _minPrice,
      _maxPrice,
      _minReputation
    ));

    if (_userId != null) {
      add(FetchCoupons(userId: _userId!, shopId: _shopId));
    }

    emit(CouponListMetaState(
      hasFilters: hasActiveFilters,
      hasOrdering: hasActiveOrdering,
    ));
  }

  void _onReadCouponFilters(ReadCouponFilters event, Emitter<CouponListState> emit) {
    emit(CouponListFilterRead(
      reductionIsPercentage: _reductionIsPercentage,
      reductionIsFixed: _reductionIsFixed,
      minPrice: _minPrice,
      maxPrice: _maxPrice, 
      minReputation: _minReputation
    ));
  }

  void _onLeaveCouponFilterPopUp(LeaveCouponFilterPopUp event, Emitter<CouponListState> emit) {
    emit(_previousListState);
  }

  void _onApplyCouponOrdering(ApplyCouponOrdering event, Emitter<CouponListState> emit) {
    if (kDebugMode) debugPrint('Applied order:\t%:${event.ordering}');
    emit(CouponListOrderingApplyInProgress());
    _ordering = event.ordering;
    emit(CouponListOrderingApplySuccess(_ordering));

    if (_userId != null) {
      add(FetchCoupons(userId: _userId!));
    }

    emit(CouponListMetaState(
      hasFilters: hasActiveFilters,
      hasOrdering: hasActiveOrdering,
    ));
  }

  void _onReadCouponOrdering(ReadCouponOrdering event, Emitter<CouponListState> emit) {
    emit(CouponListOrderingRead(_ordering));
  }

  void _onLeaveCouponSortPopUp(LeaveCouponSortPopUp event, Emitter<CouponListState> emit) {
    emit(_previousListState);
  }
}
