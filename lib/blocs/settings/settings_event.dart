import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();
  @override
  List<Object?> get props => [];
}

class SettingsFontSizeChanged extends SettingsEvent {
  final double fontSize;
  const SettingsFontSizeChanged(this.fontSize);
  @override
  List<Object?> get props => [fontSize];
}

class SettingsTextColorChanged extends SettingsEvent {
  final Color color;
  const SettingsTextColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsBgColorChanged extends SettingsEvent {
  final Color color;
  const SettingsBgColorChanged(this.color);
  @override
  List<Object?> get props => [color];
}

class SettingsRepeatChorusChanged extends SettingsEvent {
  final bool value;
  const SettingsRepeatChorusChanged(this.value);
  @override
  List<Object?> get props => [value];
}

class SettingsBibleVersionChanged extends SettingsEvent {
  final String version;
  const SettingsBibleVersionChanged(this.version);
  @override
  List<Object?> get props => [version];
}

class SettingsReset extends SettingsEvent {
  const SettingsReset();
}
