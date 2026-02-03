import 'package:flutter/material.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/models/home_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/storage_keys.dart';

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

}
