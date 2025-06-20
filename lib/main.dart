import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'services/auth_service.dart';
import 'services/biometric_utils.dart';
import 'util.dart';
import 'theme.dart';

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
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
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
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final settings = Provider.of<SettingsProvider>(context, listen: false);

      await auth.loadAuthState(); // loads creds (if any)

      if (auth.isAuthenticated &&
          settings.useBiometrics &&
          settings.biometricsAvailable) {
        final didAuth = await authenticateWithBiometrics();
        if (didAuth) {
          auth.markAuthorized();
        } else {
          await auth.logout(); // wipe creds on failed scan
        }
      }
      auth.finishChecking(); // splash finished – build UI
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final textTheme = createTextTheme(context, "Inter", "Inter");
    final theme = MaterialTheme(textTheme, themeProvider.seedColor);

    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return MaterialApp(
          title: 'Openly',
          themeMode: themeProvider.themeMode,
          theme: theme.light(),
          darkTheme: theme.dark(),
          home: auth.isChecking
              ? const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : auth.isAuthenticated
                  ? const MainScreen() // AppBar handled here
                  : const LoginScreen(),
        );
      },
    );
  }
}
