import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canBiometric = false;
  bool _hasStoredAuth = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final canCheck = await _localAuth.canCheckBiometrics &&
        await _localAuth.isDeviceSupported();
    final stored = await AuthService.loadStoredAuth();
    setState(() {
      _canBiometric = canCheck;
      _hasStoredAuth = stored != null;
    });
  }

  Future<void> _loginWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to login',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (authenticated && mounted) {
        final auth = Provider.of<AuthProvider>(context, listen: false);
        await auth.biometricLogin();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    setState(() => loading = true);
    try {
      await auth.login(emailController.text, passwordController.text);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Door Access Login'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.themeMode == ThemeMode.light
                  ? Icons.dark_mode
                  : themeProvider.themeMode == ThemeMode.dark
                      ? Icons.brightness_auto
                      : Icons.light_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.door_front_door, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _login,
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
            if (_canBiometric && _hasStoredAuth) ...[
              const SizedBox(height: 20),
              IconButton(
                iconSize: 48,
                icon: const Icon(Icons.fingerprint),
                onPressed: loading ? null : _loginWithBiometric,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
