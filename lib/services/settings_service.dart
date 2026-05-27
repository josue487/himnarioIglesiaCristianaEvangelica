import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../blocs/settings/settings_state.dart';

class SettingsService {
  static const _fontSizeKey = 'settings_font_size';
  static const _textColorKey = 'settings_text_color';
  static const _bgColorKey = 'settings_bg_color';

  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsState(
      fontSize: prefs.getDouble(_fontSizeKey) ?? SettingsState.defaultFontSize,
      textColor: Color(
        prefs.getInt(_textColorKey) ?? SettingsState.defaultTextColorValue,
      ),
      backgroundColor: Color(
        prefs.getInt(_bgColorKey) ?? SettingsState.defaultBgColorValue,
      ),
    );
  }

  Future<void> save(SettingsState s) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setDouble(_fontSizeKey, s.fontSize),
      prefs.setInt(_textColorKey, s.textColor.toARGB32()),
      prefs.setInt(_bgColorKey, s.backgroundColor.toARGB32()),
    ]);
  }
}
