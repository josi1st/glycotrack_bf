/// Écran de démarrage (splash screen)
///
/// Affiche:
/// - Logo de l'application
/// - Animation de chargement (2 secondes)
/// - Vérification du consentement RGPD
/// - Redirection vers authentification ou consentement

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/consentement_dialog.dart';

/// Écran StatefulWidget de démarrage
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Service d'authentification pour les vérifications
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _initialiser();
  }

  /// Initialise l'app:
  /// 1. Affiche le splash screen pendant 2 secondes
  /// 2. Vérifie si c'est le premier lancement
  /// 3. Affiche le dialog de consentement RGPD ou va à la connexion
  Future<void> _initialiser() async {
    // Afficher le splash screen pendant 2 secondes
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Vérifier si premier lancement (consentement RGPD non enregistré)
    final premierLancement = await _auth.estPremierLancement();
    if (premierLancement) {
      _afficherConsentement();
    } else {
      _allerLogin();
    }
  }

  /// Affiche le dialog de consentement RGPD
  ///
  /// L'utilisateur doit accepter pour continuer
  void _afficherConsentement() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConsentementDialog(
        onAccepter: () async {
          // Enregistrer l'acceptation du consentement
          await _auth.enregistrerConsentement();
          if (mounted) Navigator.pop(context);
          _allerLogin();
        },
        onRefuser: () {
          Navigator.pop(context);
          // Afficher à nouveau si l'utilisateur refuse
          _afficherConsentement();
        },
      ),
    );
  }

  /// Navigue vers l'écran de connexion
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
