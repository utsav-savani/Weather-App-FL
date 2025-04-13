import 'package:assessmentfounder/presentation/blocs/settings/settings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/core/utils/constants.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit({required this.prefs}) : super(const SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final savedUnitIndex = prefs.getInt(ApiConstants.temperatureUnitKey);
    if (savedUnitIndex != null) {
      final unit = TemperatureUnit.values[savedUnitIndex];
      emit(state.copyWith(temperatureUnit: unit));
    }
  }

  Future<void> setTemperatureUnit(TemperatureUnit unit) async {
    await prefs.setInt(ApiConstants.temperatureUnitKey, unit.index);
    emit(state.copyWith(temperatureUnit: unit));
  }
}
