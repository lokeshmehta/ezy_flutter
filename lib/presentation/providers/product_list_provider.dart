import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/utils/common_methods.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/models/product_models.dart';
import '../../data/models/home_models.dart';

class ProductListProvider extends ChangeNotifier {
  final AuthRemoteDataSource _remoteDataSource;

  ProductListProvider(this._remoteDataSource);

  // State
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ProductsResponse? _productsResponse;
  ProductsResponse? get productsResponse => _productsResponse;

  FilterProductResponse? _filterProductResponse;
  FilterProductResponse? get filterProductResponse => _filterProductResponse;

  FilterProductResponse? _allFilterProductResponse; // Popular/Default filters
  FilterProductResponse? get allFilterProductResponse => _allFilterProductResponse;

  ProductSortResponse? _productSortResponse;
  ProductSortResponse? get productSortResponse => _productSortResponse;

  ProductDetailItem? _productDetailItem;
  ProductDetailItem? get productDetailItem => _productDetailItem;

  List<ProductItem> _products = [];
  List<ProductItem> get products => _products;

  int _pageCount = 1;
  int get pageCount => _pageCount;

  String _searchText = "";
  String get searchText => _searchText;

  bool _isGridView = false;
  bool get isGridView => _isGridView;

  String _errorMsg = "";
  String get errorMsg => _errorMsg;

  String? _accessToken;
  String? _customerId;
  String? _accountNum;

  // Filter Lists
  List<FilterDivision> get divisionslist => _filterProductResponse?.divisions?.whereType<FilterDivision>().toList() ?? [];
  List<FilterGroup> get groupslist => _filterProductResponse?.groups?.whereType<FilterGroup>().toList() ?? 
                                     _filterProductResponse?.groupNames?.whereType<FilterGroup>().toList() ?? [];
  List<FilterSupplier> get supplierslist => _filterProductResponse?.suppliers?.whereType<FilterSupplier>().toList() ?? [];
  List<FilterTag> get tagslist => _filterProductResponse?.tags?.whereType<FilterTag>().toList() ?? [];
  List<SortItem> get sortList => _productSortResponse?.results?.whereType<SortItem>().toList() ?? [];

  String _divisionName = "";
  String get divisionName => _divisionName;

  // Initialize and fetch initial data matching ProductListViewModel.kt init
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(StorageKeys.accessToken) ?? "";
    _customerId = prefs.getString(StorageKeys.userId) ?? "0";
    _accountNum = prefs.getString(StorageKeys.customerAccountNum) ?? "";

    // Logic matching Handler(Looper.getMainLooper()).postDelayed in Android
    if (CommonMethods.productsBack == "suppliers") {
      CommonMethods.groupIDs = "";
      CommonMethods.selecetedProducts = "";
    } else if (CommonMethods.productsBack == "Banners") {
      // Keep values from CommonMethods
    } else {
      if (CommonMethods.productsBack != "dashboard_popcat") {
        CommonMethods.groupIDs = "";
      }
      CommonMethods.selecetedProducts = "";
    }

    if (CommonMethods.selectFirstTime == "Yes") {
      CommonMethods.supplierIDs = CommonMethods.firstSuppliers;
      CommonMethods.groupIDs = CommonMethods.firstGroupids;
      CommonMethods.categoryIDs = CommonMethods.firstCatIds;
      CommonMethods.selecetedProducts = CommonMethods.firstSelProds;
      CommonMethods.tagIDs = CommonMethods.firstTags;
      CommonMethods.selectFirstTime = "";
    }

