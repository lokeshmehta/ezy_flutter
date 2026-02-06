import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/companies_response.dart';
import '../../core/constants/url_api_key.dart';
import 'dart:io';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<UserEntity> login(String email, String password) async {
    // Note: Android uses FormUrlEncoded. http.post with map body does this by default.
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}${ApiEndpoints.login}",
      body: {
        'user_name': email,
        'password': password,
      },
    );
    
    // Assuming API returns JSON consistent with UserEntity.fromJson
    // If wrapped in "response" object, extract it here.
    return UserEntity.fromJson(response);
  }

  Future<UserEntity> signUp({
     required String firstName,
     required String lastName,
     required String phone,
     required String email,
     required String password,
     required String receiptEmails,
     required String title,
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}${ApiEndpoints.signUp}",
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        'receiptemails': receiptEmails,
        'title': title,
        'source': 'Android',
        'devicetype': Platform.operatingSystem, // Requires import 'dart:io'
        'token': '',
        'device_id': '',
      },
    );

    // API returns standard JSON, assuming UserEntity structure or similar success response.
    // However, SignUpViewModel expects JSONObject with 'status', 'message', 'error'.
    // UserEntity might not match exactly if it's just a status response.
    // But AuthRepository returns dynamic. 
    // Let's return the raw response (Map) so Provider can parse status/messages.
    return UserEntity.fromJson(response); 
  }

  Future<CompaniesResponse> getCompanies() async {
    // Companies List uses COMPANYMAIN_URL + "companies-list.php?" (Assuming endpoint is relative)
    // In Android: mainclient.create(BackEndApi::class.java).getCompaniesList()
    // mainclient uses UrlApiKey.COMPANYMAIN_URL
    final response = await apiClient.get(
      "${UrlApiKey.companyMainUrl}${ApiEndpoints.companiesList}",
    );
    return CompaniesResponse.fromJson(response);
  }


  Future<dynamic> forgotPassword(String email) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}forgot-password", 
      body: {
        'forgot_email': email,
      },
    );
    // Return raw response for provider to parse status
    return response;
  }

  // Dashboard APIs
  Future<Map<String, dynamic>> getProfile(String accessToken, String customerId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}get-profile",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getBanners(String accessToken) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}banners",
      body: {
        'access_token': accessToken,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getFooterBanners(String accessToken) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}footer-banners",
      body: {
        'access_token': accessToken,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getHomePageBlocks(String accessToken) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}home-page-blocks",
      body: {
        'access_token': accessToken,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getPromotions(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}promotions",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getBestSellers(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}best-sellers",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getFlashDeals(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}flash-deals",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getNewArrivals(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}new-arrivals",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getHotSelling(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}hot-selling",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getPopularCategories(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}popular-categories",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getSupplierLogos(String accessToken, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}supplier-logos",
      body: {
        'access_token': accessToken,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getRecentlyAdded(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}recently-added",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getPopularAdvertisements(String accessToken, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}product-advertisements",
      body: {
        'access_token': accessToken,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getWishlistCategories(String accessToken, String customerId, String productId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}wishlist-categories",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> addToWishlist({
    required String accessToken,
    required String customerId,
    required String productId,
    required String categoryName,
    required String categoryIds,
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}add-to-wishlist",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
        'category_name': categoryName,
        'category_ids': categoryIds,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> addToCart({
    required String accessToken,
    required String customerId,
    required String productId,
    required String qty,
    required String price,
    required String orderedAs,
    required String apiData,
    String accNum = "",
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}add-to-cart",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
        'qty': qty,
        'price': price,
        'ordered_as': orderedAs,
        'acc_num': accNum,
        'api_data': apiData,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> updateCartItem({
    required String accessToken,
    required String customerId,
    required String productId,
    required String brandId,
    required String qty,
    required String price,
    required String orderedAs,
    String accNum = "",
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}update-cart-item",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
        'brand_id': brandId,
        'qty': qty,
        'price': price,
        'ordered_as': orderedAs,
        'acc_num': accNum,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> deleteCartItem({
    required String accessToken,
    required String customerId,
    required String productId,
    required String brandId,
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}delete-cart-item",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
        'brand_id': brandId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> deleteFromWishlist({
    required String accessToken,
    required String customerId,
    required String wishlistId,
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}delete-from-wishlist",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'wishlist_id': wishlistId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getGlobalWishlistCategories(String accessToken, String customerId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}wishlist-categories",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
      },
    );
    return response;
  }

  // Drawer APIs
  Future<Map<String, dynamic>> getAboutUs(String accessToken) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}about-us",
      body: {
        'access_token': accessToken,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> sendFeedback({
    required String name,
    required String email,
    required String subject,
    required String message,
    required String phone,
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}contact-us",
      body: {
        'name': name,
        'email': email,
        'subject': subject,
        'message': message,
        'phone': phone,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getFAQCategories(String accessToken) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}faq-categories",
      body: {
        'access_token': accessToken,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getFAQDetails(String accessToken, String categoryId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}faq",
      body: {
        'access_token': accessToken,
        'category_id': categoryId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getNotifications(String accessToken, String customerId, int page) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}notifications",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'page': page.toString(),
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> changeNotificationStatus(String accessToken, String customerId, String notificationId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}change-notification-status",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'notification_id': notificationId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> deleteNotification(String accessToken, String customerId, String notificationId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}delete-notification",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'notification_id': notificationId,
      },
    );
    return response;
  }

  // Product List APIs
  Future<Map<String, dynamic>> getProducts({
    required String accessToken,
    required String customerId,
    String brandId = "",
    String divisionId = "",
    String groupId = "",
    String subGroupId = "",
    String subSubGroupId = "",
    required int page,
    String orderby = "",
    String tagId = "",
    String productsType = "",
    String searchText = "",
    String products = "",
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}products",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'brand_id': brandId,
        'division_id': divisionId,
        'group_id': groupId,
        'sub_group_id': subGroupId,
        'sub_sub_group_id': subSubGroupId,
        'page': page.toString(),
        'orderby': orderby,
        'tag_id': tagId,
        'products_type': productsType,
        'search_text': searchText,
        'products': products,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getAllFilterProducts({
    required String accessToken,
    required String customerId,
    String divisionId = "",
    String brandId = "",
    String selectedBrands = "",
    String groupId = "",
    String subGroupId = "",
    String subSubGroupId = "",
    String selectedProducts = "",
    String selectedDivisions = "",
    String selectedGroups = "",
    String selectedSubGroups = "",
    String selectedSubSubGroups = "",
    String productsType = "All Products",
  }) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}product-filters",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'division_id': divisionId,
        'brand_id': brandId,
        'selected_brands': selectedBrands,
        'group_id': groupId,
        'sub_group_id': subGroupId,
        'sub_sub_group_id': subSubGroupId,
        'selected_products': selectedProducts,
        'selected_divisions': selectedDivisions,
        'selected_groups': selectedGroups,
        'selected_sub_groups': selectedSubGroups,
        'selected_sub_sub_groups': selectedSubSubGroups,
        'products_type': productsType,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getProductSortOptions(String accessToken, String customerId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}product-sort-options",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
      },
    );
    return response;
  }

  Future<Map<String, dynamic>> getProductDetails(
      String accessToken, String customerId, String productId) async {
    final response = await apiClient.post(
      "${UrlApiKey.baseUrl}product-details",
      body: {
        'access_token': accessToken,
        'customer_id': customerId,
        'product_id': productId,
      },
    );
    return response;
  }
}
