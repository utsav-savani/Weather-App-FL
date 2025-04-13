import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '/core/theme/app_text_styles.dart';
import '/core/utils/constants.dart';
import '/presentation/blocs/settings/settings_cubit.dart';
import '/presentation/blocs/theme/theme_cubit.dart';
import '/presentation/widgets/responsive_builder.dart';
import '../blocs/settings/settings_state.dart';
import '../blocs/theme/theme_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TemperatureUnit _temperatureUnit = TemperatureUnit.celsius;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Weather App',
    packageName: 'com.assess.founder.assessmentfounder',
    version: '1.0.0',
    buildNumber: '1',
  );

  @override
  void initState() {
    super.initState();

    _loadPackageInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _temperatureUnit =
              context.read<SettingsCubit>().state.temperatureUnit;
        });
      }
    });
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void _toggleTheme() {
    context.read<ThemeCubit>().toggleTheme();

    final isDarkMode = context.read<ThemeCubit>().isDarkMode;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Theme changed to ${isDarkMode ? 'light' : 'dark'} mode'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setTemperatureUnit(TemperatureUnit unit) {
    context.read<SettingsCubit>().setTemperatureUnit(unit);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Temperature unit changed to ${unit == TemperatureUnit.celsius ? 'Celsius' : 'Fahrenheit'}',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openOpenWeatherMapWebsite() async {
    final Uri url = Uri.parse('https://openweathermap.org/');

    try {
      if (!await launchUrl(url)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not launch browser'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SettingsCubit, SettingsState>(
      listener: (context, state) {
        setState(() {
          _temperatureUnit = state.temperatureUnit;
        });
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ResponsiveLayout(
          mobile: _buildMobileLayout(),
          tablet: _buildTabletLayout(),
          desktop: _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAppearanceSection(),
        const SizedBox(height: 16),
        _buildUnitsSection(),
        const SizedBox(height: 16),
        _buildAboutSection(),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildAppearanceSection(),
        const SizedBox(height: 16),
        _buildUnitsSection(),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: _buildAboutSection())],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildAppearanceSection()),
                const SizedBox(width: 16),
                Expanded(child: _buildUnitsSection()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: _buildAboutSection())],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final isDarkMode = themeState.themeMode == ThemeMode.dark;

        return Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: AppTextStyles.headlineMedium)
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.1, end: 0, duration: 400.ms),
                    const SizedBox(height: 16),
                    SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text(
                            'Toggle between light and dark theme',
                          ),
                          value: isDarkMode,
                          onChanged: (value) => _toggleTheme(),
                          secondary: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                              )
                              .animate(
                                onPlay:
                                    (controller) =>
                                        controller.repeat(reverse: true),
                              )
                              .rotate(
                                begin: -0.05,
                                end: 0.05,
                                duration: 1.seconds,
                              ),
                        )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideX(begin: 0.1, end: 0, duration: 400.ms),

                    Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        transitionBuilder: (child, animation) {
                          return RotationTransition(
                            turns: animation,
                            child: ScaleTransition(
                              scale: animation,
                              child: FadeTransition(
                                opacity: animation,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child:
                            isDarkMode
                                ? const Icon(
                                  Icons.dark_mode,
                                  key: ValueKey('dark'),
                                  color: Colors.indigo,
                                  size: 64,
                                )
                                : const Icon(
                                  Icons.wb_sunny,
                                  key: ValueKey('light'),
                                  color: Colors.amber,
                                  size: 64,
                                ),
                      ),
                    ).animate().scale(
                      delay: 300.ms,
                      duration: 500.ms,
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      curve: Curves.elasticOut,
                    ),
                  ],
                ),
              ),
            )
            .animate()
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.1, end: 0, duration: 300.ms);
      },
    );
  }

  Widget _buildUnitsSection() {
    return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Units', style: AppTextStyles.headlineMedium)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 100.ms)
                    .slideX(begin: -0.1, end: 0, duration: 400.ms),
                const SizedBox(height: 16),

                _buildTemperatureUnitSelector(),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms);
  }

  Widget _buildTemperatureUnitSelector() {
    final theme = Theme.of(context);
    final radioColor =
        theme.brightness == Brightness.dark
            ? theme.colorScheme.primary
            : theme.primaryColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          RadioListTile<TemperatureUnit>(
                title: Row(
                  children: [
                    Text('Celsius (°C)', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    if (_temperatureUnit == TemperatureUnit.celsius)
                      Icon(Icons.check_circle, color: radioColor, size: 16)
                          .animate(
                            onPlay:
                                (controller) =>
                                    controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 800.ms,
                          ),
                  ],
                ),
                value: TemperatureUnit.celsius,
                groupValue: _temperatureUnit,
                onChanged:
                    (value) => _setTemperatureUnit(TemperatureUnit.celsius),
                activeColor: radioColor,
                selected: _temperatureUnit == TemperatureUnit.celsius,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                selectedTileColor: radioColor.withOpacity(0.1),
              )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms),

          const Divider(height: 1),

          RadioListTile<TemperatureUnit>(
                title: Row(
                  children: [
                    Text('Fahrenheit (°F)', style: theme.textTheme.bodyMedium),
                    const SizedBox(width: 8),
                    if (_temperatureUnit == TemperatureUnit.fahrenheit)
                      Icon(Icons.check_circle, color: radioColor, size: 16)
                          .animate(
                            onPlay:
                                (controller) =>
                                    controller.repeat(reverse: true),
                          )
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                            duration: 800.ms,
                          ),
                  ],
                ),
                value: TemperatureUnit.fahrenheit,
                groupValue: _temperatureUnit,
                onChanged:
                    (value) => _setTemperatureUnit(TemperatureUnit.fahrenheit),
                activeColor: radioColor,
                selected: _temperatureUnit == TemperatureUnit.fahrenheit,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                selectedTileColor: radioColor.withOpacity(0.1),
              )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('About', style: AppTextStyles.headlineMedium),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('App Version'),
              subtitle: Text(
                '${_packageInfo.version} (${_packageInfo.buildNumber})',
              ),
              leading: const Icon(Icons.info),
            ),
            ListTile(
              title: const Text('Data Source'),
              subtitle: const Text('OpenWeatherMap API'),
              leading: const Icon(Icons.cloud),
              onTap: _openOpenWeatherMapWebsite,
            ),
            const ListTile(
              title: Text('Developer'),
              subtitle: Text('Technical Assessment'),
              leading: Icon(Icons.person),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 300.ms);
  }
}
