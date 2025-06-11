import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;
  final Color seedColor;

  const MaterialTheme(this.textTheme, this.seedColor);

  ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light);
    return _theme(scheme);
  }

  ThemeData dark() {
    final scheme =
        ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.dark);
    return _theme(scheme);
  }

  ThemeData _theme(ColorScheme scheme) => ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        brightness: scheme.brightness,
        textTheme: textTheme.apply(
          bodyColor: scheme.onSurface,
          displayColor: scheme.onSurface,
        ),
        scaffoldBackgroundColor: scheme.surface,
        canvasColor: scheme.surface,
      );
}
