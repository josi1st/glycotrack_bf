import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ajout_mesure_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/historique_screen.dart';
import 'screens/alertes_screen.dart';
import 'screens/profil_screen.dart';

class GlycoTrackApp extends StatelessWidget {
  const GlycoTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlycoTrack BF',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/accueil': (_) => const AccueilScreen(),
        '/ajout': (_) => const AjoutMesureScreen(),
      },
    );
  }
}

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> {
  int _index = 0;

  // Index 2 = bouton central "Ajouter" -> ne correspond a aucune page,
  // il ouvre l'ecran d'ajout par-dessus au lieu de changer d'onglet.
  final List<Widget> _pages = const [
    DashboardScreen(),
    HistoriqueScreen(),
    SizedBox.shrink(), // placeholder pour l'index du bouton central
    AlertesScreen(),
    ProfilScreen(),
  ];

  void _onDestinationSelected(int i) {
    if (i == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AjoutMesureScreen()),
      );
      return;
    }
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index == 2 ? 0 : _index,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(
            icon: Icon(Icons.add_circle, size: 32, color: AppTheme.accentGreen),
            label: 'Ajouter',
          ),
          NavigationDestination(icon: Icon(Icons.warning_rounded), label: 'Alertes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}