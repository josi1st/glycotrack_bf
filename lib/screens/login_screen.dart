import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();

  bool _chargement = false;
  bool _profilExiste = false;
  bool _verificationInitiale = true;
  String? _erreur;

  @override
  void initState() {
    super.initState();
    _verifierProfil();
  }

  Future<void> _verifierProfil() async {
    final existe = await _auth.profilExiste();
    setState(() {
      _profilExiste = existe;
      _verificationInitiale = false;
    });

    // Si un profil existe déjà, on déclenche directement la biométrie
    if (existe) {
      _authentifier();
    }
  }

  Future<void> _authentifier() async {
    setState(() { _chargement = true; _erreur = null; });

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

  Future<void> _creerProfilEtAuthentifier() async {
    if (_emailController.text.trim().isEmpty || !_emailController.text.contains('@')) {
      setState(() { _erreur = 'Veuillez saisir une adresse e-mail valide.'; });
      return;
    }
    setState(() { _erreur = null; });

    // L'email identifie juste l'utilisateur, il NE donne PAS accès à l'app
    await _auth.sauvegarderEmail(_emailController.text.trim());

    // La biométrie reste obligatoire pour entrer
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
                // Première utilisation : on demande l'email (identification, pas connexion)
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bienvenue ! Renseignez votre e-mail pour créer votre profil local.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse e-mail',
                    prefixIcon: Icon(Icons.email_outlined),
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
                  onPressed: _profilExiste ? _authentifier : _creerProfilEtAuthentifier,
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
    _emailController.dispose();
    super.dispose();
  }
}