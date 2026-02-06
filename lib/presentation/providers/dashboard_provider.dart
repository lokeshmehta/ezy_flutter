import 'package:flutter/material.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/models/home_models.dart';
import '../../../data/models/wishlist_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/constants/url_api_key.dart';

class DashboardProvider extends ChangeNotifier {
  final AuthRemoteDataSource _dataSource;

  // State
  bool _isLoading = false;
  String? _errorMsg;

  // Data Models
  ProfileResponse? _profileResponse;
  BannersResponse? _bannersResponse;
  FooterBannersResponse? _footerBannersResponse;
  HomeBlocksResponse? _homeBlocksResponse;
  
  // Section Data
  PromotionsResponse? _promotionsResponse;
  DashboardProductsResponse? _bestSellersResponse;
  FlashDealsResponse? _flashDealsResponse;
  DashboardProductsResponse? _newArrivalsResponse;
  DashboardProductsResponse? _hotSellingResponse;
  PopularCategoriesResponse? _popularCategoriesResponse;
  SupplierLogosResponse? _supplierLogosResponse;
  DashboardProductsResponse? _recentlyAddedResponse;
  PopularAdvertosementsResponse? _popularAdvertisementsResponse;

  // Wishlist State
  WishlistCategoriesResponse? _wishlistCategoriesResponse;
  bool _isFetchingWishlistCategories = false;
  // Company Config
  String? _companyImage;


  // Pagination Pages (Defaults to 1 as per Android)
  int promotionPage = 1;
  int bestSellersPage = 1;
  int flashDealsPage = 1;
  int newArrivalsPage = 1;
  int hotSellingPage = 1;
  int popularCategoriesPage = 1;
  int supplierLogosPage = 1;
  int recentlyAddedPage = 1;
  int popularAdsPage = 1;


  // Getters
  bool get isLoading => _isLoading;
  String? get errorMsg => _errorMsg;
  
  ProfileResponse? get profileResponse => _profileResponse;
  BannersResponse? get bannersResponse => _bannersResponse;
  FooterBannersResponse? get footerBannersResponse => _footerBannersResponse;
  HomeBlocksResponse? get homeBlocksResponse => _homeBlocksResponse;

  PromotionsResponse? get promotionsResponse => _promotionsResponse;
  DashboardProductsResponse? get bestSellersResponse => _bestSellersResponse;
  FlashDealsResponse? get flashDealsResponse => _flashDealsResponse;
  DashboardProductsResponse? get newArrivalsResponse => _newArrivalsResponse;
  DashboardProductsResponse? get hotSellingResponse => _hotSellingResponse;
  PopularCategoriesResponse? get popularCategoriesResponse => _popularCategoriesResponse;
  SupplierLogosResponse? get supplierLogosResponse => _supplierLogosResponse;
  DashboardProductsResponse? get recentlyAddedResponse => _recentlyAddedResponse;
  PopularAdvertosementsResponse? get popularAdvertisementsResponse => _popularAdvertisementsResponse;
  String? get companyImage => _companyImage;
  String? get supplierLogosPosition => _profileResponse?.results?[0]?.supplierLogosPosition;

  // Wishlist Getters
  List<WishlistCategory?>? get wishlistCategories => _wishlistCategoriesResponse?.results;
  bool get isFetchingWishlistCategories => _isFetchingWishlistCategories;

  DashboardProvider(this._dataSource);

  void init() {
    _isLoading = true;
    _errorMsg = null;
    notifyListeners();

    // Android Logic: Profile Call FIRST
    _loadCompanyConfig();
    _fetchProfile();
  }

