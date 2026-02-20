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
  // Cart Stats (Getters for UI)
  String get subTotal {
    double apiSubTotal = double.tryParse(cartResult?.subTotal ?? "0") ?? 0;
    if (apiSubTotal > 0) return cartResult?.subTotal ?? "0.00";
    return _calculateLocalSubTotal().toStringAsFixed(2);
  }

  String get totalAmount {
    double apiTotal = double.tryParse(cartResult?.orderAmount ?? "0") ?? 0;
    if (apiTotal > 0) return cartResult?.orderAmount ?? "0.00";

    // Fallback calculation
    double localSub = _calculateLocalSubTotal();
    double delivery = double.tryParse(cartResult?.deliveryCharge ?? "0") ?? 0;
    double locDelivery = double.tryParse(cartResult?.deliveryLocationCharge ?? "0") ?? 0;
    // Note: gst and deliveryChargeGst are properties of this class calling cartResult
    double tax = double.tryParse(cartResult?.gst ?? "0") ?? 0;
    double delTax = double.tryParse(cartResult?.deliveryChargeGst ?? "0") ?? 0;
    double disc = double.tryParse(cartResult?.discount ?? "0") ?? 0;
    double supplierCharge = double.tryParse(cartResult?.suppliersExceededShippingCharge ?? "0") ?? 0;
    double couponDisc = double.tryParse(cartResult?.couponDiscount ?? "0") ?? 0;

    double calculatedTotal = localSub + delivery + locDelivery + tax + delTax + supplierCharge - disc - couponDisc;
    return calculatedTotal.toStringAsFixed(2);
  }

  String get discount => cartResult?.discount ?? "0.00";
  String get deliveryCharge => cartResult?.deliveryCharge ?? "0.00";
  String get locationDeliveryCharge => cartResult?.deliveryLocationCharge ?? "0.00";
  String get gst => cartResult?.gst ?? "0.00";
  String get deliveryChargeGst => cartResult?.deliveryChargeGst ?? "0.00";
  String get taxTotal => ((double.tryParse(gst) ?? 0.0) + (double.tryParse(deliveryChargeGst) ?? 0.0)).toStringAsFixed(2);
  
  String get couponName => cartResult?.couponName ?? "";
  String get couponDiscount => cartResult?.couponDiscount ?? "0.00";
  String get suppliersExceededCharge => cartResult?.suppliersExceededShippingCharge ?? "0.00";

  double _calculateLocalSubTotal() {
    double total = 0.0;
    for (var item in _flattenedCartItems) {
      double price = double.tryParse(item.salePrice ?? "0") ?? 0;
      if (price <= 0) {
        price = double.tryParse(item.normalPrice ?? "0") ?? 0;
      }
      int quantity = item.qty ?? 0;
      // If soldAs is Box/Carton, the price might be per unit or per carton depending on data.
      // In cart_item_refined_widget, we see logic:
      // price = (double.tryParse(item.salePrice ?? "0") ?? 0) > 0 ? item.salePrice : (item.normalPrice ?? "0.00")
      // And it just displays it.
      // In StepCartWidget, it sums up: (price * qty).
      total += price * quantity;
    }
    return total;
  }



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

        price: (double.tryParse(item.salePrice ?? "0") ?? 0) > 0 ? item.salePrice! : (item.normalPrice ?? "0"), // Uses sale_price as price, fallback to normal
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
  
  Future<void> _updateGlobalCartStats(Map<String, dynamic> response) async {
     final prefs = await SharedPreferences.getInstance();
     CommonMethods.cartCount = response['cart_quantity']?.toString() ?? CommonMethods.cartCount;
     CommonMethods.supplierCount = response['suppliers_count'] ?? CommonMethods.supplierCount;
     
     await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
  }
}
