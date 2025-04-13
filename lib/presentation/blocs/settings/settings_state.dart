import '../../../core/utils/constants.dart';

class SettingsState {
  final TemperatureUnit temperatureUnit;

  const SettingsState({this.temperatureUnit = TemperatureUnit.celsius});

  SettingsState copyWith({TemperatureUnit? temperatureUnit}) {
    return SettingsState(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
    );
  }
}