  Future<void> _fetchDashboardContent(ProfileResult profile) async {
      // Logic from Android DashboardActivity/ViewModel:
      // Always call: Banners, Footer Banners, Home Blocks, Promotions
      
      final futures = <Future>[];
      
      futures.add(_fetchBanners());
      futures.add(_fetchFooterBanners());
      futures.add(_fetchHomeBlocks());
      futures.add(_fetchPromotions());
      
      // Conditional Calls based on Profile settings
      if (profile.bestSellers == "Show") futures.add(_fetchBestSellers());
      
      if (profile.productsAdvertisements == "Show") futures.add(_fetchPopularAdvertisements());
      
      if (profile.hotSelling == "Show") futures.add(_fetchHotSelling());
      
      if (profile.supplierLogos == "Show") futures.add(_fetchSupplierLogos());
      
      if (profile.popularCategories == "Show") futures.add(_fetchPopularCategories());
      
      if (profile.flashDeals == "Show") futures.add(_fetchFlashDeals());
      
      if (profile.newArrivals == "Show") futures.add(_fetchNewArrivals());
      
      if (profile.recentlyAdded == "Show") futures.add(_fetchRecentlyAdded());

      await Future.wait(futures);
      
      _isLoading = false;
      notifyListeners();
  }


  Future<void> _loadCompanyConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _companyImage = prefs.getString(StorageKeys.companyImage);
      
