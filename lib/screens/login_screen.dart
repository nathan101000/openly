import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';
import '../services/auth_service.dart';
import '../services/biometric_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool loading = false;
  bool _canBiometric = false;
  bool _hasStoredAuth = false;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim =
        Tween(begin: const Offset(0, 0.1), end: Offset.zero).animate(_fadeAnim);
    _init();
    _animController.forward();
  }

  Future<void> _init() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _canBiometric = settings.biometricsAvailable;
    _hasStoredAuth = await AuthService.loadStoredAuth() != null;
    setState(() {}); // refresh UI (shows / hides fingerprint)
  }

  Future<void> _loginWithBiometric() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final didAuth = await authenticateWithBiometrics();
    if (!didAuth) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Biometric authentication failed or canceled')),
        );
      }
      return;
    }

    try {
      await auth.biometricLogin();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    }
  }

  Future<void> _login() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    setState(() => loading = true);
    try {
      await auth.login(emailController.text, passwordController.text);

      // store or discard creds based on “Remember me”
      if (settings.rememberMe) {
        await settings.storeCredentials(
          emailController.text,
          passwordController.text,
        );
      } else {
        await AuthService.clearAuth();
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return Column(
                          children: [
                            SwitchListTile(
                              dense: true,
                              title: const Text('Remember Me'),
                              value: settings.rememberMe,
                              onChanged: (v) => settings.setRememberMe(v),
                            ),
                            if (settings.biometricsAvailable)
                              SwitchListTile(
                                dense: true,
                                title: const Text('Use biometrics'),
                                value: settings.useBiometrics,
                                onChanged: (v) => settings.setUseBiometrics(v),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: loading ? null : _login,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Login'),
                        ),
                      ),
                    ),
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        if (!_canBiometric ||
                            !_hasStoredAuth ||
                            !settings.useBiometrics) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            IconButton(
                              iconSize: 48,
                              icon: const Icon(Icons.fingerprint),
                              onPressed: loading ? null : _loginWithBiometric,
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
