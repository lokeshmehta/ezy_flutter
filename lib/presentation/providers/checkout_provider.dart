
import 'package:flutter/material.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/profile_models.dart';

// import '../../core/constants/common_methods.dart' as common; // Removed invalid import

class CheckoutProvider extends ChangeNotifier {
  final AuthRemoteDataSource authRemoteDataSource;

  CheckoutProvider(this.authRemoteDataSource);

  // State
  int _currentStep = 0;
  int get currentStep => _currentStep;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Profile & Address Data
  ProfileResponse? _profileResponse;
  ProfileResponse? get profileResponse => _profileResponse;
  List<AddressItem> _addressList = [];
  List<AddressItem> get addressList => _addressList;

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
  final TextEditingController couponController = TextEditingController();
  final TextEditingController orderNotesController = TextEditingController();

  // Cart Summary (Synced from CartProvider or API)
  // Android logic uses static CommonMethods variables, we will use local state synced from API
  String _subTotal = "0.00";
  String get subTotal => _subTotal;
  String _totalAmount = "0.00";
  String get totalAmount => _totalAmount;
  String _discount = "0.00";
  String get discount => _discount;
  String _shippingCharge = "0.00";
  String get shippingCharge => _shippingCharge; // deliveryCharges
  String _taxTotal = "0.00"; // taxCharges
  String get taxTotal => _taxTotal;
  String _supplierCharge = "0.00";
  String get supplierCharge => _supplierCharge;
  
  String _couponName = "";
  String get couponName => _couponName;
  String _couponDiscount = "0.00";
  String get couponDiscount => _couponDiscount;

  // Credentials
  String _customerId = "";
  String _accessToken = "";

  // Initialization
  Future<void> initCheckout(String customerId, String accessToken) async {
    _customerId = customerId;
    _accessToken = accessToken;
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch Profile for Addresses
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
        
        // If address list has default, select it? 
        // Logic from AddressesFragment.kt:257
        for(int i=0; i<_addressList.length; i++) {
           if(_addressList[i].defaultAddress == "Yes") {
             _selectedAddressIndex = i + 1; // +1 because 0 is "Choose"
             _fillShippingFormWithAddress(_addressList[i]);
           }
        }
      }
      
      // Also Fetch Cart Details to get latest prices
      await refreshCartSummary(customerId, accessToken);

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> refreshCartSummary(String customerId, String accessToken) async {
      final cartResponse = await authRemoteDataSource.getCartDetails(accessToken, customerId);
      // Parse basic fields
      if(cartResponse['status'] == 200 && cartResponse['results'] != null) {
          final result = cartResponse['results'][0];
          _subTotal = result['sub_total']?.toString() ?? "0.00";
          _totalAmount = result['order_amount']?.toString() ?? "0.00";
          _discount = result['discount']?.toString() ?? "0.00";
          _shippingCharge = result['delivery_charge']?.toString() ?? "0.00";
          
          double gst = double.tryParse(result['gst']?.toString() ?? "0") ?? 0.0;
          double delGst = double.tryParse(result['delivery_charge_gst']?.toString() ?? "0") ?? 0.0;
          _taxTotal = (gst + delGst).toStringAsFixed(2);
          
          _supplierCharge = result['suppliers_exceeded_shipping_charge']?.toString() ?? "0.00";
          _couponDiscount = result['coupon_discount']?.toString() ?? "0.00";
          _couponName = result['coupon_name']?.toString() ?? "";
          
          // Adjust total if coupon exists (Android logic: order_amount - coupon_discount)
          // Actually Android: totalAmountVal = it.results?.get(0)?.order_amount?.toDouble()!!-couponval
          double orderAmt = double.tryParse(_totalAmount) ?? 0.0;
          double couponVal = double.tryParse(_couponDiscount) ?? 0.0;
           _totalAmount = (orderAmt - couponVal).toStringAsFixed(2);
      }
      notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
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
    _paymentMethod = method; // "COD" or "Online Payment"
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
          if(response['status'] == 200) {
             // Success - Refresh Cart to see updated prices
             await refreshCartSummary(_customerId, _accessToken);
             _isLoading = false;
             return true;
          } else {
             _errorMessage = response['message'] ?? "Invalid Coupon";
             _isLoading = false;
             notifyListeners();
             return false;
          }
      } catch (e) {
          _errorMessage = e.toString();
          _isLoading = false;
          notifyListeners();
          return false;
      }
  }

  // Create Order
  Future<bool> createOrder() async {
       _isLoading = true;
       notifyListeners();
       
       // Prepare Billing Address
       String street = billStreetController.text;
       String street2 = billStreet2Controller.text;
       String suburb = billCityController.text; // Android maps city to suburb
       String state = billStateController.text;
       String postcode = billPostCodeController.text;
       
       // Prepare Shipping Address (Map properly based on New/Selected)
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
               paymentType: _paymentMethod == "COD" ? "COD" : "Online Payment", // Match Android values
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
               return true;
           } else {
               _errorMessage = response['message'] ?? "Order creation failed";
               _isLoading = false;
               notifyListeners();
               return false;
           }
       } catch (e) {
           _errorMessage = e.toString();
           _isLoading = false;
           notifyListeners();
           return false;
       }
  }

  // Navigation & Validation
  void nextStep() {
      if(_currentStep < 2) {
          _currentStep++;
          notifyListeners();
      }
  }

  void previousStep() {
      if(_currentStep > 0) {
          _currentStep--;
          notifyListeners();
      }
  }

  bool validateAddressStep() {
      if(isNewAddressChecked) {
          return shipFirstNameController.text.isNotEmpty && 
                 shipLastNameController.text.isNotEmpty &&
                 shipStreetController.text.isNotEmpty &&
                 shipCityController.text.isNotEmpty &&
                 shipStateController.text.isNotEmpty &&
                 shipPostCodeController.text.isNotEmpty &&
                 shipPhoneController.text.isNotEmpty;
      } else {
          return billFirstNameController.text.isNotEmpty && billPhoneController.text.isNotEmpty; 
      }
  }

  bool validatePaymentStep() {
      return _paymentMethod.isNotEmpty;
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
