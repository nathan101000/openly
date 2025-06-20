import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final auth = LocalAuthentication();
  final canCheck = await auth.canCheckBiometrics;
  final isSupported = await auth.isDeviceSupported();
  final available = await auth.getAvailableBiometrics();

  if (!canCheck || !isSupported || available.isEmpty) return false;

  final didAuthenticate = await auth.authenticate(
    localizedReason: 'Authenticate to continue',
    options: const AuthenticationOptions(
      biometricOnly: true,
      stickyAuth: true,
    ),
  );

  return didAuthenticate;
}
