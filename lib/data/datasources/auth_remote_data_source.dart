import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/companies_response.dart';
import '../../core/constants/url_api_key.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource(this.apiClient);

  Future<UserEntity> login(String email, String password) async {
    // Note: Android uses FormUrlEncoded. http.post with map body does this by default.
    final response = await apiClient.post(
      UrlApiKey.baseUrl + ApiEndpoints.login,
      body: {
        'user_name': email,
        'password': password,
      },
    );
    
    // Assuming API returns JSON consistent with UserEntity.fromJson
    // If wrapped in "response" object, extract it here.
    return UserEntity.fromJson(response);
  }

  Future<UserEntity> signUp(
     String firstName,
     String lastName,
     String phone,
     String email,
     String password,
  ) async {
    final response = await apiClient.post(
      UrlApiKey.baseUrl + ApiEndpoints.signUp,
      body: {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
        'email': email,
        'password': password,
        // Add other fields as needed per Android implementation
      },
    );

    return UserEntity.fromJson(response);
  }

  Future<CompaniesResponse> getCompanies() async {
    // Companies List uses COMPANYMAIN_URL + "companies-list.php?" (Assuming endpoint is relative)
    // In Android: mainclient.create(BackEndApi::class.java).getCompaniesList()
    // mainclient uses UrlApiKey.COMPANYMAIN_URL
    final response = await apiClient.get(
      UrlApiKey.companyMainUrl + ApiEndpoints.companiesList,
    );
    return CompaniesResponse.fromJson(response);
  }
}
