import 'package:flutter/material.dart';
import 'package:openly/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/favorites_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
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
    Future.microtask(() =>
        Provider.of<AuthProvider>(context, listen: false).loadAuthState());
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
                  ? Scaffold(
                      appBar: AppBar(
                        actions: [
                          IconButton(
                            icon: Icon(
                              switch (themeProvider.themeMode) {
                                ThemeMode.light => Icons.light_mode,
                                ThemeMode.dark => Icons.dark_mode,
                                ThemeMode.system => Icons.brightness_auto,
                              },
                            ),
                            onPressed: () => themeProvider.toggleTheme(),
                          ),
                        ],
                      ),
                      body: const MainScreen(),
                    )
                  : const LoginScreen(),
        );
      },
    );
  }
}
