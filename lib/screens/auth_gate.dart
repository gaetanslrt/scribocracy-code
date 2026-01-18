import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:scribocracy_new/screens/home.dart';
import 'package:scribocracy_new/theme.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _status = "SECURE_LOCKED";

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _status = "SCANNING_BIOMETRICS...";
      });
      
      // Vérifie si le matériel est dispo
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      if (!canAuthenticateWithBiometrics) {
         // Si pas de capteur (émulateur parfois), on laisse passer ou on demande un code
         // Pour l'instant on laisse passer pour le dev
         _unlock();
         return;
      }

      authenticated = await auth.authenticate(
        localizedReason: 'IDENTITY VERIFICATION REQUIRED',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      setState(() => _status = "BIO_SENSOR_ERROR");
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      _unlock();
    } else {
      setState(() => _status = "ACCESS_DENIED");
    }
  }
  
  void _unlock() {
      Navigator.pushReplacement(
        context, 
        MaterialPageRoute(builder: (context) => const HomeScreen())
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.fingerprint, size: 80, color: AppTheme.dangerRed),
            const SizedBox(height: 20),
            Text(
              "SCRIBOCRACY_VAULT",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 10),
            Text(
              _status,
              style: TextStyle(
                fontFamily: 'ShareTechMono', 
                color: _status == "ACCESS_DENIED" ? AppTheme.dangerRed : AppTheme.neonCyan
              ),
            ),
            if (_status == "ACCESS_DENIED")
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: OutlinedButton.icon(
                  onPressed: _authenticate,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.dangerRed),
                    foregroundColor: AppTheme.dangerRed,
                    // LA MODIFICATION EST ICI (Coins coupés)
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15)
                  ),
                  icon: const Icon(Icons.fingerprint),
                  label: const Text("RETRY_HANDSHAKE", style: TextStyle(fontFamily: 'Orbitron')),
                ),
              )
          ],
        ),
      ),
    );
  }
}