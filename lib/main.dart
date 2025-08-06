import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/update_service.dart';

void main() {
  runApp(const Openly());
}

class Openly extends StatelessWidget {
  const Openly({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _updateChecked = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.loadAuthState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Openly',
      themeMode: themeProvider.themeMode,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (!_updateChecked && auth.isAuthenticated) {
            _updateChecked = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              UpdateService.checkForUpdates(context);
            });
          }

          if (auth.isChecking) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return auth.isAuthenticated
                ? const MainScreen()
                : const LoginScreen();
          }
        },
      ),
    );
  }
}
