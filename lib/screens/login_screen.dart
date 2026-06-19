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
  String? _erreur;

  Future<void> _connecterBiometrie() async {
    setState(() { _chargement = true; _erreur = null; });
    final succes = await _auth.authentifierBiometrie();
    if (succes) {
      if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
    } else {
      setState(() { _erreur = 'Authentification échouée. Réessayez.'; });
    }
    setState(() { _chargement = false; });
  }

  Future<void> _connecterEmail() async {
    if (_emailController.text.isEmpty) {
      setState(() { _erreur = 'Veuillez saisir votre adresse e-mail.'; });
      return;
    }
    setState(() { _chargement = true; _erreur = null; });
    await _auth.sauvegarderEmail(_emailController.text);
    if (mounted) Navigator.pushReplacementNamed(context, '/accueil');
    setState(() { _chargement = false; });
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Adresse e-mail',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              if (_erreur != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.alertRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_erreur!,
                      style: TextStyle(color: AppTheme.alertRed)),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _chargement ? null : _connecterEmail,
                child: _chargement
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Connexion'),
              ),
              const SizedBox(height: 16),
              const Row(children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('ou', style: TextStyle(color: Colors.grey)),
                ),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _chargement ? null : _connecterBiometrie,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Se connecter avec la biométrie'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                ),
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