import 'package:assessmentfounder/presentation/blocs/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '/core/di/injection_container.dart' as di;
import '/core/navigation/router.dart';
import '/core/theme/app_theme.dart';
import '/domain/repositories/weather_repository.dart';
import '/presentation/blocs/current_weather/current_weather_cubit.dart';
import '/presentation/blocs/forecast/forecast_cubit.dart';
import '/presentation/blocs/theme/theme_cubit.dart';
import '/presentation/blocs/theme/theme_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Initialization of dependencies
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<void> _requestLocationPermission() async {
    await Geolocator.requestPermission();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestLocationPermission();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrentWeatherCubit>(
          create: (context) => di.sl<CurrentWeatherCubit>(),
        ),
        BlocProvider<ForecastCubit>(
          create: (context) => di.sl<ForecastCubit>(),
        ),
        BlocProvider<ThemeCubit>(create: (context) => di.sl<ThemeCubit>()),
        BlocProvider<SettingsCubit>(
          create: (context) => di.sl<SettingsCubit>(),
        ),
      ],
      child: RepositoryProvider<WeatherRepository>(
        create: (context) => di.sl<WeatherRepository>(),
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return MaterialApp.router(
              title: 'Weather App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeState.themeMode,
              routerConfig: AppRouter.router,
            );
          },
        ),
      ),
    );
  }
}
