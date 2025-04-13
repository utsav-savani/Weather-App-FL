import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/theme/app_text_styles.dart';
import '/domain/repositories/weather_repository.dart';
import '/presentation/blocs/current_weather/current_weather_cubit.dart';
import '/presentation/blocs/forecast/forecast_cubit.dart';
import '/presentation/widgets/responsive_builder.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];
  bool _isLoading = false;
  bool _isSearching = false;
  Timer? _debounceTimer;

  // This list is for major cities for initial suggestions
  final List<String> _majorCities = [
    'London',
    'New York',
    'Tokyo',
    'Paris',
    'Sydney',
    'Berlin',
    'Moscow',
    'Rome',
    'Toronto',
    'Mumbai',
    'Singapore',
    'Cairo',
    'Madrid',
    'Amsterdam',
    'Dubai',
    'Bangkok',
    'Seoul',
    'Mexico City',
    'Stockholm',
    'Buenos Aires',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    setState(() {
      _isLoading = true;
    });

    final searches =
        await context.read<WeatherRepository>().getLastSearchedCities();

    setState(() {
      _recentSearches = searches;
      _isLoading = false;
    });
  }

  void _search(String query) {
    if (query.isEmpty) return;

    context.read<CurrentWeatherCubit>().fetchWeatherByCity(query);
    context.read<ForecastCubit>().fetchForecastByCity(query);

    context.pop();
  }

  void _clearRecentSearches() async {
    await context.read<WeatherRepository>().clearSearchHistory();
    _loadRecentSearches();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();

    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (query.length >= 2) {
        final matchingRecent =
            _recentSearches
                .where(
                  (city) => city.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

        final matchingCities =
            _majorCities
                .where(
                  (city) => city.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

        final localResults = [
          ...matchingRecent,
          ...matchingCities.where((city) => !matchingRecent.contains(city)),
        ];

        if (!localResults.contains(query) && query.length > 2) {
          localResults.insert(0, query);
        }

        setState(() {
          _searchSuggestions = localResults.take(10).toList();
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchSuggestions = [];
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
        actions: [
          if (_recentSearches.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearRecentSearches,
              tooltip: 'Clear history',
            ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(),
        tablet: _buildTabletLayout(),
        desktop: _buildDesktopLayout(),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSearchBar(),
        if (_isSearching)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: CircularProgressIndicator(),
          ),
        Expanded(
          child:
              _searchSuggestions.isNotEmpty
                  ? _buildSearchSuggestions()
                  : _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildRecentSearches(),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildSearchBar(),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child:
                _searchSuggestions.isNotEmpty
                    ? _buildSearchSuggestions()
                    : _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildRecentSearches(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            _buildSearchBar(),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            Expanded(
              child:
                  _searchSuggestions.isNotEmpty
                      ? _buildSearchSuggestions()
                      : _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildRecentSearches(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Search for a city...',
              prefixIcon: const Icon(Icons.search)
                  .animate(
                    onPlay: (controller) => controller.repeat(reverse: true),
                  )
                  .scaleXY(begin: 0.9, end: 1.1, duration: 1.seconds),
              suffixIcon:
                  _searchController.text.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchSuggestions = [];
                          });
                        },
                      ).animate().fadeIn(duration: 200.ms)
                      : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              fillColor: Theme.of(context).cardColor,
              filled: true,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: _search,
            textInputAction: TextInputAction.search,
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .moveY(begin: -20, end: 0, curve: Curves.easeOutQuad),
    );
  }

  Widget _buildSearchSuggestions() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _searchSuggestions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final city = _searchSuggestions[index];
        final isExact = city == _searchController.text;

        return ListTile(
              leading: Icon(
                isExact ? Icons.search : Icons.location_city,
                color: isExact ? Theme.of(context).primaryColor : null,
              ),
              title: Text(
                city,
                style:
                    isExact
                        ? TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        )
                        : null,
              ),
              subtitle: isExact ? const Text("Search for this city") : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getWeatherIconForCity(city),
                    size: 20,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () => _search(city),
              tileColor: Colors.transparent,
              hoverColor: Theme.of(context).primaryColor.withOpacity(0.05),
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 50).ms)
            .slideX(
              begin: -0.1,
              end: 0,
              duration: 300.ms,
              delay: (index * 50).ms,
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  Widget _buildRecentSearches() {
    if (_recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 64, color: Colors.grey)
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .rotate(
                  begin: -0.05,
                  end: 0.05,
                  duration: 2.seconds,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 16),
            Text(
              'No recent searches',
              style: AppTextStyles.headlineSmall.copyWith(color: Colors.grey),
            ).animate().fadeIn(duration: 600.ms).moveY(begin: 10, end: 0),
            const SizedBox(height: 8),
            Text(
                  'Search for a city to see the weather',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
                )
                .animate()
                .fadeIn(delay: 300.ms, duration: 600.ms)
                .moveY(begin: 10, end: 0),

            const SizedBox(height: 40),
            _buildAnimatedSuggestions(),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      itemCount: _recentSearches.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final city = _recentSearches[index];
        return ListTile(
              leading: const Icon(Icons.history),
              title: Text(city),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getWeatherIconForCity(city),
                    size: 20,
                    color: Theme.of(context).primaryColor.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onTap: () => _search(city),
              tileColor: Colors.transparent,
              hoverColor: Theme.of(context).primaryColor.withOpacity(0.05),
            )
            .animate()
            .fadeIn(duration: 300.ms, delay: (index * 100).ms)
            .slideX(
              begin: -0.1,
              end: 0,
              duration: 300.ms,
              delay: (index * 100).ms,
              curve: Curves.easeOutQuad,
            );
      },
    );
  }

  IconData _getWeatherIconForCity(String city) {
    final random = math.Random(city.hashCode);
    final icons = [
      Icons.wb_sunny_outlined,
      Icons.cloud_outlined,
      Icons.water_drop_outlined,
      Icons.thunderstorm_outlined,
      Icons.ac_unit_outlined,
      Icons.wb_cloudy_outlined,
    ];
    return icons[random.nextInt(icons.length)];
  }

  Widget _buildAnimatedSuggestions() {
    final suggestions = [
      'London',
      'New York',
      'Tokyo',
      'Paris',
      'Sydney',
      'Berlin',
      'Moscow',
      'Rome',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children:
          suggestions.asMap().entries.map((entry) {
            final index = entry.key;
            final city = entry.value;
            final random = math.Random(index);
            final delay = (random.nextDouble() * 500).toInt();

            return ActionChip(
                  avatar: Icon(
                    _getWeatherIconForCity(city),
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: Text(city),
                  backgroundColor: Theme.of(context).cardColor,
                  side: BorderSide(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                  onPressed: () => _search(city),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  delay: Duration(milliseconds: delay),
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                );
          }).toList(),
    );
  }
}
