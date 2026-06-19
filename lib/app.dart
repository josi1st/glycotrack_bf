import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ajout_mesure_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/mesures_screen.dart';
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

  final List<Widget> _pages = const [
    DashboardScreen(),
    MesuresScreen(),
    HistoriqueScreen(),
    AlertesScreen(),
    ProfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Mesures'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historique'),
          NavigationDestination(icon: Icon(Icons.warning_rounded), label: 'Alertes'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}