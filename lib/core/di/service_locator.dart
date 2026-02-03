import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import '../../core/network/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../presentation/providers/auth_provider.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // External
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Core
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(client: getIt<http.Client>()));

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<ApiClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Providers (ChangeNotifiers)
  getIt.registerFactory(() => AuthProvider(getIt<AuthRepository>()));
}
