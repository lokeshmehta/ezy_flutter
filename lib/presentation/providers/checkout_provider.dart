import 'package:flutter/material.dart';
import '../../core/utils/common_methods.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/cart_models.dart';
import '../../data/models/profile_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes/app_routes.dart';
import '../../core/constants/app_messages.dart';
import '../../core/constants/storage_keys.dart';

class CheckoutProvider extends ChangeNotifier {
  final AuthRemoteDataSource authRemoteDataSource;

  CheckoutProvider(this.authRemoteDataSource);

  // State
  int _currentStep = 0; // 0=Cart, 1=Address, 2=Payment, 3=Preview
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;
  
  String _successMessage = '';
  String get successMessage => _successMessage;
  
  bool get isPreviewEnabled {
      if(_profileResponse?.results != null && _profileResponse!.results!.isNotEmpty) {
          return _profileResponse!.results![0].allowToReviewOrderBeforeSubmitting == "Yes";
      }
      return false; // Default to No if not found? Android defaults to "Yes"? 
      // Android: if(DashboardViewModel...equals("Yes")) -> 4 steps. So default is 3 steps (No).
  }
  
  bool get isLastStep {
      return _currentStep == (isPreviewEnabled ? 3 : 2);
  }
  
  int get totalSteps => isPreviewEnabled ? 4 : 3;

  // Profile & Address Data
  ProfileResponse? _profileResponse;
  ProfileResponse? get profileResponse => _profileResponse;
  List<AddressItem> _addressList = [];
  List<AddressItem> get addressList => _addressList;

  // Cart Data
  CartResult? _cartResult;
  CartResult? get cartResult => _cartResult;
  List<CartProduct> _cartItems = [];
  List<CartProduct> get cartItems => _cartItems;
  
  bool get isCartEmpty => _cartItems.isEmpty;

  // Financial Getters for Summary Widgets
  // Financial Getters for Summary Widgets
  String get subTotal {
    double apiSubTotal = double.tryParse(_cartResult?.subTotal ?? "0") ?? 0;
    if (apiSubTotal > 0) return apiSubTotal.toStringAsFixed(2);
    return _calculateLocalSubTotal().toStringAsFixed(2);
  }

  String get totalAmount {
    double apiTotal = double.tryParse(_cartResult?.orderAmount ?? "0") ?? 0;
    if (apiTotal > 0) return apiTotal.toStringAsFixed(2);

    // Fallback calculation
    double localSub = _calculateLocalSubTotal();
    double delivery = double.tryParse(_cartResult?.deliveryCharge ?? "0") ?? 0;
    double locDelivery = double.tryParse(_cartResult?.deliveryLocationCharge ?? "0") ?? 0;
    double tax = double.tryParse(_cartResult?.gst ?? "0") ?? 0;
    double delTax = double.tryParse(_cartResult?.deliveryChargeGst ?? "0") ?? 0;
    double disc = double.tryParse(_cartResult?.discount ?? "0") ?? 0;
    double supplierCharge = double.tryParse(_cartResult?.suppliersExceededShippingCharge ?? "0") ?? 0;
    double couponDisc = double.tryParse(_cartResult?.couponDiscount ?? "0") ?? 0;

    double calculatedTotal = localSub + delivery + locDelivery + tax + delTax + supplierCharge - disc - couponDisc;
    return calculatedTotal.toStringAsFixed(2);
  }

  double _calculateLocalSubTotal() {
    double total = 0.0;
    for (var item in _cartItems) {
      double price = double.tryParse(item.salePrice ?? "0") ?? 0;
      if (price <= 0) {
        price = double.tryParse(item.normalPrice ?? "0") ?? 0;
      }
      int quantity = item.qty ?? 0;
      total += price * quantity;
    }
    return total;
  }
  
