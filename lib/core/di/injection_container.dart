import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/api/api_client.dart';
import '/core/config/app_config.dart';
import '/core/storage/hive_storage.dart';
import '/data/datasources/local/weather_local_data_source.dart';
import '/data/datasources/remote/weather_remote_data_source.dart';
import '/data/repositories/weather_repository_impl.dart';
import '/domain/repositories/weather_repository.dart';
import '/domain/usecases/get_current_weather.dart';
import '/domain/usecases/get_forecast.dart';
import '/presentation/blocs/current_weather/current_weather_cubit.dart';
import '/presentation/blocs/forecast/forecast_cubit.dart';
import '/presentation/blocs/theme/theme_cubit.dart';
import '../../presentation/blocs/settings/settings_cubit.dart';

// Service locator
final sl = GetIt.instance;

Future<void> init() async {
  // App config
  sl.registerLazySingleton<AppConfig>(() => AppConfig.development());

  // External
  final dio = Dio();
  sl.registerLazySingleton<Dio>(() => dio);
  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Storage
  final storage = HiveStorageImpl();
  await storage.init();
  sl.registerLazySingleton<HiveStorage>(() => storage);

  // Api client
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl(), appConfig: sl()),
  );

  // Data sources
  sl.registerLazySingleton<WeatherRemoteDataSource>(
    () => WeatherRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<WeatherLocalDataSource>(
    () => WeatherLocalDataSourceImpl(storage: sl()),
  );

  // Repositories
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      connectivity: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentWeather(sl()));
  sl.registerLazySingleton(() => GetForecast(sl()));

  // Cubits
  sl.registerFactory(() => CurrentWeatherCubit(getCurrentWeather: sl()));
  sl.registerFactory(() => ForecastCubit(getForecast: sl()));
  sl.registerLazySingleton(() => ThemeCubit(prefs: sl()));
  sl.registerLazySingleton(() => SettingsCubit(prefs: sl()));
}
