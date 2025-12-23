
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
  // ...existing code...

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

    // Map ordering enum to backend sort string
    String? sort;
    switch (_ordering) {
      case ListedCouponsOrdering.listingDateAsc:
        sort = 'listing+asc';
        break;
      case ListedCouponsOrdering.listingDateDesc:
        sort = 'listing+desc';
        break;
      case ListedCouponsOrdering.expiryDateAsc:
        sort = 'expiry+asc';
        break;
      case ListedCouponsOrdering.expiryDateDesc:
        sort = 'expiry+desc';
        break;
      case ListedCouponsOrdering.priceAsc:
        sort = 'price+asc';
        break;
      case ListedCouponsOrdering.priceDesc:
        sort = 'price+desc';
        break;
    }

    try {
      final result = await couponRepository.fetchListedCouponsPaginated(
        limit: _limit,
        offset: _lastOffset ?? 0,
        userId: _userId!,
        reductionIsPercentage: _reductionIsPercentage,
        reductionIsFixed: _reductionIsFixed,
        showActive: _showActive,
        showSold: _showSold,
        shopId: _shopId,
        sort: sort,
      );
      final listedCoupons = result.coupons;
      if (kDebugMode) print('Fetched ${listedCoupons.length} listed coupons: ${listedCoupons}');

      _hasMore = listedCoupons.length == _limit;
      _allCoupons.addAll(listedCoupons);
      _lastOffset = result.lastOffset;

      emit(ListedCouponListLoadSuccess(coupons: _allCoupons, hasMore: _hasMore));
      if (_allCoupons.isEmpty) {
        emit(ListedCouponListLoadEmpty());
      }
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
    if (_userId != null) {
      add(FetchListedCoupons(userId: _userId!));
    }
  }

  void _onClearFilters(ClearListedCouponFilters event, Emitter emit) {
    _reductionIsPercentage = true;
    _reductionIsFixed = true;
    _showActive = true;
    _showSold = true;
    _shopId = null;
    if (_userId != null) {
      add(FetchListedCoupons(userId: _userId!));
    }
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
    if (_userId != null) {
      add(FetchListedCoupons(userId: _userId!));
    }
  }

  void _onReadOrdering(ReadListedCouponOrdering event, Emitter emit) {
    emit(ListedCouponOrderingRead(_ordering));
  }

  // ...existing code...
}