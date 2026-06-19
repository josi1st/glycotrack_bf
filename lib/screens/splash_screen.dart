import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/consentement_dialog.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _initialiser();
  }

  Future<void> _initialiser() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final premierLancement = await _auth.estPremierLancement();
    if (premierLancement) {
      _afficherConsentement();
    } else {
      _allerLogin();
    }
  }

  void _afficherConsentement() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConsentementDialog(
        onAccepter: () async {
          await _auth.enregistrerConsentement();
          if (mounted) Navigator.pop(context);
          _allerLogin();
        },
        onRefuser: () {
          Navigator.pop(context);
          _afficherConsentement();
        },
      ),
    );
  }

  void _allerLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.bloodtype_rounded,
                size: 60,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GlycoTrack BF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Suivi de glycémie intelligent',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}