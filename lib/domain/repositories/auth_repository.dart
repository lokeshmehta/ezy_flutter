
import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../entities/companies_response.dart';


abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
  });
  Future<Either<Failure, CompaniesResponse>> getCompanies();
}
