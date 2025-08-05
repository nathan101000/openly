import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import '../models/api_exception.dart';
import '../providers/auth_provider.dart';
import '../services/auth_service.dart';
import '../widgets/snackbar.dart';

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
  final LocalAuthentication _localAuth = LocalAuthentication();
  bool _canBiometric = false;
  bool _hasStoredAuth = false;
  bool _obscurePassword = true;
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
    _initBiometric();
    _animController.forward();
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
      if (mounted) {
        showAppSnackBar(context, 'Login successful!', success: true);
      }
    } on ApiException catch (e) {
      showAppSnackBar(context, e.message);
    } catch (e) {
      showAppSnackBar(context, 'Unexpected error occurred');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Door Access Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
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
                AutofillGroup(
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        autofillHints: const [AutofillHints.username],
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passwordController,
                        autofillHints: const [AutofillHints.password],
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() {
                              _obscurePassword = !_obscurePassword;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Login'),
                    ),
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
        ),
      ),
    );
  }
}
