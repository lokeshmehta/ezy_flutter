
import 'package:flutter/material.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/order_models.dart';

class OrdersProvider with ChangeNotifier {
  final AuthRemoteDataSource _dataSource;

  OrdersProvider(this._dataSource);

  // Order History State
  List<OrderHistoryResult> _orders = [];
  List<OrderHistoryResult> get orders => _orders;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isMoreLoading = false;
  bool get isMoreLoading => _isMoreLoading;

  int _currentPage = 1;
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  // Search/Filters
  String _searchText = "";
  String _startDate = "";
  String _endDate = "";

  // Order Details State
  OrderDetailsResponse? _orderDetails;
  OrderDetailsResponse? get orderDetails => _orderDetails;

  String? _orderIdCreated;
  String? get orderIdCreated => _orderIdCreated;

  // Initialize and Fetch History
  Future<void> fetchOrders({
    required String accessToken,
    required String customerId,
    bool isRefresh = false,
  }) async {
    if (isRefresh) {
      _currentPage = 1;
      _orders = [];
      _hasMore = true;
      _isLoading = true;
    } else {
      if (!_hasMore || _isMoreLoading) return;
      if (_currentPage == 1) {
        _isLoading = true;
      } else {
        _isMoreLoading = true;
      }
    }
    notifyListeners();

    try {
      final json = await _dataSource.getOrderHistory(
        accessToken: accessToken,
        customerId: customerId,
        page: _currentPage,
        searchText: _searchText,
        startDate: _startDate,
        endDate: _endDate,
      );

      final response = OrderHistoryResponse.fromJson(json);

      if (response.status == 200) {
        if (_currentPage == 1) {
          _orders = response.results ?? [];
        } else {
          _orders.addAll(response.results ?? []);
        }

        _hasMore = (response.results?.length ?? 0) > 0;
        if (_hasMore) _currentPage++;
      } else {
        _hasMore = false;
        if (_currentPage == 1) _orders = [];
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      _isMoreLoading = false;
      notifyListeners();
    }
  }

  // Update Filters
  void updateFilters(String search, String start, String end) {
    _searchText = search;
    _startDate = start;
    _endDate = end;
  }

  void clearFilters() {
    _searchText = "";
    _startDate = "";
    _endDate = "";
  }

  // Fetch Order Details
  Future<void> fetchOrderDetails({
    required String accessToken,
    required String customerId,
    required String orderId,
  }) async {
    _isLoading = true;
    _orderDetails = null;
    notifyListeners();

    try {
      final json = await _dataSource.getOrderDetails(
        accessToken: accessToken,
        customerId: customerId,
        orderId: orderId,
      );
      _orderDetails = OrderDetailsResponse.fromJson(json);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Order Actions
  Future<bool> cancelOrder({
    required String accessToken,
    required String customerId,
    required String orderId,
  }) async {
    try {
      final json = await _dataSource.deleteOrder(
        accessToken: accessToken,
        customerId: customerId,
        orderId: orderId,
      );
      return json['status'] == 200;
    } catch (e) {
      return false;
    }
  }

  Future<String?> duplicateOrder({
    required String accessToken,
    required String customerId,
    required String oldOrderId,
  }) async {
    try {
      final json = await _dataSource.duplicateOrder(
        accessToken: accessToken,
        customerId: customerId,
        oldOrderId: oldOrderId,
      );
      if (json['status'] == 200) {
        _orderIdCreated = json['RefNo'];
        return _orderIdCreated;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> reorderOrder({
    required String accessToken,
    required String customerId,
    required String oldOrderId,
  }) async {
    try {
      final json = await _dataSource.reorderOrder(
        accessToken: accessToken,
        customerId: customerId,
        oldOrderId: oldOrderId,
      );
      return json['status'] == 200;
    } catch (e) {
      return false;
    }
  }
}