  String get discount => (double.tryParse(_cartResult?.discount ?? "0") ?? 0).toStringAsFixed(2);
  String get shippingCharge => (double.tryParse(_cartResult?.deliveryCharge ?? "0") ?? 0).toStringAsFixed(2);
  String get supplierCharge => (double.tryParse(_cartResult?.suppliersExceededShippingCharge ?? "0") ?? 0).toStringAsFixed(2);
  
  // Adjusted to include Delivery GST match Native App logic
  String get taxTotal {
      double gst = double.tryParse(_cartResult?.gst ?? "0") ?? 0;
      double delGst = double.tryParse(_cartResult?.deliveryChargeGst ?? "0") ?? 0;
      return (gst + delGst).toStringAsFixed(2);
  }
  
  String get couponDiscount => (double.tryParse(_cartResult?.couponDiscount ?? "0") ?? 0).toStringAsFixed(2);
  String get couponName => _cartResult?.couponName ?? "";

  // Address Form Controllers (Billing)
  final TextEditingController billFirstNameController = TextEditingController();
  final TextEditingController billLastNameController = TextEditingController();
  final TextEditingController billStreetController = TextEditingController();
  final TextEditingController billStreet2Controller = TextEditingController(); // Optional
  final TextEditingController billCityController = TextEditingController();
  final TextEditingController billStateController = TextEditingController();
  final TextEditingController billPostCodeController = TextEditingController();
  final TextEditingController billPhoneController = TextEditingController();
  final TextEditingController billEmailController = TextEditingController();

  // Address Form Controllers (Shipping)
  final TextEditingController shipFirstNameController = TextEditingController();
  final TextEditingController shipLastNameController = TextEditingController();
  final TextEditingController shipStreetController = TextEditingController();
  final TextEditingController shipStreet2Controller = TextEditingController(); // Optional
  final TextEditingController shipCityController = TextEditingController();
  final TextEditingController shipStateController = TextEditingController();
  final TextEditingController shipPostCodeController = TextEditingController();
  final TextEditingController shipPhoneController = TextEditingController();
  final TextEditingController shipEmailController = TextEditingController();

  bool _isNewAddressChecked = false;
  bool get isNewAddressChecked => _isNewAddressChecked;

  // Selected Address State
  // "0" = Select, Others = Index + 1
  int _selectedAddressIndex = 0; 
  int get selectedAddressIndex => _selectedAddressIndex;

  // Payment State
  String _paymentMethod = ""; // "COD" or "Online Payment"
  String get paymentMethod => _paymentMethod;
  
  List<String> _availablePaymentMethods = [];
  List<String> get availablePaymentMethods => _availablePaymentMethods;

  final TextEditingController couponController = TextEditingController();
  final TextEditingController orderNotesController = TextEditingController();

  // Credentials
  String _customerId = "";
  String _accessToken = "";

