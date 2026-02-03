
import '../entities/user_entity.dart';
import '../entities/companies_response.dart';


abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<void> logout();
  Future<UserEntity> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  });
  Future<CompaniesResponse> getCompanies();
}
