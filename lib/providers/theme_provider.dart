import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

enum ThemeSource {
  app,
  custom,
  system,
}

enum AppThemeMode {
  light,
  dark,
  black,
  system,
  systemBlack,
}

enum ContrastLevel {
  standard,
  medium,
  high,
}

enum TypographyStyle {
  system,
  roboto,
  openSans,
  lato,
}

class ThemeProvider with ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';
  static const String _themeSourceKey = 'theme_source';
  static const String _customSeedKey = 'custom_seed_color';
  static const String _contrastLevelKey = 'contrast_level';
  static const String _typographyStyleKey = 'typography_style';

  static Color get _defaultSeedColor => MaterialTheme.lightScheme().primary;

  AppThemeMode _appThemeMode = AppThemeMode.system;
  ThemeSource _themeSource = ThemeSource.app;
  ContrastLevel _contrastLevel = ContrastLevel.standard;
  TypographyStyle _typographyStyle = TypographyStyle.system;
  Color _customSeedColor = MaterialTheme.lightScheme().primary;

  ColorScheme? _systemLightColorScheme;
  ColorScheme? _systemDarkColorScheme;

  MaterialTheme get _materialTheme => MaterialTheme(_getTextTheme());

  ThemeProvider() {
    _loadSettings();
    _loadSystemColors();
  }

  AppThemeMode get appThemeMode => _appThemeMode;
  ThemeSource get themeSource => _themeSource;
  ContrastLevel get contrastLevel => _contrastLevel;
  TypographyStyle get typographyStyle => _typographyStyle;
  Color get customSeedColor => _customSeedColor;
  bool get hasSystemColors =>
      _systemLightColorScheme != null && _systemDarkColorScheme != null;

  ThemeMode get themeMode {
    switch (_appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.black:
        return ThemeMode.dark;
      case AppThemeMode.system:
      case AppThemeMode.systemBlack:
        return ThemeMode.system;
    }
  }

  Color get currentSeedColor {
    switch (_themeSource) {
      case ThemeSource.app:
        return _defaultSeedColor;
      case ThemeSource.custom:
        return _customSeedColor;
      case ThemeSource.system:
        return _defaultSeedColor;
    }
  }

  ThemeData get lightTheme {
    print(
        "Generating light theme - Source: $_themeSource, Typography: $_typographyStyle");

    switch (_themeSource) {
      case ThemeSource.app:
        return _getAppTheme(Brightness.light);
      case ThemeSource.custom:
        final scheme = _applyContrast(ColorScheme.fromSeed(
          seedColor: _customSeedColor,
          brightness: Brightness.light,
        ));
        return _createTheme(scheme);
      case ThemeSource.system:
        final scheme = _applyContrast(
          _systemLightColorScheme ??
              ColorScheme.fromSeed(
                seedColor: _defaultSeedColor,
                brightness: Brightness.light,
              ),
        );
        return _createTheme(scheme);
    }
  }

  ThemeData get darkTheme {
    final isBlackMode = _appThemeMode == AppThemeMode.black ||
        _appThemeMode == AppThemeMode.systemBlack;

    switch (_themeSource) {
      case ThemeSource.app:
        final theme = _getAppTheme(Brightness.dark);
        return isBlackMode ? _applyBlackMode(theme) : theme;
      case ThemeSource.custom:
        final scheme = _applyContrast(ColorScheme.fromSeed(
          seedColor: _customSeedColor,
          brightness: Brightness.dark,
        ));
        final theme = _createTheme(scheme);
        return isBlackMode ? _applyBlackMode(theme) : theme;
      case ThemeSource.system:
        final scheme = _applyContrast(
          _systemDarkColorScheme ??
              ColorScheme.fromSeed(
                seedColor: _defaultSeedColor,
                brightness: Brightness.dark,
              ),
        );
        final theme = _createTheme(scheme);
        return isBlackMode ? _applyBlackMode(theme) : theme;
    }
  }

  ThemeData _getAppTheme(Brightness brightness) {
    switch (_contrastLevel) {
      case ContrastLevel.standard:
        return brightness == Brightness.light
            ? _materialTheme.light()
            : _materialTheme.dark();
      case ContrastLevel.medium:
        return brightness == Brightness.light
            ? _materialTheme.lightMediumContrast()
            : _materialTheme.darkMediumContrast();
      case ContrastLevel.high:
        return brightness == Brightness.light
            ? _materialTheme.lightHighContrast()
            : _materialTheme.darkHighContrast();
    }
  }

  ThemeData _createTheme(ColorScheme colorScheme) {
    final textTheme = _getTextTheme();
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: colorScheme.brightness,
      textTheme: textTheme.apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
      canvasColor: colorScheme.surface,
    );
  }

  ColorScheme _applyContrast(ColorScheme scheme) {
    switch (_contrastLevel) {
      case ContrastLevel.medium:
        return scheme.copyWith(
          surface: scheme.surface.withOpacity(0.94),
          onSurface: scheme.onSurface.withOpacity(0.94),
          surfaceVariant: scheme.surfaceVariant.withOpacity(0.92),
        );
      case ContrastLevel.high:
        return scheme.copyWith(
          surface: scheme.surface.withOpacity(1.0),
          onSurface: scheme.onSurface.withOpacity(1.0),
          surfaceVariant: scheme.surfaceVariant.withOpacity(1.0),
          primary: scheme.primary,
          onPrimary: scheme.onPrimary,
          background: scheme.background.withOpacity(1.0),
        );
      case ContrastLevel.standard:
      default:
        return scheme;
    }
  }

  ThemeData _applyBlackMode(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final blackColorScheme = colorScheme.copyWith(
      surface: Colors.black,
      onSurface: Colors.white,
      surfaceContainer: Colors.black,
      surfaceContainerLow: const Color(0xff0a0a0a),
      surfaceContainerHigh: const Color(0xff1a1a1a),
      surfaceContainerHighest: const Color(0xff2a2a2a),
      surfaceDim: Colors.black,
      surfaceBright: const Color(0xff1a1a1a),
    );

    final textTheme = _getTextTheme();
    return theme.copyWith(
      colorScheme: blackColorScheme,
      textTheme: textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      canvasColor: Colors.black,
    );
  }

  TextTheme _getTextTheme() {
    switch (_typographyStyle) {
      case TypographyStyle.system:
        return Typography.material2021().black;
      case TypographyStyle.roboto:
        return GoogleFonts.robotoTextTheme();
      case TypographyStyle.openSans:
        return GoogleFonts.openSansTextTheme();
      case TypographyStyle.lato:
        return GoogleFonts.latoTextTheme();
    }
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    _appThemeMode = mode;
    await prefs.setString(_themeModeKey, mode.name);
    notifyListeners();
  }

  Future<void> setThemeSource(ThemeSource source) async {
    final prefs = await SharedPreferences.getInstance();
    _themeSource = source;
    await prefs.setString(_themeSourceKey, source.name);

    if (source == ThemeSource.system && !hasSystemColors) {
      _themeSource = ThemeSource.app;
      await prefs.setString(_themeSourceKey, ThemeSource.app.name);
    }

    notifyListeners();
  }

  Future<void> setContrastLevel(ContrastLevel level) async {
    final prefs = await SharedPreferences.getInstance();
    _contrastLevel = level;
    await prefs.setString(_contrastLevelKey, level.name);
    notifyListeners();
  }

  Future<void> setTypographyStyle(TypographyStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    _typographyStyle = style;
    await prefs.setString(_typographyStyleKey, style.name);
    notifyListeners();
  }

  Future<void> setCustomSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    _customSeedColor = color;
    await prefs.setInt(_customSeedKey, color.toARGB32());

    if (_themeSource != ThemeSource.custom) {
      _themeSource = ThemeSource.custom;
      await prefs.setString(_themeSourceKey, ThemeSource.custom.name);
    }

    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _appThemeMode = AppThemeMode.values.firstWhere(
      (e) => e.name == prefs.getString(_themeModeKey),
      orElse: () => AppThemeMode.system,
    );

    _themeSource = ThemeSource.values.firstWhere(
      (e) => e.name == prefs.getString(_themeSourceKey),
      orElse: () => ThemeSource.app,
    );

    _contrastLevel = ContrastLevel.values.firstWhere(
      (e) => e.name == prefs.getString(_contrastLevelKey),
      orElse: () => ContrastLevel.standard,
    );

    _typographyStyle = TypographyStyle.values.firstWhere(
      (e) => e.name == prefs.getString(_typographyStyleKey),
      orElse: () => TypographyStyle.system,
    );

    final customSeed = prefs.getInt(_customSeedKey);
    if (customSeed != null) {
      _customSeedColor = Color(customSeed);
    }

    notifyListeners();
  }

  Future<void> _loadSystemColors() async {
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        _systemLightColorScheme =
            corePalette.toColorScheme(brightness: Brightness.light);
        _systemDarkColorScheme =
            corePalette.toColorScheme(brightness: Brightness.dark);
        notifyListeners();
      }
    } catch (e) {
      _systemLightColorScheme = null;
      _systemDarkColorScheme = null;
    }
  }

  Future<void> toggleTheme() async {
    switch (_appThemeMode) {
      case AppThemeMode.system:
        await setAppThemeMode(AppThemeMode.light);
        break;
      case AppThemeMode.light:
        await setAppThemeMode(AppThemeMode.dark);
        break;
      case AppThemeMode.dark:
      case AppThemeMode.black:
      case AppThemeMode.systemBlack:
        await setAppThemeMode(AppThemeMode.system);
        break;
    }
  }

  Color get seedColor => currentSeedColor;

  Future<void> updateSeedColor(Color color) async {
    await setCustomSeedColor(color);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    switch (mode) {
      case ThemeMode.light:
        await setAppThemeMode(AppThemeMode.light);
        break;
      case ThemeMode.dark:
        await setAppThemeMode(AppThemeMode.dark);
        break;
      case ThemeMode.system:
        await setAppThemeMode(AppThemeMode.system);
        break;
    }
  }
}
