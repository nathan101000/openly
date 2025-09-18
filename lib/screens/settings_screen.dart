import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/update_service.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, auth, theme, child) {
          final displayName = auth.displayName ?? '';
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Account Section
              _buildSectionHeader(context, 'Account'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(displayName),
                      subtitle: Text(auth.userName ?? 'Not provided'),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.logout,
                          color: Theme.of(context).colorScheme.error,),
                      title: Text('Logout',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error,),),
                      subtitle: const Text('Sign out of your account'),
                      trailing: Icon(Icons.arrow_forward_ios,
                          size: 16, color: Theme.of(context).colorScheme.error,),
                      onTap: () => _confirmLogout(context, auth),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        switch (theme.themeMode) {
                          ThemeMode.light => Icons.light_mode,
                          ThemeMode.dark => Icons.dark_mode,
                          ThemeMode.system => Icons.brightness_auto,
                        },
                      ),
                      title: const Text('Theme Mode'),
                      subtitle: Text(
                        switch (theme.themeMode) {
                          ThemeMode.light => 'Light mode',
                          ThemeMode.dark => 'Dark mode',
                          ThemeMode.system => 'System default',
                        },
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => theme.toggleTheme(),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text('Theme Color'),
                      subtitle: const Text('Choose your preferred color'),
                      trailing: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: theme.seedColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: Theme.of(context).dividerColor),
                        ),
                      ),
                      onTap: () => _showColorPicker(context, theme),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // App Section
              _buildSectionHeader(context, 'App'),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.system_update_alt),
                      title: const Text('Check for Updates'),
                      subtitle: const Text('Get the latest features and fixes'),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => UpdateService.checkForUpdates(context,
                          showNoUpdateDialog: true,),
                    ),
                    const Divider(height: 1),
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snapshot) {
                        final versionText = (snapshot.hasData)
                            ? snapshot.data!.version.split('+').first
                            : 'Loading...';

                        return ListTile(
                          leading: const Icon(Icons.info_outline),
                          title: const Text('Version'),
                          subtitle: Text(versionText),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider theme) async {
    Color selected = theme.seedColor;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Pick theme color'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 320,
              child: ColorPicker(
                color: selected,
                onColorChanged: (c) => selected = c,
                showColorName: false,
                showColorCode: false,
                enableOpacity: false,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.onSurface,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                theme.updateSeedColor(selected);
                Navigator.of(ctx).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.primary,
                foregroundColor: Theme.of(ctx).colorScheme.onPrimary,
              ),
              child: const Text('Select'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.onSurface,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
