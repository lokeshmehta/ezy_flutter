import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/common_methods.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/cart_models.dart';

class CartProvider extends ChangeNotifier {
  final AuthRemoteDataSource _remoteDataSource;

  CartProvider(this._remoteDataSource);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMsg;
  String? get errorMsg => _errorMsg;

  CartResponse? _cartResponse;
  CartResult? get cartResult => 
      (_cartResponse?.results != null && _cartResponse!.results!.isNotEmpty) 
      ? _cartResponse!.results![0] 
      : null;

  List<CartProduct> _flattenedCartItems = [];
  List<CartProduct> get flattenedCartItems => _flattenedCartItems;
  List<CartProduct> get cartItems => _flattenedCartItems;

  // Cart Stats (Getters for UI)
  String get subTotal => cartResult?.subTotal ?? "0.00";
  String get totalAmount => cartResult?.orderAmount ?? "0.00";
  String get discount => cartResult?.discount ?? "0.00";
  String get deliveryCharge => cartResult?.deliveryCharge ?? "0.00";
  String get locationDeliveryCharge => cartResult?.deliveryLocationCharge ?? "0.00";
  String get gst => cartResult?.gst ?? "0.00";
  String get deliveryChargeGst => cartResult?.deliveryChargeGst ?? "0.00";
  String get taxTotal => (double.tryParse(gst) ?? 0.0 + (double.tryParse(deliveryChargeGst) ?? 0.0)).toStringAsFixed(2);
  
  String get couponName => cartResult?.couponName ?? "";
  String get couponDiscount => cartResult?.couponDiscount ?? "0.00";
  String get suppliersExceededCharge => cartResult?.suppliersExceededShippingCharge ?? "0.00";



  Future<void> init() async {
    await fetchCartDetails();
  }

  Future<void> fetchCartDetails() async {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? "";
      final customerId = prefs.getString(StorageKeys.userId) ?? "";

      if (accessToken.isEmpty || customerId.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final response = await _remoteDataSource.getCartDetails(accessToken, customerId);
      _cartResponse = CartResponse.fromJson(response);

      if (_cartResponse?.status == 200) {
        _processCartData();
      } else {
        _errorMsg = _cartResponse?.message;
        _flattenedCartItems = [];
      }
    } catch (e) {
      _errorMsg = e.toString();
      _flattenedCartItems = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void _processCartData() {
    _flattenedCartItems = [];
    final result = cartResult;
    if (result == null || result.brands == null) return;

    // Flatten logic mirroring ShoppingCartFragment.kt
    for (var brand in result.brands!) {
      if (brand != null && brand.products != null) {
        for (var product in brand.products!) {
          if (product != null) {
            // Copy brand info into product
            product.brandId = brand.brandId;
            product.brandName = brand.brandName;
            _flattenedCartItems.add(product);
          }
        }
      }
    }
  }

  // Actions
  Future<void> updateCartItem(CartProduct item, String newQty) async {
    // Optimistic update? No, safer to wait for API as taxes/totals change complexly
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? "";
      final customerId = prefs.getString(StorageKeys.userId) ?? "";
      final accountNum = prefs.getString(StorageKeys.customerAccountNum) ?? "";

      final response = await _remoteDataSource.updateCartItem(
        accessToken: accessToken,
        customerId: customerId,
        productId: item.productId ?? "",
        brandId: item.brandId ?? "",
        qty: newQty,
        price: item.salePrice ?? "0", // Uses sale_price as price
        orderedAs: item.orderedAs ?? "Each",
        accNum: accountNum,
      );

      if (response['status'] == 200) {
        // Success -> Refresh Cart to get new totals
        await _updateGlobalCartStats(response);
        await fetchCartDetails(); 
      } else {
        _errorMsg = response['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMsg = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> deleteCartItem(CartProduct item) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? "";
      final customerId = prefs.getString(StorageKeys.userId) ?? "";

      final response = await _remoteDataSource.deleteCartItem(
        accessToken: accessToken,
        customerId: customerId,
        productId: item.productId ?? "",
        brandId: item.brandId ?? "",
      );

      if (response['status'] == 200) {
         await _updateGlobalCartStats(response);
         await fetchCartDetails();
      } else {
        _errorMsg = response['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMsg = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? "";
      final customerId = prefs.getString(StorageKeys.userId) ?? "";

      final response = await _remoteDataSource.clearCart(
        accessToken: accessToken,
        customerId: customerId,
      );

      if (response['status'] == 200) {
         await _updateGlobalCartStats(response);
         await fetchCartDetails();
      } else {
        _errorMsg = response['message'];
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _errorMsg = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _updateGlobalCartStats(Map<String, dynamic> response) async {
     final prefs = await SharedPreferences.getInstance();
     CommonMethods.cartCount = response['cart_quantity']?.toString() ?? CommonMethods.cartCount;
     CommonMethods.supplierCount = response['suppliers_count'] ?? CommonMethods.supplierCount;
     
     await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
  }
}
