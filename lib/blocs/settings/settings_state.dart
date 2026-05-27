import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsState extends Equatable {
  static const double minFontSize = 12.0;
  static const double maxFontSize = 36.0;
  static const double defaultFontSize = 16.0;
  static const int defaultTextColorValue = 0xFF424242;
  static const int defaultBgColorValue = 0xFFF8F9FA;

  final double fontSize;
  final Color textColor;
  final Color backgroundColor;

  const SettingsState({
    this.fontSize = defaultFontSize,
    this.textColor = const Color(defaultTextColorValue),
    this.backgroundColor = const Color(defaultBgColorValue),
  });

  SettingsState copyWith({
    double? fontSize,
    Color? textColor,
    Color? backgroundColor,
  }) =>
      SettingsState(
        fontSize: fontSize ?? this.fontSize,
        textColor: textColor ?? this.textColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
      );

  @override
  List<Object?> get props => [fontSize, textColor, backgroundColor];
}
