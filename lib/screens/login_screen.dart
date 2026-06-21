/// Écran d'authentification et création de profil
///
/// Gère:
/// - Création du profil initial (nom et téléphone)
/// - Authentification biométrique (empreinte, visage, PIN)
/// - Validation des entrées utilisateur
/// - Navigation vers l'écran d'accueil après succès

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

/// Écran StatefulWidget pour l'authentification
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Service d'authentification
  final AuthService _auth = AuthService();

  /// Contrôleur pour le nom complet
  final _nomController = TextEditingController();

  /// Contrôleur pour le numéro de téléphone
  final _telephoneController = TextEditingController();

  /// Flag indiquant un chargement en cours
  bool _chargement = false;

  /// True si un profil existe déjà
  bool _profilExiste = false;

  /// True pendant la vérification initiale du profil
  bool _verificationInitiale = true;

  /// Message d'erreur à afficher
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _verifierProfil();
  }

  /// Vérifie si un profil utilisateur existe
  ///
  /// Si oui, déclenche immédiatement l'authentification
  /// Si non, affiche le formulaire de création
  Future<void> _verifierProfil() async {
    final existe = await _auth.profilExiste();
    setState(() {
      _profilExiste = existe;
      _verificationInitiale = false;
    });

    if (existe) {
      _authentifier();
    }
  }

  /// Authentifie l'utilisateur par biométrie
  ///
  /// Vérifie que la biométrie est disponible avant de déclencher
  /// l'authentification native
  Future<void> _authentifier() async {
    setState(() {
      _chargement = true;
      _erreur = null;
    });

    final biometrieOk = await _auth.biometrieDisponible();
    if (!biometrieOk) {
      setState(() {
        _erreur = 'Aucune authentification biométrique ou code de verrouillage '
            'n\'est configuré sur cet appareil. Veuillez en activer un dans '
            'les paramètres de votre téléphone (Empreinte digitale, Visage ou Code PIN).';
        _chargement = false;
      });
      return;
    }

    final succes = await _auth.authentifierBiometrie();

    if (succes) {
      if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
    } else {
      setState(() {
        _erreur = 'Authentification échouée ou annulée. Réessayez.';
        _chargement = false;
      });
    }
  }

  /// Crée un nouveau profil et tente une authentification
  ///
  /// Étapes:
  /// 1. Récupère et valide les champs (nom, téléphone)
  /// 2. Sauvegarde le profil de manière sécurisée
  /// 3. Déclenche l'authentification biométrique
  Future<void> _creerProfilEtAuthentifier() async {
    final nom = _nomController.text.trim();
    final telephone = _telephoneController.text.trim();

    // Valider le nom
    if (nom.isEmpty) {
      setState(() {
        _erreur = 'Veuillez saisir votre nom.';
      });
      return;
    }

    // Valider le numéro de téléphone (format Burkina Faso: 8 chiffres)
    final telephoneValide =
        RegExp(r'^(\+226)?[0-9]{8}$').hasMatch(telephone.replaceAll(' ', ''));
    if (!telephoneValide) {
      setState(() {
        _erreur =
            'Numéro invalide. Format attendu : 8 chiffres (ex: 70123456).';
      });
      return;
    }

    setState(() {
      _erreur = null;
    });
    await _auth.sauvegarderProfil(nom: nom, telephone: telephone);
    await _authentifier();
  }

  @override
  Widget build(BuildContext context) {
    if (_verificationInitiale) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.bloodtype_rounded,
                    size: 48, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('GlycoTrack BF',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const Text('Master e-Santé & Télémédecine',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 48),
              if (!_profilExiste) ...[
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bienvenue ! Renseignez vos informations pour créer votre profil local.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nomController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nom complet',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    hintText: 'Ex: 70123456',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+226 ',
                  ),
                ),
                const SizedBox(height: 20),
              ],
              if (_erreur != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.alertRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_erreur!,
                      style: TextStyle(color: AppTheme.alertRed, fontSize: 13)),
                ),
                const SizedBox(height: 16),
              ],
              if (_chargement)
                const CircularProgressIndicator()
              else
                ElevatedButton.icon(
                  onPressed: _profilExiste
                      ? _authentifier
                      : _creerProfilEtAuthentifier,
                  icon: const Icon(Icons.fingerprint),
                  label: Text(_profilExiste
                      ? 'S\'authentifier'
                      : 'Créer mon profil et s\'authentifier'),
                ),
              const SizedBox(height: 16),
              Text(
                '🔒 La biométrie (ou le code de votre téléphone) est obligatoire '
                'pour accéder à vos données de santé.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }
}
