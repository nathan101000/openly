import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/theme.dart';

class ThemeSettingsScreen extends StatelessWidget {
  const ThemeSettingsScreen({super.key});

  static List<Color> get _predefinedColors => [
    MaterialTheme.lightScheme().primary, // App default primary
    MaterialTheme.lightScheme().secondary, // App default secondary  
    MaterialTheme.lightScheme().tertiary, // App default tertiary
    const Color(0xff6b7c32), // Dark olive green
    const Color(0xff5a6b2d), // Darker green
    const Color(0xff2d5a4f), // Dark teal
    const Color(0xffa4c663), // Light green
    const Color(0xff8a8a8a), // Gray
    const Color(0xff63c4c6), // Light teal
    const Color(0xff4a4a4a), // Dark gray
    const Color(0xffe91e63), // Pink
    const Color(0xff9c27b0), // Purple
    const Color(0xff673ab7), // Deep purple
    const Color(0xff3f51b5), // Indigo
    const Color(0xff2196f3), // Blue
    const Color(0xff03a9f4), // Light blue
    const Color(0xff00bcd4), // Cyan
    const Color(0xff009688), // Teal
    const Color(0xff4caf50), // Green
    const Color(0xff8bc34a), // Light green
    const Color(0xffcddc39), // Lime
    const Color(0xffffeb3b), // Yellow
    const Color(0xffffc107), // Amber
    const Color(0xffff9800), // Orange
    const Color(0xffff5722), // Deep orange
    const Color(0xff795548), // Brown
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Theme, font and colors',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildSectionWithIcon(
                context,
                icon: Icons.dark_mode_outlined,
                title: 'Theme mode',
                child: _buildThemeModeChips(context, themeProvider),
              ),
              const SizedBox(height: 24),
              _buildSectionWithIcon(
                context,
                icon: Icons.palette_outlined,
                title: 'Default color source',
                child: _buildColorSourceChips(context, themeProvider),
              ),
              if (themeProvider.themeSource == ThemeSource.custom) ...[
                const SizedBox(height: 24),
                _buildSectionWithIcon(
                  context,
                  icon: Icons.edit,
                  title: 'Seed color',
                  child: _buildSeedColorPicker(context, themeProvider),
                ),
              ],
              const SizedBox(height: 24),
              _buildSectionWithIcon(
                context,
                icon: Icons.contrast,
                title: 'Contrast',
                child: _buildContrastChips(context, themeProvider),
              ),
              const SizedBox(height: 32),
              _buildSectionWithIcon(
                context,
                icon: null,
                title: 'Selected theme colors',
                child: _buildThemePreview(context, themeProvider),
              ),
              const SizedBox(height: 32),
              _buildSectionWithIcon(
                context,
                icon: Icons.text_fields_outlined,
                title: 'Typography',
                child: Text(
                  _getTypographyDisplayName(themeProvider.typographyStyle),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                onTap: () => _showTypographyDialog(context, themeProvider),
              ),
              const SizedBox(height: 28),
              _buildSectionWithIcon(
                context,
                icon: Icons.restore_outlined,
                title: 'Restore defaults',
                child: const SizedBox.shrink(),
                onTap: () => _showRestoreDefaultsDialog(context, themeProvider),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionWithIcon(
    BuildContext context, {
    required IconData? icon,
    required String title,
    required Widget child,
    VoidCallback? onTap,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 24,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        if (child is! SizedBox) ...[
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.only(left: 32),
            child: child,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildThemeModeChips(
      BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'System Light/Dark',
            icon: Icons.brightness_auto,
            isSelected: themeProvider.appThemeMode == AppThemeMode.system,
            onTap: () => themeProvider.setAppThemeMode(AppThemeMode.system),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Light',
            icon: Icons.light_mode,
            isSelected: themeProvider.appThemeMode == AppThemeMode.light,
            onTap: () => themeProvider.setAppThemeMode(AppThemeMode.light),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Dark',
            icon: Icons.dark_mode,
            isSelected: themeProvider.appThemeMode == AppThemeMode.dark,
            onTap: () => themeProvider.setAppThemeMode(AppThemeMode.dark),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Black',
            icon: Icons.brightness_2,
            isSelected: themeProvider.appThemeMode == AppThemeMode.black,
            onTap: () => themeProvider.setAppThemeMode(AppThemeMode.black),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'System Light/Black',
            icon: Icons.brightness_4,
            isSelected: themeProvider.appThemeMode == AppThemeMode.systemBlack,
            onTap: () => themeProvider.setAppThemeMode(AppThemeMode.systemBlack),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSourceChips(
      BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'System default',
            icon: Icons.auto_awesome,
            isSelected: themeProvider.themeSource == ThemeSource.system,
            onTap: () => themeProvider.setThemeSource(ThemeSource.system),
            enabled: themeProvider.hasSystemColors,
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'App default',
            icon: Icons.app_settings_alt,
            isSelected: themeProvider.themeSource == ThemeSource.app,
            onTap: () => themeProvider.setThemeSource(ThemeSource.app),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Custom color',
            icon: Icons.edit,
            isSelected: themeProvider.themeSource == ThemeSource.custom,
            onTap: () => themeProvider.setThemeSource(ThemeSource.custom),
          ),
        ],
      ),
    );
  }

  Widget _buildContrastChips(
      BuildContext context, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'Standard',
            icon: Icons.contrast,
            isSelected: themeProvider.contrastLevel == ContrastLevel.standard,
            onTap: () => themeProvider.setContrastLevel(ContrastLevel.standard),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'Medium',
            icon: Icons.contrast,
            isSelected: themeProvider.contrastLevel == ContrastLevel.medium,
            onTap: () => themeProvider.setContrastLevel(ContrastLevel.medium),
          ),
          const SizedBox(width: 8),
          _buildChip(
            context,
            label: 'High',
            icon: Icons.contrast,
            isSelected: themeProvider.contrastLevel == ContrastLevel.high,
            onTap: () => themeProvider.setContrastLevel(ContrastLevel.high),
          ),
        ],
      ),
    );
  }

  Widget _buildSeedColorPicker(BuildContext context, ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: themeProvider.currentSeedColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () => _showColorPicker(context, themeProvider),
              child: const Text('Pick'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemePreview(BuildContext context, ThemeProvider themeProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewColors = [
      ColorInfo('Primary', colorScheme.primary, colorScheme.onPrimary),
      ColorInfo('Secondary', colorScheme.secondary, colorScheme.onSecondary),
      ColorInfo('Tertiary', colorScheme.tertiary, colorScheme.onTertiary),
      ColorInfo('Surface', colorScheme.surface, colorScheme.onSurface),
      ColorInfo('Surface Variant', colorScheme.surfaceVariant, colorScheme.onSurfaceVariant),
      ColorInfo('Error', colorScheme.error, colorScheme.onError),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: previewColors.map((colorInfo) {
        return Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: colorInfo.color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.circle,
                color: colorInfo.onColor,
                size: 16,
              ),
              const SizedBox(height: 4),
              Text(
                colorInfo.name,
                style: TextStyle(
                  fontSize: 10,
                  color: colorInfo.onColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final backgroundColor = isSelected
        ? colorScheme.primaryContainer
        : colorScheme.surfaceVariant.withOpacity(0.4);

    final foregroundColor = isSelected
        ? colorScheme.onPrimaryContainer
        : enabled
            ? colorScheme.onSurfaceVariant
            : colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: foregroundColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _predefinedColors.length,
            itemBuilder: (context, index) {
              final color = _predefinedColors[index];
              final isSelected =
                  themeProvider.currentSeedColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () {
                  themeProvider.setCustomSeedColor(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 3,
                          )
                        : Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme Settings Help'),
        content: const Text(
          'Customize your app appearance:\n\n'
          '• Theme Mode:\n'
          '  - Light: Bright background\n'
          '  - Dark: Dark gray background\n'
          '  - Black: Pure black (#000000) for AMOLED\n'
          '  - System: Follows device setting\n'
          '  - System Black: Follows device, but uses black instead of dark\n\n'
          '• Color Source:\n'
          '  - System Default: Uses Material You colors from your wallpaper\n'
          '  - App Default: Uses the app\'s expressive theme\n'
          '  - Custom Color: Choose from predefined colors\n\n'
          '• Contrast: Adjusts text/UI contrast for accessibility\n'
          '• Typography: Select different font families',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDefaultsDialog(
      BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Defaults'),
        content: const Text(
          'This will reset all theme settings to their default values. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _restoreDefaults(themeProvider);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _restoreDefaults(ThemeProvider themeProvider) {
    themeProvider.setAppThemeMode(AppThemeMode.system);
    themeProvider.setThemeSource(ThemeSource.app);
    themeProvider.setContrastLevel(ContrastLevel.standard);
    themeProvider.setTypographyStyle(TypographyStyle.system);
  }

  String _getTypographyDisplayName(TypographyStyle style) {
    switch (style) {
      case TypographyStyle.system:
        return 'System default';
      case TypographyStyle.roboto:
        return 'Roboto';
      case TypographyStyle.openSans:
        return 'Open Sans';
      case TypographyStyle.lato:
        return 'Lato';
    }
  }

  void _showTypographyDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Typography'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TypographyStyle.values.map((style) {
            return RadioListTile<TypographyStyle>(
              title: Text(_getTypographyDisplayName(style)),
              value: style,
              groupValue: themeProvider.typographyStyle,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setTypographyStyle(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class ColorInfo {
  final String name;
  final Color color;
  final Color onColor;

  ColorInfo(this.name, this.color, this.onColor);
}
