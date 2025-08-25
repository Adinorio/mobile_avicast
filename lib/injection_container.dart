import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:network_info_plus/network_info_plus.dart' as network_info_plus;
import 'package:http/http.dart' as http;

// Core
import 'core/network/network_info.dart';
import 'core/services/user_context_service.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source_impl.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/sign_in.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Features - Sites
import 'features/sites/data/services/sites_database_service.dart';

// Core - Database
import 'core/database/database_service.dart';
import 'core/database/web_storage_service.dart';
import 'core/database/repositories/sites_repository.dart';
import 'core/database/repositories/bird_counts_repository.dart';
import 'core/database/migration_service.dart';

// Features - Notes
import 'features/notes/data/repositories/notes_repository_impl.dart';
import 'features/notes/data/services/notes_local_storage_service.dart';
import 'features/notes/presentation/bloc/notes_bloc.dart';

// Features - Camera
import 'features/notes/data/services/camera_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Notes
  // Bloc
  sl.registerFactory(
    () => NotesBloc(sl()),
  );

  // Repository
  sl.registerLazySingleton(
    () => NotesRepositoryImpl(sl()),
  );

  // Services
  sl.registerLazySingleton(() => NotesLocalStorageService.instance);

  //! Features - Sites
  // Services
  sl.registerLazySingleton(() => SitesDatabaseService.instance);
  
  //! Core - Database
  // Database service
  sl.registerLazySingleton(() => DatabaseService.instance);
  
  // Web storage service
  sl.registerLazySingleton(() => WebStorageService.instance);
  
  // Repositories
  sl.registerLazySingleton(() => SitesRepository());
  sl.registerLazySingleton(() => BirdCountsRepository());
  
  // Migration service
  sl.registerLazySingleton(() => MigrationService());

  //! Features - Camera
  // Services
  sl.registerLazySingleton(() => CameraService());

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(
    connectivity: sl(),
    networkInfo: sl(),
  ));

  //! Services
  sl.registerLazySingleton(() => UserContextService.instance);

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());
  sl.registerLazySingleton(() => network_info_plus.NetworkInfo());
} 