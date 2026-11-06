import 'package:flutter_bloc/flutter_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';
import '../../services/settings_service.dart';

export 'settings_event.dart';
export 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsService _service;

  SettingsBloc(this._service, SettingsState initial) : super(initial) {
    on<SettingsFontSizeChanged>(_onFontSize);
    on<SettingsTextColorChanged>(_onTextColor);
    on<SettingsBgColorChanged>(_onBgColor);
    on<SettingsRepeatChorusChanged>(_onRepeatChorus);
    on<SettingsBibleVersionChanged>(_onBibleVersion);
    on<SettingsReset>(_onReset);
  }

  Future<void> _onFontSize(
    SettingsFontSizeChanged e,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(fontSize: e.fontSize);
    emit(next);
    await _service.save(next);
  }

  Future<void> _onTextColor(
    SettingsTextColorChanged e,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(textColor: e.color);
    emit(next);
    await _service.save(next);
  }

  Future<void> _onBgColor(
    SettingsBgColorChanged e,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(backgroundColor: e.color);
    emit(next);
    await _service.save(next);
  }

  Future<void> _onRepeatChorus(
    SettingsRepeatChorusChanged e,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(repeatChorus: e.value);
    emit(next);
    await _service.save(next);
  }

  Future<void> _onBibleVersion(
    SettingsBibleVersionChanged e,
    Emitter<SettingsState> emit,
  ) async {
    final next = state.copyWith(bibleVersion: e.version);
    emit(next);
    await _service.save(next);
  }

  Future<void> _onReset(
    SettingsReset e,
    Emitter<SettingsState> emit,
  ) async {
    final next = SettingsState(bibleVersion: state.bibleVersion);
    emit(next);
    await _service.save(next);
  }
}
