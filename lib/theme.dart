import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4b5c92),
      surfaceTint: Color(0xff4b5c92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffdbe1ff),
      onPrimaryContainer: Color(0xff324478),
      secondary: Color(0xff226a4c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffaaf2cc),
      onSecondaryContainer: Color(0xff005236),
      tertiary: Color(0xff67548e),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffeaddff),
      onTertiaryContainer: Color(0xff4f3d74),
      error: Color(0xff904a46),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad7),
      onErrorContainer: Color(0xff733330),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff171c1f),
      onSurfaceVariant: Color(0xff43474e),
      outline: Color(0xff74777f),
      outlineVariant: Color(0xffc4c6cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xffb4c5ff),
      primaryFixed: Color(0xffdbe1ff),
      onPrimaryFixed: Color(0xff00174b),
      primaryFixedDim: Color(0xffb4c5ff),
      onPrimaryFixedVariant: Color(0xff324478),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff002113),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff005236),
      tertiaryFixed: Color(0xffeaddff),
      onTertiaryFixed: Color(0xff220f46),
      tertiaryFixedDim: Color(0xffd2bcfd),
      onTertiaryFixedVariant: Color(0xff4f3d74),
      surfaceDim: Color(0xffd6dbde),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffeaeef2),
      surfaceContainerHigh: Color(0xffe4e9ec),
      surfaceContainerHighest: Color(0xffdfe3e7),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff213367),
      surfaceTint: Color(0xff4b5c92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff596ba2),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003f29),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff337a5a),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff3e2c62),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff76639e),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff5e2321),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffa15853),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff0d1215),
      onSurfaceVariant: Color(0xff33363d),
      outline: Color(0xff4f525a),
      outlineVariant: Color(0xff6a6d75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xffb4c5ff),
      primaryFixed: Color(0xff596ba2),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff415388),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff337a5a),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff156043),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff76639e),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff5d4b83),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc2c7cb),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff0f4f8),
      surfaceContainer: Color(0xffe4e9ec),
      surfaceContainerHigh: Color(0xffd9dde1),
      surfaceContainerHighest: Color(0xffced2d6),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff15295c),
      surfaceTint: Color(0xff4b5c92),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff35477b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff003421),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff005438),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff342158),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff513f77),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff511918),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff763632),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff6fafe),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff292c33),
      outlineVariant: Color(0xff464951),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xffb4c5ff),
      primaryFixed: Color(0xff35477b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff1d3063),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff005438),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff003b26),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff513f77),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff3a285f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb5b9bd),
      surfaceBright: Color(0xfff6fafe),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffedf1f5),
      surfaceContainer: Color(0xffdfe3e7),
      surfaceContainerHigh: Color(0xffd0d5d9),
      surfaceContainerHighest: Color(0xffc2c7cb),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffb4c5ff),
      surfaceTint: Color(0xffb4c5ff),
      onPrimary: Color(0xff1a2d60),
      primaryContainer: Color(0xff324478),
      onPrimaryContainer: Color(0xffdbe1ff),
      secondary: Color(0xff8ed5b0),
      onSecondary: Color(0xff003824),
      secondaryContainer: Color(0xff005236),
      onSecondaryContainer: Color(0xffaaf2cc),
      tertiary: Color(0xffd2bcfd),
      onTertiary: Color(0xff38265c),
      tertiaryContainer: Color(0xff4f3d74),
      onTertiaryContainer: Color(0xffeaddff),
      error: Color(0xffffb3ad),
      onError: Color(0xff571e1b),
      errorContainer: Color(0xff733330),
      onErrorContainer: Color(0xffffdad7),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffdfe3e7),
      onSurfaceVariant: Color(0xffc4c6cf),
      outline: Color(0xff8d9199),
      outlineVariant: Color(0xff43474e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff4b5c92),
      primaryFixed: Color(0xffdbe1ff),
      onPrimaryFixed: Color(0xff00174b),
      primaryFixedDim: Color(0xffb4c5ff),
      onPrimaryFixedVariant: Color(0xff324478),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff002113),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff005236),
      tertiaryFixed: Color(0xffeaddff),
      onTertiaryFixed: Color(0xff220f46),
      tertiaryFixedDim: Color(0xffd2bcfd),
      onTertiaryFixedVariant: Color(0xff4f3d74),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff353a3d),
      surfaceContainerLowest: Color(0xff0a0f12),
      surfaceContainerLow: Color(0xff171c1f),
      surfaceContainer: Color(0xff1b2023),
      surfaceContainerHigh: Color(0xff262b2e),
      surfaceContainerHighest: Color(0xff303538),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffd2dbff),
      surfaceTint: Color(0xffb4c5ff),
      onPrimary: Color(0xff0d2255),
      primaryContainer: Color(0xff7d8fc8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffa4ecc6),
      onSecondary: Color(0xff002c1c),
      secondaryContainer: Color(0xff599e7d),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffe5d5ff),
      onTertiary: Color(0xff2d1a51),
      tertiaryContainer: Color(0xff9b86c4),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2ce),
      onError: Color(0xff481312),
      errorContainer: Color(0xffcb7b75),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdadce5),
      outline: Color(0xffafb2bb),
      outlineVariant: Color(0xff8d9099),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff34467a),
      primaryFixed: Color(0xffdbe1ff),
      onPrimaryFixed: Color(0xff000e35),
      primaryFixedDim: Color(0xffb4c5ff),
      onPrimaryFixedVariant: Color(0xff213367),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff00150b),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff003f29),
      tertiaryFixed: Color(0xffeaddff),
      onTertiaryFixed: Color(0xff18023c),
      tertiaryFixedDim: Color(0xffd2bcfd),
      onTertiaryFixedVariant: Color(0xff3e2c62),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff404548),
      surfaceContainerLowest: Color(0xff04080a),
      surfaceContainerLow: Color(0xff191e21),
      surfaceContainer: Color(0xff24292b),
      surfaceContainerHigh: Color(0xff2e3336),
      surfaceContainerHighest: Color(0xff393e41),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffedefff),
      surfaceTint: Color(0xffb4c5ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffafc1fd),
      onPrimaryContainer: Color(0xff000928),
      secondary: Color(0xffbaffda),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xff8ad1ad),
      onSecondaryContainer: Color(0xff000e07),
      tertiary: Color(0xfff6ecff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffceb8f9),
      onTertiaryContainer: Color(0xff110031),
      error: Color(0xffffecea),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea8),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0f1417),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffedf0f9),
      outlineVariant: Color(0xffc0c2cb),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdfe3e7),
      inversePrimary: Color(0xff34467a),
      primaryFixed: Color(0xffdbe1ff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffb4c5ff),
      onPrimaryFixedVariant: Color(0xff000e35),
      secondaryFixed: Color(0xffaaf2cc),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xff8ed5b0),
      onSecondaryFixedVariant: Color(0xff00150b),
      tertiaryFixed: Color(0xffeaddff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffd2bcfd),
      onTertiaryFixedVariant: Color(0xff18023c),
      surfaceDim: Color(0xff0f1417),
      surfaceBright: Color(0xff4c5154),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1b2023),
      surfaceContainer: Color(0xff2c3134),
      surfaceContainerHigh: Color(0xff373c3f),
      surfaceContainerHighest: Color(0xff42474b),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
        useMaterial3: true,
        brightness: colorScheme.brightness,
        colorScheme: colorScheme,
        textTheme: textTheme.apply(
          bodyColor: colorScheme.onSurface,
          displayColor: colorScheme.onSurface,
        ),
        scaffoldBackgroundColor: colorScheme.surface,
        canvasColor: colorScheme.surface,
      );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