    if (CommonMethods.productsBack == "Banners" || CommonMethods.productsBack == "suppliers") {
      await fetchAllFilterOptions("1");
    } else {
      if (CommonMethods.productsBack == "dashboard_popcat") {
        await fetchAllFilterOptionsPopular();
      } else {
        await fetchAllFilterOptionsDefault();
      }
    }
  }

  Future<void> fetchAllFilterOptionsDefault() async {
    _setLoading(true);
    try {
      final response = await _remoteDataSource.getAllFilterProducts(
        accessToken: _accessToken!,
        customerId: _customerId!,
        productsType: "All Products",
      );
      _allFilterProductResponse = FilterProductResponse.fromJson(response);
      
      // Chaining logic from Android
      await fetchAllFilterOptions("0");
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchAllFilterOptionsPopular() async {
    _setLoading(true);
    try {
      String divisionId = "";
      String selectedDivisions = "";
      if (CommonMethods.categoryIDs.contains(",")) {
        selectedDivisions = CommonMethods.categoryIDs;
      } else {
        divisionId = CommonMethods.categoryIDs;
      }

      final response = await _remoteDataSource.getAllFilterProducts(
        accessToken: _accessToken!,
        customerId: _customerId!,
        divisionId: divisionId,
        selectedDivisions: selectedDivisions,
        productsType: CommonMethods.filterSelected,
      );
      _allFilterProductResponse = FilterProductResponse.fromJson(response);
      
      await fetchAllFilterOptions("3");
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchAllFilterOptions(String type) async {
    if (type == "1" || type == "2") {
      _setLoading(true);
    }

    try {
      String divisionId = "";
      String selectedDivisions = "";
      String brandId = "";
      String selectedBrands = "";
      String groupId = "";
      String selectedGroups = "";

      if (CommonMethods.supplierIDs.contains(",")) {
        selectedBrands = CommonMethods.supplierIDs;
      } else {
        brandId = CommonMethods.supplierIDs;
      }

      // division filter matching Android logic
      if (CommonMethods.productsBack != "suppliers") {
        if (CommonMethods.categoryIDs.contains(",")) {
          selectedDivisions = CommonMethods.categoryIDs;
        } else {
          divisionId = CommonMethods.categoryIDs;
        }
      }

      // group filter matching Android logic
      if (CommonMethods.productsBack == "dashboard_popcat" && (type == "2" || type == "3")) {
        if (CommonMethods.groupIDs.contains(",")) {
          selectedGroups = CommonMethods.groupIDs;
        } else {
          groupId = CommonMethods.groupIDs;
        }
      }

      final response = await _remoteDataSource.getAllFilterProducts(
        accessToken: _accessToken!,
        customerId: _customerId!,
        divisionId: divisionId,
        brandId: brandId,
        selectedBrands: selectedBrands,
        groupId: groupId,
        selectedDivisions: selectedDivisions,
        selectedGroups: selectedGroups,
        selectedProducts: CommonMethods.selecetedProducts,
        productsType: CommonMethods.filterSelected,
      );
      
      _filterProductResponse = FilterProductResponse.fromJson(response);
      
      if (_filterProductResponse?.divisionNames != null && _filterProductResponse!.divisionNames!.isNotEmpty) {
        _divisionName = _filterProductResponse!.divisionNames![0]?.groupLevel1 ?? "";
      } else {
        _divisionName = "";
      }

      if (type == "first" || type == "1" || type == "0" || type == "3") { // type first logic
        await fetchProductSortOptions();
      } else if (type == "show") {
        await fetchProducts(page: 1);
      } else {
        _setLoading(false);
      }
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchProductSortOptions() async {
    try {
      final response = await _remoteDataSource.getProductSortOptions(_accessToken!, _customerId!);
      _productSortResponse = ProductSortResponse.fromJson(response);
      
      if (_productSortResponse?.status == 200) {
        // Continue to fetching products
        await fetchProducts(page: 1);
      } else {
        await fetchProducts(page: 1);
      }
    } catch (e) {
      debugPrint("Sort options error: $e");
      await fetchProducts(page: 1);
    }
  }

  Future<void> fetchProducts({required int page, bool isLoadMore = false}) async {
    if (!isLoadMore) {
      _setLoading(true);
      _products = [];
      _pageCount = 1;
    }

    try {
      final response = await _remoteDataSource.getProducts(
        accessToken: _accessToken!,
        customerId: _customerId!,
        brandId: CommonMethods.supplierIDs,
        divisionId: CommonMethods.categoryIDs,
        groupId: CommonMethods.groupIDs,
        page: page,
        orderby: CommonMethods.sortIDs,
        tagId: CommonMethods.tagIDs,
        productsType: CommonMethods.filterSelected,
        searchText: _searchText,
        products: CommonMethods.selecetedProducts,
      );

      _productsResponse = ProductsResponse.fromJson(response);
      
      if (_productsResponse?.status == 200) {
        if (isLoadMore) {
          _products.addAll(_productsResponse?.results?.whereType<ProductItem>() ?? []);
          _pageCount = page;
        } else {
          _products = _productsResponse?.results?.whereType<ProductItem>().toList() ?? [];
        }
      } else {
        if (!isLoadMore) _products = [];
      }
      _setLoading(false);
    } catch (e) {
      _errorMsg = e.toString();
      _setLoading(false);
    }
  }

  Future<void> fetchProductDetails(String productId) async {
    _setLoading(true);
    _productDetailItem = null;
    try {
      final response = await _remoteDataSource.getProductDetails(_accessToken!, _customerId!, productId);
      final detailsResponse = ProductDetailsResponse.fromJson(response);
      
      if (detailsResponse.status == 200 && detailsResponse.results != null && detailsResponse.results!.isNotEmpty) {
        _productDetailItem = detailsResponse.results![0];
      }
    } catch (e) {
      debugPrint("Fetch product details error: $e");
      _errorMsg = e.toString();
    }
    _setLoading(false);
  }

  // Selection Toggles
  void toggleDivisionSelection(int index) {
    var item = _filterProductResponse?.divisions?[index];
    if (item != null) {
      item.selected = item.selected == "Yes" ? "No" : "Yes";
      _updateCategoryIds();
      notifyListeners();
    }
  }

  void toggleGroupSelection(int index) {
    final groups = _filterProductResponse?.groups ?? _filterProductResponse?.groupNames;
    var item = groups?[index];
    if (item != null) {
      item.groupSelected = item.groupSelected == "Yes" ? "No" : "Yes";
      _updateGroupIds();
      notifyListeners();
    }
  }

  void toggleSupplierSelection(int index) {
    var item = _filterProductResponse?.suppliers?[index];
    if (item != null) {
      item.selected = item.selected == "Yes" ? "No" : "Yes";
      _updateBrandIds();
      notifyListeners();
    }
  }

  void toggleTagSelection(int index) {
    var item = _filterProductResponse?.tags?[index];
    if (item != null) {
      item.tagSelected = item.tagSelected == "Yes" ? "No" : "Yes";
      _updateTagIds();
      notifyListeners();
    }
  }

  void onSortSelected(SortItem option) {
    // Clear all other selections
    _productSortResponse?.results?.forEach((item) {
      item?.selected = "No";
    });
    option.selected = "Yes";
    CommonMethods.sortIDs = option.value ?? "";
    fetchProducts(page: 1);
    notifyListeners();
  }

  void onFilterSubmit() {
    CommonMethods.supplierIDs = _getBrandIds();
    CommonMethods.categoryIDs = _getCategoryIds();
    CommonMethods.tagIDs = _getTagIds();
    CommonMethods.groupIDs = _getGroupIds();
    
    _searchText = "";
    _pageCount = 1;
    fetchProducts(page: 1);
  }

  void onFilterClear() {
    CommonMethods.supplierIDs = CommonMethods.firstSuppliers;
    CommonMethods.categoryIDs = CommonMethods.firstCatIds;
    CommonMethods.tagIDs = CommonMethods.firstTags;
    CommonMethods.groupIDs = CommonMethods.firstGroupids;
    CommonMethods.selecetedProducts = CommonMethods.firstSelProds;

    _searchText = "";
    _pageCount = 1;
    fetchAllFilterOptions("1");
  }

  void onProductAvaSelected(String selection) {
    if (selection == "Show Products") {
      CommonMethods.filterSelected = "All Products";
      onFilterClear();
    } else {
      CommonMethods.filterSelected = selection;
      CommonMethods.supplierIDs = CommonMethods.firstSuppliers;
      CommonMethods.categoryIDs = CommonMethods.firstCatIds;
      CommonMethods.tagIDs = CommonMethods.firstTags;
      CommonMethods.groupIDs = CommonMethods.firstGroupids;
      CommonMethods.selecetedProducts = CommonMethods.firstSelProds;

      _searchText = "";
      _pageCount = 1;
      fetchAllFilterOptions("show");
    }
    notifyListeners();
  }

  // Internal helper to update CommonMethods strings matching selection
  void _updateCategoryIds() {
    CommonMethods.categoryIDs = _getCategoryIds();
  }

  void _updateGroupIds() {
    CommonMethods.groupIDs = _getGroupIds();
  }

  void _updateBrandIds() {
    CommonMethods.supplierIDs = _getBrandIds();
  }

  void _updateTagIds() {
    CommonMethods.tagIDs = _getTagIds();
  }

  String _getCategoryIds() {
    return _filterProductResponse?.divisions
            ?.where((e) => e?.selected == "Yes")
            .map((e) => e?.divisionId)
            .join(",") ?? "";
  }

  String _getGroupIds() {
    final groups = _filterProductResponse?.groups ?? _filterProductResponse?.groupNames;
    return groups
            ?.where((e) => e?.groupSelected == "Yes")
            .map((e) => e?.groupId)
            .join(",") ?? "";
  }

  String _getBrandIds() {
    return _filterProductResponse?.suppliers
            ?.where((e) => e?.selected == "Yes")
            .map((e) => e?.brandId)
            .join(",") ?? "";
  }

  String _getTagIds() {
    return _filterProductResponse?.tags
            ?.where((e) => e?.tagSelected == "Yes")
            .map((e) => e?.tagId)
            .join(",") ?? "";
  }

  // UI interaction methods
  void setGridView(bool value) {
    _isGridView = value;
    notifyListeners();
  }

  void setSearchText(String text) {
    _searchText = text;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Cart Management logic matching ProductListViewModel.kt
  Future<void> addToCart(ProductItem product, String qty, String orderedAs) async {
    _setLoading(true);
    try {
      final response = await _remoteDataSource.addToCart(
        accessToken: _accessToken!,
        customerId: _customerId!,
        productId: product.productId!,
        qty: qty,
        price: product.price ?? "0.00",
        orderedAs: orderedAs,
        apiData: product.apiData ?? "",
        accNum: _accountNum!,
      );

      if (response['status'] == 200) {
        await _updateCartStats(response);
        
        // Update local product state
        final index = _products.indexWhere((p) => p.productId == product.productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            addedToCart: "Yes",
            addedQty: qty,
            orderedAs: orderedAs,
          );
        }
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    _setLoading(false);
  }

  Future<void> updateCart(ProductItem product, String qty, String orderedAs) async {
    _setLoading(true);
    try {
      final response = await _remoteDataSource.updateCartItem(
        accessToken: _accessToken!,
        customerId: _customerId!,
        productId: product.productId!,
        brandId: product.brandId!,
        qty: qty,
        price: product.price ?? "0.00",
        orderedAs: orderedAs,
        accNum: _accountNum!,
      );

      if (response['status'] == 200) {
        await _updateCartStats(response);
        
        final index = _products.indexWhere((p) => p.productId == product.productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            addedToCart: "Yes",
            addedQty: qty,
            orderedAs: orderedAs,
          );
        }
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    _setLoading(false);
  }

  Future<void> deleteFromCart(ProductItem product) async {
    _setLoading(true);
    try {
      final response = await _remoteDataSource.deleteCartItem(
        accessToken: _accessToken!,
        customerId: _customerId!,
        productId: product.productId!,
        brandId: product.brandId!,
      );

      if (response['status'] == 200) {
        await _updateCartStats(response);
        
        final index = _products.indexWhere((p) => p.productId == product.productId);
        if (index != -1) {
          _products[index] = _products[index].copyWith(
            addedToCart: "No",
            addedQty: "0",
            addedSubTotal: "0.000",
          );
        }
      }
    } catch (e) {
      _errorMsg = e.toString();
    }
    _setLoading(false);
  }

  Future<void> _updateCartStats(Map<String, dynamic> response) async {
    final prefs = await SharedPreferences.getInstance();
    CommonMethods.cartCount = response['cart_quantity']?.toString() ?? "0";
    CommonMethods.supplierCount = response['suppliers_count'] ?? 0;
    CommonMethods.suppliers = response['suppliers']?.toString() ?? "";
    
    await prefs.setString(StorageKeys.cartCount, CommonMethods.cartCount);
    await prefs.setInt(StorageKeys.supplierCount, CommonMethods.supplierCount);
    await prefs.setString(StorageKeys.suppliers, CommonMethods.suppliers);
    notifyListeners();
  }

  // Navigation helper methods for dashboard filtering
  void clearFilters() {
    CommonMethods.resetProductFilters();
    notifyListeners();
  }

  void setCategory(String categoryId) {
    CommonMethods.categoryIDs = categoryId;
    CommonMethods.productsBack = "dashboard_popcat";
    notifyListeners();
  }

  void setSupplier(String supplierId) {
    CommonMethods.supplierIDs = supplierId;
    CommonMethods.productsBack = "suppliers";
    notifyListeners();
  }

  void setGroup(String groupId) {
    CommonMethods.groupIDs = groupId;
    CommonMethods.productsBack = "Banners";
    notifyListeners();
  }

  void setSelectedProducts(String productIds) {
    CommonMethods.selecetedProducts = productIds;
    CommonMethods.productsBack = "Banners";
    notifyListeners();
  }
}

// Helper extension for copyWith if not present in ProductItem
extension ProductItemCopyWith on ProductItem {
  ProductItem copyWith({
    String? addedToCart,
    String? addedQty,
    String? addedSubTotal,
    String? orderedAs,
  }) {
    return ProductItem(
      productId: productId,
      name: name,
      title: title,
      description: description,
      shortDescription: shortDescription,
      image: image,
      brandName: brandName,
      brandId: brandId,
      price: price,
      promotionPrice: promotionPrice,
      stockUnlimited: stockUnlimited,
      qtyStatus: qtyStatus,
      availableStockQty: availableStockQty,
      minimumOrderQty: minimumOrderQty,
      soldAs: soldAs,
      isFavourite: isFavourite,
      productAvailable: productAvailable,
      supplierAvailable: supplierAvailable,
      notAvailableDaysMessage: notAvailableDaysMessage,
      addedToCart: addedToCart ?? this.addedToCart,
      addedQty: addedQty ?? this.addedQty,
      addedSubTotal: addedSubTotal ?? this.addedSubTotal,
      orderedAs: orderedAs ?? this.orderedAs,
      qtyPerOuter: qtyPerOuter,
      apiData: apiData,
      divisionId: divisionId,
      groupId: groupId,
      sku: sku,
      gst: gst,
      gstPercentage: gstPercentage,
      fromDate: fromDate,
      toDate: toDate,
      hasPromotion: hasPromotion,
      label: label,
      discountPercentage: discountPercentage,
      discountId: discountId,
      discountName: discountName,
      wishlistId: wishlistId,
      wishlistCategoryId: wishlistCategoryId,
    );
  }
}
