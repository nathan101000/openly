import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/update_service.dart';
import 'theme_settings_screen.dart';

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
                    const ListTile(
                      leading: Icon(Icons.verified_user),
                      title: Text('User ID'),
                      subtitle: Text('Unknown'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

// Appearance Section
              _buildSectionHeader(context, 'Appearance'),
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.seedColor,
                    child: Icon(
                      _getThemeModeIcon(theme.appThemeMode),
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  title: const Text('Appearance'),
                  subtitle: Text(
                    '${_getThemeModeDisplayName(theme.appThemeMode)} • '
                    '${theme.themeSource == ThemeSource.system ? 'System color' : theme.themeSource == ThemeSource.app ? 'App default' : 'Custom color'}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ThemeSettingsScreen(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // App Section
              _buildSectionHeader(context, 'App'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.system_update_alt),
                  title: const Text('Check for Updates'),
                  subtitle: const Text('Get the latest features and fixes'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => UpdateService.checkForUpdates(context,
                      showNoUpdateDialog: true),
                ),
              ),

              const SizedBox(height: 24),

              // Actions Section
              _buildSectionHeader(context, 'Actions'),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title:
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                  subtitle: const Text('Sign out of your account'),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      size: 16, color: Colors.red),
                  onTap: () => _confirmLogout(context, auth),
                ),
              ),
            ],
          );
        },
      ),
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

  String _getThemeModeDisplayName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.black:
        return 'Black';
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.systemBlack:
        return 'System (Black)';
    }
  }

  IconData _getThemeModeIcon(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.black:
        return Icons.brightness_2;
      case AppThemeMode.system:
        return Icons.brightness_auto;
      case AppThemeMode.systemBlack:
        return Icons.brightness_4;
    }
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
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await auth.logout();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
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