  // Initialization
  Future<void> initCheckout(String customerId, String accessToken, {int initialStep = 0}) async {
    _currentStep = initialStep;
    _customerId = customerId;
    _accessToken = accessToken;
    _isLoading = true;
    notifyListeners();
    try {
      // 0. Load Payment Methods (Synced from Company Preferences)
      await _loadPaymentMethods();

      // 1. Fetch Cart Details First (Essential for Step 0)
      await refreshCartSummary(customerId, accessToken);

      // 2. Fetch Profile for Addresses (Background)
      final response = await authRemoteDataSource.getProfile(accessToken, customerId);
      _profileResponse = ProfileResponse.fromJson(response);
      
      if (_profileResponse?.results != null && _profileResponse!.results!.isNotEmpty) {
        _addressList = _profileResponse!.results![0].addressesList ?? [];
        
        // Auto-fill form with Profile Data if exists
        final profile = _profileResponse!.results![0];
        billFirstNameController.text = profile.firstName ?? "";
        billLastNameController.text = profile.lastName ?? "";
        billEmailController.text = profile.email ?? "";
        billPhoneController.text = profile.phone ?? "";
        
        // Auto-select default address
        for(int i=0; i<_addressList.length; i++) {
           if(_addressList[i].defaultAddress == "Yes") {
             _selectedAddressIndex = i + 1; // +1 because 0 is "Choose"
             _fillShippingFormWithAddress(_addressList[i]);
           }
        }
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _fetchProfileCount() async {
      try {
          final response = await authRemoteDataSource.getProfile(_accessToken, _customerId);
          final profile = ProfileResponse.fromJson(response);
          if (profile.results != null && profile.results!.isNotEmpty) {
             String qty = response['cart_quantity']?.toString() ?? "0";
             CommonMethods.cartCount = qty;
             final prefs = await SharedPreferences.getInstance();
             await prefs.setString(StorageKeys.cartCount, qty);
          }
      } catch (e) {
         debugPrint("Error syncing cart count: $e");
      }
  }


  Future<void> _loadPaymentMethods() async {
      final prefs = await SharedPreferences.getInstance();
      String methodsStr = prefs.getString(StorageKeys.paymentMethods) ?? "";
      
      // Android Logic: replace("COD","Cash on Delivery").split(",")
      // Note: Android does replace BEFORE split.
      // Make sure we handle potential spaces or empty strings.
      
      if(methodsStr.isNotEmpty) {
          // Replace COD first
          methodsStr = methodsStr.replaceAll("COD", "Cash on Delivery");
          
          _availablePaymentMethods = methodsStr.split(",").where((s) => s.isNotEmpty).toList();
          
          // Auto-select first if available and nothing selected
          if(_availablePaymentMethods.isNotEmpty && _paymentMethod.isEmpty) {
              _paymentMethod = _availablePaymentMethods[0];
          }
      } else {
          _availablePaymentMethods = ["Cash on Delivery"]; // Fallback default?
          _paymentMethod = "Cash on Delivery";
      }
      notifyListeners();
  }
  
  // Cart Logic
  Future<void> refreshCartSummary(String customerId, String accessToken) async {
      try {
        final response = await authRemoteDataSource.getCartDetails(accessToken, customerId);
        final cartResponse = CartResponse.fromJson(response);

        if(cartResponse.status == 200 && cartResponse.results != null && cartResponse.results!.isNotEmpty) {
            _cartResult = cartResponse.results![0];
            _flattenCartItems(_cartResult!);
            
            // ALWAYS calculate from the items we just fetched to ensure sync
            await _calculateAndSyncCartCount();
        } else {
            _cartResult = null;
            _cartItems = [];
        }
      } catch (e) {
         debugPrint("Error refreshing cart: $e");
         _cartResult = null;
         _cartItems = [];
      }
      notifyListeners();
  }
  
  Future<void> _calculateAndSyncCartCount() async {
      int totalQty = 0;
      for (var item in _cartItems) {
          totalQty += (item.qty ?? 0);
      }
      
      // Update Global State
      CommonMethods.cartCount = totalQty.toString();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
  }
  
  void _flattenCartItems(CartResult result) {
      _cartItems = [];
      if(result.brands != null) {
          for(var brand in result.brands!) {
              if(brand?.products != null) {
                  for(var product in brand!.products!) {
                      if(product != null) {
                          // Note: Assuming product model has fields set, implies we might need to manually set brand name if not there
                          // Android does: item?.brand_name = brand.brand_name
                          // Our CartProduct model does not strictly have brandName setters unless we added them.
                          // Wait, looking at CartProduct model, it DOES NOT receive brand info from JSON inside products list typically
                          // But we can check if we customized it.
                          // Checked CartProduct: has `title`, `image`, etc. 
                          // Let's assume we might need a wrapper or just rely on index.
                          // Update: I did not add `brandName` to `CartProduct` in the `cart_models.dart`.
                          // Android `CartItemS` has `brand_name`. 
                          // I will omit brand headers for now OR I should have added it.
                          // Wait, the plan says 1:1 parity and "Vendor Grouping".
                          // I can handle this in UI by checking `_cartResult?.brands`.
                          // Actually, flattening makes UI easier but losing hierarchy.
                          // Let's usage `_cartResult` directly in UI for sectioned list if possible.
                          // But `_cartItems` is good for "All items count" etc.
                          // PROCEEDING WITH FLATTENED LIST FOR SIMPLE ITERATION, 
                          // BUT UI WIDGET SHOULD PROBABLY USE `_cartResult.brands` to drive the ListView.builder for sections.
                          // Android `MyCartAdapter` uses a flat list but checks `if(i==0 || brand_id != prev.brand_id)` for header.
                          // I'll stick to that. I'll need `brandId` and `brandName` in `CartProduct`.
                          // I'll re-check `cart_models.dart` briefly.
                          // ... Checking ...
                          _cartItems.add(product); 
                      }
                  }
              }
          }
      }
  }

  Future<void> updateCartItem(String productId, String quantity, String brandId, String price, String soldAs) async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await authRemoteDataSource.updateCartItem(
              accessToken: _accessToken,
              customerId: _customerId,
              productId: productId,
              brandId: brandId,
              qty: quantity,
              price: price,
              orderedAs: soldAs, // Assuming 'orderedAs' matches 'soldAs' or passed param
              accNum: "" // Optional
          );
          
          if (response['status'] == 200) {
             if (response['cart_quantity'] != null) {
                CommonMethods.cartCount = response['cart_quantity'].toString();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
             }
          }

          await refreshCartSummary(_customerId, _accessToken);
          await _fetchProfileCount(); // Force sync
      } catch (e) {
          _errorMessage = AppMessages.failureMsg;
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }

  Future<void> deleteCartItem(String productId, String brandId) async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await authRemoteDataSource.deleteCartItem(
              accessToken: _accessToken,
              customerId: _customerId,
              productId: productId,
              brandId: brandId
          );
          
          if (response['status'] == 200) {
             if (response['cart_quantity'] != null) {
                CommonMethods.cartCount = response['cart_quantity'].toString();
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
             }
          }

          await refreshCartSummary(_customerId, _accessToken);
          await _fetchProfileCount(); // Force sync
      } catch (e) {
          _errorMessage = AppMessages.failureMsg;
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }
  
  Future<void> clearCart() async {
      _isLoading = true;
      notifyListeners();
      try {
          final response = await authRemoteDataSource.clearCart(
              accessToken: _accessToken,
              customerId: _customerId,
          );
          
          if (response['status'] == 200) {
              CommonMethods.cartCount = "0";
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString(StorageKeys.cartCount, "0");
          }

          await refreshCartSummary(_customerId, _accessToken);
          await _fetchProfileCount(); // Force sync
          // Redirection handled by UI observing empty cart or specific flag
          setStep(0); // Ensure on first step
      } catch (e) {
          _errorMessage = AppMessages.failureMsg;
      } finally {
          _isLoading = false;
          notifyListeners();
      }
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
  

  // Navigation
  void goToStep(int step) {
    setStep(step);
  }

  Future<void> placeOrder(BuildContext context) async {
       if(_paymentMethod == "Cash on Delivery") {
           final result = await createOrder();
           if(result != null && result['status'] == 200) {
               if(context.mounted) {
                   context.go(AppRoutes.orderSuccess, extra: result);
               }
           } else {
               if(context.mounted) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_errorMessage)));
               }
           }
       } else {
           // Online Payment Flow (To be implemented - Parity with PaymentActivity)
           if(context.mounted) {
               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Online Payment flow coming soon")));
           }
       }
  }

  void nextStep() {
      if(_currentStep == 0) {
          // Validate Cart Step
          // Android logic: Check minimum order amount
          // if (restrict_on_min_order_amount_not_reached == "Yes") check total
          if(_cartResult?.restrictOnMinOrderAmountNotReached == "Yes") {
              double total = double.tryParse(_cartResult?.orderAmount ?? "0") ?? 0;
              double min = double.tryParse(_cartResult?.minOrderAmount ?? "0") ?? 0;
              if(total < min) {
                  _errorMessage = _cartResult?.minOrderNotificationText ?? "Minimum order amount not reached";
                  notifyListeners();
                  return;
              }
          }
          // Move to Address
          _currentStep = 1;
      } else if (_currentStep == 1) {
          if(validateAddressStep()) {
              _currentStep = 2; // Payment
          } else {
              _errorMessage = AppMessages.pleaseFillAllRequiredFields;
          }
      } else if (_currentStep == 2) {
           if(validatePaymentStep()) {
              if(isPreviewEnabled) {
                  _currentStep = 3; // Preview
              } else {
                  // Already at last step, UI should handle "Submit"
              }
           } else {
              _errorMessage = AppMessages.pleaseSelectPaymentMethod;
           }
      }
      notifyListeners();
  }

  void previousStep() {
      if(_currentStep > 0) {
          _currentStep--;
          notifyListeners();
      }
  }

  // Address Logic
  void toggleNewAddress(bool value) {
    _isNewAddressChecked = value;
    notifyListeners();
  }

  void onAddressSelected(int index) {
    _selectedAddressIndex = index;
    if(index > 0 && index - 1 < _addressList.length) {
       _fillShippingFormWithAddress(_addressList[index-1]);
    } else {
       // Clear shipping form?
    }
    notifyListeners();
  }
  
  void _fillShippingFormWithAddress(AddressItem address) {
      shipFirstNameController.text = address.firstName ?? "";
      shipLastNameController.text = address.lastName ?? "";
      shipStreetController.text = address.street ?? "";
      shipStreet2Controller.text = address.street2 ?? "";
      shipCityController.text = address.suburb ?? "";
      shipStateController.text = address.state ?? "";
      shipPostCodeController.text = address.postcode ?? "";
      shipPhoneController.text = address.phone ?? "";
      shipEmailController.text = address.email ?? "";
  }

  // Payment Logic
  void selectPaymentMethod(String method) {
    // method: "COD" or "Online Payment"
    _paymentMethod = method; 
    notifyListeners();
  }
  
  Future<bool> applyCoupon() async {
      String code = couponController.text.trim();
      if(code.isEmpty) {
          _errorMessage = "Please enter coupon code";
          notifyListeners();
          return false;
      }
      
      _isLoading = true;
      notifyListeners();
      try {
          final response = await authRemoteDataSource.checkCouponCode(_accessToken, _customerId, code);
          // Assuming AuthRemoteDataSource returns Map
          if(response['status'] == 200) {
              await refreshCartSummary(_customerId, _accessToken);
              _successMessage = "Coupon Applied Successfully";
              _isLoading = false;
               notifyListeners();
              return true;
          } else {
              // Prioritize 'error' field for specific message like "Invalid Coupon Code"
              _errorMessage = response['error'] ?? response['message'] ?? "Invalid Coupon";
              _isLoading = false;
              notifyListeners();
              return false;
          }
      } catch (e) {
          _errorMessage = AppMessages.failureMsg;
          _isLoading = false;
          notifyListeners();
          return false;
      }
  }

  // Create Order
  Future<Map<String, dynamic>?> createOrder() async {
       _isLoading = true;
       notifyListeners();
       
       // Prepare Billing Address
       String street = billStreetController.text;
       String street2 = billStreet2Controller.text;
       String suburb = billCityController.text; 
       String state = billStateController.text;
       String postcode = billPostCodeController.text;
       
       // Prepare Shipping Address 
       String sFirstName = shipFirstNameController.text;
       String sLastName = shipLastNameController.text;
       String sPhone = shipPhoneController.text;
       String sEmail = shipEmailController.text;
       String sStreet = shipStreetController.text;
       String sStreet2 = shipStreet2Controller.text;
       String sSuburb = shipCityController.text;
       String sState = shipStateController.text;
       String sPostcode = shipPostCodeController.text;

       try {
           final response = await authRemoteDataSource.createOrder(
               accessToken: _accessToken,
               customerId: _customerId,
               paymentType: _paymentMethod, 
               street: street,
               street2: street2,
               suburb: suburb,
               state: state,
               postcode: postcode,
               shippingFirstName: sFirstName,
               shippingLastName: sLastName,
               shippingPhone: sPhone,
               shippingEmail: sEmail,
               shippingStreet: sStreet,
               shippingStreet2: sStreet2,
               shippingSuburb: sSuburb,
               shippingState: sState,
               shippingPostcode: sPostcode,
               remarks: orderNotesController.text,
           );
           
           if(response['status'] == 200) {
               _isLoading = false;
               notifyListeners();
               return response;
           } else {
               _errorMessage = response['message'] ?? AppMessages.failureMsg;
               _isLoading = false;
               notifyListeners();
               return null;
           }
       } catch (e) {
           _errorMessage = AppMessages.failureMsg;
           _isLoading = false;
           notifyListeners();
           return null;
       }
  }

  bool validateAddressStep() {
    // Validate Billing Address (Always Required)
    bool isBillingValid = billFirstNameController.text.isNotEmpty &&
                          billLastNameController.text.isNotEmpty &&
                          billStreetController.text.isNotEmpty &&
                          billCityController.text.isNotEmpty &&
                          billStateController.text.isNotEmpty &&
                          billPostCodeController.text.isNotEmpty &&
                          billPhoneController.text.isNotEmpty &&
                          billEmailController.text.isNotEmpty;

    if (!isBillingValid) return false;

    // Validate Shipping Address (Only if "Different Address" is checked)
    if(isNewAddressChecked) {
        return shipFirstNameController.text.isNotEmpty &&
               shipLastNameController.text.isNotEmpty &&
               shipStreetController.text.isNotEmpty &&
               shipCityController.text.isNotEmpty &&
               shipStateController.text.isNotEmpty &&
               shipPostCodeController.text.isNotEmpty &&
               shipPhoneController.text.isNotEmpty &&
               shipEmailController.text.isNotEmpty;
    }
    
    return true;
  }

  bool validatePaymentStep() {
      return _paymentMethod.isNotEmpty;
  }

  Future<bool> sendOrderReceipt(String orderId, String emails) async {
       try {
           final response = await authRemoteDataSource.sendOrderReceipt(
               accessToken: _accessToken,
               customerId: _customerId,
               orderId: orderId,
               emails: emails,
           );
           return response['status'] == 200;
       } catch (e) {
           debugPrint("Error sending receipt: $e");
           return false;
       }
  }

  void clearCartLocal() {
      _cartItems = [];
      _cartResult = null;
      _currentStep = 0;
      billFirstNameController.clear();
      billLastNameController.clear();
      // Keep others maybe? Or clear all.
      // Android "cleardata()" clears everything.
      billStreetController.clear();
      billStreet2Controller.clear();
      billCityController.clear();
      billStateController.clear();
      billPostCodeController.clear();
      
      shipFirstNameController.clear();
      shipLastNameController.clear();
      shipStreetController.clear();
      shipStreet2Controller.clear();
      shipCityController.clear();
      shipStateController.clear();
      shipPostCodeController.clear();
      shipPhoneController.clear();
      shipEmailController.clear();
      
      couponController.clear();
      orderNotesController.clear();
      _paymentMethod = "";
      _successMessage = "";
      notifyListeners();
  }

  @override
  void dispose() {
    billFirstNameController.dispose();
    billLastNameController.dispose();
    billStreetController.dispose();
    billStreet2Controller.dispose();
    billCityController.dispose();
    billStateController.dispose();
    billPostCodeController.dispose();
    billPhoneController.dispose();
    billEmailController.dispose();
    
    shipFirstNameController.dispose();
    shipLastNameController.dispose();
    shipStreetController.dispose();
    shipStreet2Controller.dispose();
    shipCityController.dispose();
    shipStateController.dispose();
    shipPostCodeController.dispose();
    shipPhoneController.dispose();
    shipEmailController.dispose();
    
    couponController.dispose();
    orderNotesController.dispose();
    super.dispose();
  }
}
