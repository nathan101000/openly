import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';

import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/splash_screen.dart'; // Your animated splash screen

import 'services/update_service.dart';
import 'util.dart';
import 'theme.dart';

import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:openly/services/update_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true);
  UpdateService.initialize();
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textTheme = createTextTheme(context, "Inter", "Inter");
          final theme = MaterialTheme(textTheme, themeProvider.seedColor);

          return MaterialApp(
            title: 'Openly',
            themeMode: themeProvider.themeMode,
            theme: theme.light(),
            darkTheme: theme.dark(),
            debugShowCheckedModeBanner: false,
            home:
                const SplashWrapper(), // 👈 Splash screen runs inside MaterialApp
          );
        },
      ),
    );
  }
}

/// Shows SplashScreen briefly, then loads the real app
class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _startSplashDelay();
  }

  void _startSplashDelay() async {
    await Future.delayed(const Duration(milliseconds: 4200));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showSplash ? const SplashScreen() : const AppEntryPoint();
  }
}

/// The actual app logic — loads auth state, then shows login or main
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
    final auth = Provider.of<AuthProvider>(context);

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
    }

    return auth.isAuthenticated ? const MainScreen() : const LoginScreen();
  }
}
