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
}
