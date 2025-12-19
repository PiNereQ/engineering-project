
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proj_inz/data/models/coupon_model.dart';
import 'listed_coupon_list_event.dart';
import 'listed_coupon_list_state.dart';
import 'package:flutter/foundation.dart';
import 'package:proj_inz/data/repositories/coupon_repository.dart';

class ListedCouponListBloc extends Bloc<ListedCouponListEvent, ListedCouponListState> {
  int? _lastOffset;
  bool _isFetching = false;
  String? _userId;
  final CouponRepository couponRepository;

  List<Coupon> _allCoupons = [];
  List<Coupon> _filtered = [];

  // filters
  bool _reductionIsPercentage = true;
  bool _reductionIsFixed = true;
  bool _showActive = true;
  bool _showSold = true;
  String? _shopId;

  ListedCouponsOrdering _ordering = ListedCouponsOrdering.listingDateDesc;

  int _limit = 20;
  bool _hasMore = true;

List<({String id, String name})> get uniqueShops {
  final map = <String, String>{};

  for (final c in _allCoupons) {
    map[c.shopId] = c.shopName;
  }

  return map.entries
      .map((e) => (id: e.key, name: e.value))
      .toList();
}

  ListedCouponListBloc(this.couponRepository) : super(ListedCouponListInitial()) {
    on<FetchListedCoupons>(_onFetch);
    on<FetchMoreListedCoupons>(_onMore);
    on<RefreshListedCoupons>(_onRefresh);

    on<ApplyListedCouponFilters>(_onApplyFilters);
    on<ClearListedCouponFilters>(_onClearFilters);
    on<ReadListedCouponFilters>(_onReadFilters);

    on<ApplyListedCouponOrdering>(_onApplyOrdering);
    on<ReadListedCouponOrdering>(_onReadOrdering);
  }


  Future<void> _onFetch(FetchListedCoupons event, Emitter emit) async {
    emit(ListedCouponListLoadInProgress());
    _allCoupons.clear();
    _lastOffset = null;
    _hasMore = true;
    _userId = event.userId;
    add(FetchMoreListedCoupons());
  }

  Future<void> _onMore(FetchMoreListedCoupons event, Emitter emit) async {
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
      emit(ListedCouponListLoadFailure("User ID required"));
      return;
    }

    _isFetching = true;
    emit(ListedCouponListLoadInProgress());

    try {
      final result = await couponRepository.fetchListedCouponsPaginated(
        _limit,
        _lastOffset ?? 0,
        _userId!,
      );
      final listedCoupons = result.coupons;
      if (kDebugMode) print('Fetched \\${listedCoupons.length} listed coupons: \\${listedCoupons}');

      _hasMore = listedCoupons.length == _limit;
      _allCoupons.addAll(listedCoupons);
      _lastOffset = result.lastOffset;

      _applyAll();
      emit(ListedCouponListLoadSuccess(coupons: _filtered, hasMore: _hasMore));
    } catch (e) {
      emit(ListedCouponListLoadFailure(e.toString()));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _onRefresh(RefreshListedCoupons event, Emitter emit) async {
    if (_userId != null) {
      add(FetchListedCoupons(userId: _userId!));
    } else {
      emit(ListedCouponListLoadFailure("User ID required"));
    }
  }

  void _onApplyFilters(ApplyListedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = event.reductionIsPercentage;
    _reductionIsFixed = event.reductionIsFixed;
    _showActive = event.showActive;
    _showSold = event.showSold;
    _shopId = event.shopId;

    _applyAll();

    emit(ListedCouponListLoadSuccess(coupons: _filtered, hasMore: _hasMore));
  }

  void _onClearFilters(ClearListedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = true;
    _reductionIsFixed = true;
    _showActive = true;
    _showSold = true;
    _shopId = null;

    _applyAll();
    emit(ListedCouponListLoadSuccess(coupons: _filtered, hasMore: _hasMore));
  }

  void _onReadFilters(ReadListedCouponFilters event, Emitter emit) {
    emit(ListedCouponFilterRead(
      reductionIsPercentage: _reductionIsPercentage,
      reductionIsFixed: _reductionIsFixed,
      showActive: _showActive,
      showSold: _showSold,
      shopId: _shopId,
    ));
  }

  void _onApplyOrdering(ApplyListedCouponOrdering event, Emitter emit) {
    _ordering = event.ordering;

    _applyAll();
    emit(ListedCouponListLoadSuccess(coupons: _filtered, hasMore: _hasMore));
  }

  void _onReadOrdering(ReadListedCouponOrdering event, Emitter emit) {
    emit(ListedCouponOrderingRead(_ordering));
  }

  // filtering and sorting
  void _applyAll() {
    _filtered = _allCoupons.where((c) {
      if (!_reductionIsPercentage && c.reductionIsPercentage) return false;
      if (!_reductionIsFixed && !c.reductionIsPercentage) return false;

      if (!_showActive && !c.isSold) return false;
      if (!_showSold && c.isSold) return false;

      if (_shopId != null && c.shopId != _shopId) return false;

      return true;
    }).toList();

    switch (_ordering) {
      case ListedCouponsOrdering.listingDateDesc:
        _filtered.sort((a, b) => b.listingDate.compareTo(a.listingDate));
        break;
      case ListedCouponsOrdering.listingDateAsc:
        _filtered.sort((a, b) => a.listingDate.compareTo(b.listingDate));
        break;
      case ListedCouponsOrdering.expiryDateAsc:
        _filtered.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return -1;
          if (b.expiryDate == null) return 1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
      case ListedCouponsOrdering.expiryDateDesc:
        _filtered.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return -1;
          if (b.expiryDate == null) return 1;
          return b.expiryDate!.compareTo(a.expiryDate!);
        });
        break;
      case ListedCouponsOrdering.priceAsc:
        _filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ListedCouponsOrdering.priceDesc:
        _filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
    }
  }
}