      // Update Global URLs from Preferences (Android Parity)
      final companyUrl = prefs.getString(StorageKeys.companyUrl);
      if (companyUrl != null && companyUrl.isNotEmpty) {
          // Android: UrlApiKey.MAIN_URL = prefs.CompanyUrl + "/"
          UrlApiKey.mainUrl = "$companyUrl/"; 
          UrlApiKey.companyMainUrl = "$companyUrl/";
          
          // Android: UrlApiKey.BASE_URL = prefs.CompanyUrl + "/api/"
          UrlApiKey.baseUrl = "$companyUrl/api/";
          
          debugPrint("Updated UrlApiKey.mainUrl to: ${UrlApiKey.mainUrl}");
      }
    } catch (e) {
       debugPrint("Error loading company config: $e");
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? ''; 
      
      final response = await _dataSource.getProfile(accessToken, customerId);
      _profileResponse = ProfileResponse.fromJson(response);
      
      if (_profileResponse?.results != null && _profileResponse!.results!.isNotEmpty) {
          await _fetchDashboardContent(_profileResponse!.results![0]!);
      } else {
          _isLoading = false;
          notifyListeners();
      }
      
    } catch (e) {
      debugPrint("Error fetching profile: $e");
      _isLoading = false;
      // errorMsg = e.toString(); // Android doesn't show blocking error for dashboard components, just logs/toasts
      notifyListeners();
    }
  }

  Future<void> _fetchBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final response = await _dataSource.getBanners(accessToken);
      _bannersResponse = BannersResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching banners: $e");
    }
  }
   Future<void> _fetchFooterBanners() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final response = await _dataSource.getFooterBanners(accessToken);
      _footerBannersResponse = FooterBannersResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching footer banners: $e");
    }
  }

  Future<void> _fetchHomeBlocks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final response = await _dataSource.getHomePageBlocks(accessToken);
      _homeBlocksResponse = HomeBlocksResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching home blocks: $e");
    }
  }

   Future<void> _fetchPromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getPromotions(accessToken, customerId, promotionPage);
      _promotionsResponse = PromotionsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching promotions: $e");
    }
  }

  Future<void> _fetchBestSellers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getBestSellers(accessToken, customerId, bestSellersPage);
      _bestSellersResponse = DashboardProductsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching best sellers: $e");
    }
  }
  
  Future<void> _fetchFlashDeals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getFlashDeals(accessToken, customerId, flashDealsPage);
      _flashDealsResponse = FlashDealsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching flash deals: $e");
    }
  }
  
  Future<void> _fetchNewArrivals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getNewArrivals(accessToken, customerId, newArrivalsPage);
      _newArrivalsResponse = DashboardProductsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching new arrivals: $e");
    }
  }

  Future<void> _fetchHotSelling() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getHotSelling(accessToken, customerId, hotSellingPage);
      _hotSellingResponse = DashboardProductsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching hot selling: $e");
    }
  }
  
  Future<void> _fetchPopularCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getPopularCategories(accessToken, customerId, popularCategoriesPage);
      _popularCategoriesResponse = PopularCategoriesResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching popular categories: $e");
    }
  }
  
  Future<void> _fetchSupplierLogos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final response = await _dataSource.getSupplierLogos(accessToken, supplierLogosPage);
      _supplierLogosResponse = SupplierLogosResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching supplier logos: $e");
    }
  }
  
  Future<void> _fetchRecentlyAdded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';
      final response = await _dataSource.getRecentlyAdded(accessToken, customerId, recentlyAddedPage);
      _recentlyAddedResponse = DashboardProductsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching recently added: $e");
    }
  }

  Future<void> _fetchPopularAdvertisements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final response = await _dataSource.getPopularAdvertisements(accessToken, popularAdsPage);
      _popularAdvertisementsResponse = PopularAdvertosementsResponse.fromJson(response);
    } catch (e) {
       debugPrint("Error fetching popular advertisements: $e");
    }
  }

  // Wishlist Methods
  Future<void> fetchWishlistCategories(String productId) async {
    _isFetchingWishlistCategories = true;
    _wishlistCategoriesResponse = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';

      final response = await _dataSource.getWishlistCategories(accessToken, customerId, productId);
      _wishlistCategoriesResponse = WishlistCategoriesResponse.fromJson(response);
    } catch (e) {
      debugPrint("Error fetching wishlist categories: $e");
      _errorMsg = "Failed to load wishlist categories";
    } finally {
      _isFetchingWishlistCategories = false;
      notifyListeners();
    }
  }

  void toggleWishlistCategory(String? categoryId) {
    if (_wishlistCategoriesResponse?.results == null) return;
    
    for (var category in _wishlistCategoriesResponse!.results!) {
      if (category == null) continue;
      if (category.categoryId == categoryId) {
        category.isSelected = !category.isSelected;
        break;
      }
    }
    notifyListeners();
  }

  Future<bool> submitWishlistUpdate(String productId, String newCategoryName) async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
      final customerId = prefs.getString(StorageKeys.userId) ?? '';

      // Collect selected category IDs
      String categoryIds = "";
      if (_wishlistCategoriesResponse?.results != null) {
        final selectedIds = _wishlistCategoriesResponse!.results!
            .where((c) => c?.isSelected == true)
            .map((c) => c?.categoryId)
            .whereType<String>();
        
        if (selectedIds.isNotEmpty) {
          categoryIds = selectedIds.join(',');
        }
      }

      final response = await _dataSource.addToWishlist(
        accessToken: accessToken,
        customerId: customerId,
        productId: productId,
        categoryName: newCategoryName,
        categoryIds: categoryIds,
      );

      final addResponse = AddToWishlistResponse.fromJson(response);
      if (addResponse.status == 200) {
        // Update local favorite state (simplified: if any selected or new name provided)
        final isFav = categoryIds.isNotEmpty || newCategoryName.isNotEmpty;
        _updateProductFavoriteState(productId, isFav ? "Yes" : "No");
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMsg = addResponse.successMessage ?? "Failed to update wishlist";
      }
    } catch (e) {
      debugPrint("Error submitting wishlist update: $e");
      _errorMsg = "Failed to update wishlist";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  void _updateProductFavoriteState(String productId, String state) {
    // Update state in all loaded sections
    _bestSellersResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
    _hotSellingResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
    _newArrivalsResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
    _flashDealsResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
    _promotionsResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
    _recentlyAddedResponse?.results?.forEach((p) { if (p?.productId == productId) p?.isFavourite = state; });
  }

  // Cart Methods
  Future<bool> addToCart(String productId, String qty, String price, String orderedAs, String apiData, String brandId) async {
      _isLoading = true;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
        final customerId = prefs.getString(StorageKeys.userId) ?? '';

        final response = await _dataSource.addToCart(
            accessToken: accessToken,
            customerId: customerId,
            productId: productId,
            qty: qty,
            price: price,
            orderedAs: orderedAs,
            apiData: apiData
        );
        
        // Check "status" from response
        if (response['status'] == 200) {
             _updateProductCartState(productId, "Yes", qty);
             
             // Update Local Profile Suppliers State (Scenario requirement)
             // Update Local Profile Suppliers State (Scenario requirement)
             if (_profileResponse != null) {
                 List<String> currentSuppliers = _profileResponse!.suppliers?.split(',') ?? [];
                 if (currentSuppliers.length == 1 && currentSuppliers[0].isEmpty) currentSuppliers = [];
                 
                 if (!currentSuppliers.contains(brandId)) {
                     currentSuppliers.add(brandId);
                     _profileResponse!.suppliers = currentSuppliers.join(',');
                     int count = int.tryParse(_profileResponse!.suppliersCount ?? "0") ?? 0;
                     _profileResponse!.suppliersCount = (count + 1).toString();
                 }
             }

             _isLoading = false;
             notifyListeners();
             return true;
        } else {
             _errorMsg = response['message'] ?? "Failed to add to cart";
        }
      } catch (e) {
          debugPrint("Error adding to cart: $e");
          _errorMsg = "Failed to add to cart";
      }
      _isLoading = false;
      notifyListeners();
      return false;
  }

  Future<bool> updateCart(String productId, String qty, String brandId, String price, String orderedAs) async {
      _isLoading = true;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
        final customerId = prefs.getString(StorageKeys.userId) ?? '';

        final response = await _dataSource.updateCartItem(
            accessToken: accessToken,
            customerId: customerId,
            productId: productId,
            brandId: brandId,
            qty: qty,
            price: price,
            orderedAs: orderedAs
        );
        
        if (response['status'] == 200) {
             _updateProductCartState(productId, "Yes", qty);
             _isLoading = false;
             notifyListeners();
             return true;
        } else {
             _errorMsg = response['message'] ?? "Failed to update cart";
        }
      } catch (e) {
          debugPrint("Error updating cart: $e");
          _errorMsg = "Failed to update cart";
      }
      _isLoading = false;
      notifyListeners();
      return false;
  }

  Future<bool> deleteCart(String productId, String brandId) async {
       _isLoading = true;
      notifyListeners();
      try {
        final prefs = await SharedPreferences.getInstance();
        final accessToken = prefs.getString(StorageKeys.accessToken) ?? '';
        final customerId = prefs.getString(StorageKeys.userId) ?? '';

        final response = await _dataSource.deleteCartItem(
            accessToken: accessToken,
            customerId: customerId,
            productId: productId,
            brandId: brandId
        );
        
        if (response['status'] == 200) {
             _updateProductCartState(productId, "No", "0");
             _isLoading = false;
             notifyListeners();
             return true;
        } else {
             _errorMsg = response['message'] ?? "Failed to delete from cart";
        }
      } catch (e) {
          debugPrint("Error deleting from cart: $e");
          _errorMsg = "Failed to delete from cart";
      }
      _isLoading = false;
      notifyListeners();
      return false;
  }

  void _updateProductCartState(String productId, String addedToCart, String qty) {
     void update(ProductItem? p) {
         if (p?.productId == productId) {
             p?.addedToCart = addedToCart;
             p?.addedQty = qty;
         }
     }
     
    _bestSellersResponse?.results?.forEach(update);
    _hotSellingResponse?.results?.forEach(update);
    _newArrivalsResponse?.results?.forEach(update);
    _flashDealsResponse?.results?.forEach(update);
    _promotionsResponse?.results?.forEach(update);
    _recentlyAddedResponse?.results?.forEach(update);
  }
}
