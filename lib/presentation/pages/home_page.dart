import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/theme/app_colors.dart';
import '/core/theme/app_text_styles.dart';
import '/presentation/blocs/current_weather/current_weather_cubit.dart';
import '/presentation/blocs/current_weather/current_weather_state.dart';
import '/presentation/blocs/forecast/forecast_cubit.dart';
import '/presentation/blocs/forecast/forecast_state.dart';
import '/presentation/widgets/current_weather_card.dart';
import '/presentation/widgets/forecast_card.dart';
import '/presentation/widgets/responsive_builder.dart';
import '../../core/utils/location_permission_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;

  void _onLocationButtonPressed() async {
    final hasPermission =
        await LocationPermissionHelper.checkAndRequestLocationPermission(
          context,
        );

    if (hasPermission && mounted) {
      context.read<CurrentWeatherCubit>().fetchWeatherByCurrentLocation();
      context.read<ForecastCubit>().fetchForecastByCurrentLocation();
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    _loadWeatherData();
    _loadForecastData();
  }

  void _loadWeatherData() {
    context.read<CurrentWeatherCubit>().fetchWeatherByDefault();
  }

  void _loadForecastData() {
    context.read<ForecastCubit>().fetchForecastByDefault();
  }

  void _refreshData() {
    context.read<CurrentWeatherCubit>().refreshWeather();
    context.read<ForecastCubit>().refreshForecast();
  }

  void _navigateToSearch() {
    context.pushNamed('search');
  }

  void _navigateToSettings() {
    context.pushNamed('settings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
        },
        child: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(child: _buildCurrentWeatherSection()),
        SliverToBoxAdapter(child: _buildHourlyForecastSection()),
        SliverToBoxAdapter(child: _buildDailyForecastSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildCurrentWeatherSection()),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      _buildHourlyForecastSection(),
                      _buildDailyForecastSection(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Weather App',
                    style: AppTextStyles.headlineLarge,
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  selected: true,
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text('Search'),
                  onTap: _navigateToSearch,
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: _navigateToSettings,
                ),
                const Spacer(),
                const Divider(),
                ListTile(
                  title: const Text('Refresh Data'),
                  leading: const Icon(Icons.refresh),
                  onTap: _refreshData,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverAppBar(
                title: const Text('Weather Dashboard'),
                floating: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _navigateToSearch,
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: _navigateToSettings,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 2, child: _buildCurrentWeatherSection()),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            _buildHourlyForecastSection(),
                            _buildDailyForecastSection(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      floating: true,
      pinned: false,
      title: const Text('Weather App')
          .animate()
          .fadeIn(duration: 600.ms)
          .slideX(
            begin: -0.2,
            end: 0,
            duration: 600.ms,
            curve: Curves.easeOutQuad,
          ),
      actions: [
        IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: _onLocationButtonPressed,
            )
            .animate()
            .fadeIn(delay: 200.ms, duration: 400.ms)
            .rotate(begin: -0.2, end: 0, duration: 400.ms),
        IconButton(icon: const Icon(Icons.search), onPressed: _navigateToSearch)
            .animate()
            .fadeIn(delay: 300.ms, duration: 400.ms)
            .scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 400.ms,
            ),
        IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigateToSettings,
            )
            .animate()
            .fadeIn(delay: 400.ms, duration: 400.ms)
            .slideX(begin: 0.2, end: 0, duration: 400.ms),
      ],
    );
  }

  Widget _buildCurrentWeatherSection() {
    return BlocBuilder<CurrentWeatherCubit, CurrentWeatherState>(
      builder: (context, state) {
        if (state.isInitial) {
          return const _LoadingWeatherCard();
        } else if (state.isLoading && !state.isRefreshing) {
          return const _LoadingWeatherCard();
        } else if (state.isSuccess) {
          return CurrentWeatherCard(
            weather: state.weather!,
            isLoading: state.isRefreshing,
            onRefresh: _refreshData,
          );
        } else if (state.isFailure) {
          return _ErrorCard(
            message: state.errorMessage ?? 'Failed to load weather data',
            onRetry: _loadWeatherData,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildHourlyForecastSection() {
    return BlocBuilder<ForecastCubit, ForecastState>(
      builder: (context, state) {
        if (state.isInitial) {
          return const _LoadingForecastCard();
        } else if (state.isLoading && !state.isRefreshing) {
          return const _LoadingForecastCard();
        } else if (state.isSuccess) {
          return HourlyForecastCard(forecast: state.forecast!);
        } else if (state.isFailure) {
          return _ErrorCard(
            message: state.errorMessage ?? 'Failed to load forecast data',
            onRetry: _loadForecastData,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildDailyForecastSection() {
    return BlocBuilder<ForecastCubit, ForecastState>(
      builder: (context, state) {
        if (state.isInitial) {
          return const _LoadingForecastCard();
        } else if (state.isLoading && !state.isRefreshing) {
          return const _LoadingForecastCard();
        } else if (state.isSuccess) {
          return ForecastCard(forecast: state.forecast!);
        } else if (state.isFailure) {
          return _ErrorCard(
            message: state.errorMessage ?? 'Failed to load forecast data',
            onRetry: _loadForecastData,
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}

class _LoadingWeatherCard extends StatefulWidget {
  const _LoadingWeatherCard();

  @override
  State<_LoadingWeatherCard> createState() => _LoadingWeatherCardState();
}

class _LoadingWeatherCardState extends State<_LoadingWeatherCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        height: 400,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: child,
                  );
                },
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                    'Loading weather data...',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                    ),
                  )
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fadeIn(duration: 500.ms)
                  .then(delay: 500.ms)
                  .fadeOut(duration: 500.ms),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.5),
                        size: 30,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveX(
                        begin: -10,
                        end: 10,
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveX(
                        begin: 10,
                        end: -10,
                        duration: 2.seconds,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 20),
                  Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.7),
                        size: 40,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveX(
                        begin: 10,
                        end: -10,
                        duration: 3.seconds,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveX(
                        begin: -10,
                        end: 10,
                        duration: 3.seconds,
                        curve: Curves.easeInOut,
                      ),
                  const SizedBox(width: 20),
                  Icon(
                        Icons.cloud,
                        color: Colors.white.withOpacity(0.5),
                        size: 30,
                      )
                      .animate(onPlay: (controller) => controller.repeat())
                      .moveX(
                        begin: -5,
                        end: 5,
                        duration: 2.5.seconds,
                        curve: Curves.easeInOut,
                      )
                      .then()
                      .moveX(
                        begin: 5,
                        end: -5,
                        duration: 2.5.seconds,
                        curve: Curves.easeInOut,
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().shimmer(duration: 1.seconds, curve: Curves.easeInOut);
  }
}

class _LoadingForecastCard extends StatefulWidget {
  const _LoadingForecastCard();

  @override
  State<_LoadingForecastCard> createState() => _LoadingForecastCardState();
}

class _LoadingForecastCardState extends State<_LoadingForecastCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                    minHeight: 6,
                  );
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(backgroundColor: Colors.grey[300], radius: 8)
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .fadeIn(duration: 500.ms)
                      .fadeOut(delay: 500.ms, duration: 500.ms),
                  const SizedBox(width: 8),
                  CircleAvatar(backgroundColor: Colors.grey[300], radius: 8)
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .fadeIn(delay: 200.ms, duration: 500.ms)
                      .fadeOut(delay: 700.ms, duration: 500.ms),
                  const SizedBox(width: 8),
                  CircleAvatar(backgroundColor: Colors.grey[300], radius: 8)
                      .animate(
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                      )
                      .fadeIn(delay: 400.ms, duration: 500.ms)
                      .fadeOut(delay: 900.ms, duration: 500.ms),
                ],
              ),
              const SizedBox(height: 20),
              Text('Loading forecast data...', style: AppTextStyles.bodyMedium)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .fadeIn(duration: 500.ms)
                  .scaleXY(begin: 0.95, end: 1.05, duration: 800.ms)
                  .fadeOut(delay: 800.ms, duration: 500.ms),
            ],
          ),
        ),
      ),
    ).animate().shimmer(duration: 1.seconds, curve: Curves.easeInOut);
  }
}

class _ErrorCard extends StatefulWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  State<_ErrorCard> createState() => _ErrorCardState();
}

class _ErrorCardState extends State<_ErrorCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: -5,
      end: 5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticIn));

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _controller.repeat(
          reverse: true,
          period: const Duration(milliseconds: 100),
        );

        _controller.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                _controller.reset();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
          elevation: 3,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ).animate().scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1.0, 1.0),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                      widget.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 200.ms)
                    .moveY(begin: 5, end: 0, curve: Curves.easeOut),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                      onPressed: () {
                        _controller.reset();
                        _controller.forward().then((_) => widget.onRetry());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .moveY(begin: 10, end: 0, curve: Curves.easeOutBack),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 500.ms,
          curve: Curves.easeOut,
        );
  }
}
