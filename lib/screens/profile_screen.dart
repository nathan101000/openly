import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer3<AuthProvider, ThemeProvider, SettingsProvider>(
          builder: (context, auth, theme, settings, child) {
            final displayName = auth.displayName ?? '';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      child: Icon(Icons.person, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(),
                ProfileInfoTile(
                  icon: Icons.email,
                  title: 'Email',
                  value: auth.userName ?? 'Not provided',
                ),
                ProfileInfoTile(
                  icon: Icons.verified_user,
                  title: 'User ID',
                  value: 'Unknown',
                ),
                const SizedBox(height: 20),
                Text('Theme Color',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final color in [
                        const Color(0xff4b5c92),
                        Colors.teal,
                        Colors.deepOrange,
                        Colors.purple
                      ])
                        GestureDetector(
                          onTap: () => theme.updateSeedColor(color),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    theme.seedColor.toARGB32() == color.toARGB32()
                                        ? Colors.black
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 30),
                  SwitchListTile(
                    title: const Text('Remember Login'),
                    value: settings.rememberMe,
                    onChanged: (v) => settings.setRememberMe(v),
                  ),
                  SwitchListTile(
                    title: Text(
                      'Use biometrics (${settings.biometricsAvailable ? 'available' : 'unavailable'})',
                    ),
                    value: settings.useBiometrics,
                    onChanged: settings.biometricsAvailable
                        ? (v) => settings.setUseBiometrics(v)
                        : null,
                  ),
                  const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Logout',
                        style: TextStyle(color: Colors.red)),
                    onPressed: () => _confirmLogout(context, auth),
                  ),
                ),
              ],
            );
          },
        ),
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
