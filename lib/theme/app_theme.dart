/// Thème centralisé de l'application GlycoTrack BF
///
/// Définit:
/// - Palette de couleurs (primaire, accents, alertes)
/// - Polices (Google Fonts: Public Sans)
/// - Styles Material Design 3 pour tous les composants
/// - Cohérence visuelle globale

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Classe contenant toutes les constantes de thème
class AppTheme {
  /// Bleu primaire (couleur principale de la marque)
  static const Color primaryBlue = Color(0xFF1A3A6B);

  /// Vert accent (actions positives, succès)
  static const Color accentGreen = Color(0xFF2ECC8F);

  /// Orange d'alerte (mesures hors normes modérées)
  static const Color alertOrange = Color(0xFFF59E0B);

  /// Rouge d'alerte (mesures critiques)
  static const Color alertRed = Color(0xFFEF4444);

  /// Gris léger de fond
  static const Color backgroundGrey = Color(0xFFF8FAFC);

  /// Blanc pur pour les cartes et dialogs
  static const Color cardWhite = Color(0xFFFFFFFF);

  /// Retourne le thème clair Material Design 3
  ///
  /// Inclut:
  /// - Schéma de couleur personnalisé
  /// - AppBar avec fond bleu et texte blanc
  /// - Cartes arrondies avec ombre
  /// - Boutons avec rayon et padding personnalisés
  /// - Champs de saisie avec bordures arrondies
  /// - Polices Google Fonts (Public Sans)
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: accentGreen,
          surface: backgroundGrey,
        ),
        scaffoldBackgroundColor: backgroundGrey,
        // Utilise la police Google Fonts "Public Sans"
        textTheme: GoogleFonts.publicSansTextTheme(),
        // Customisation de l'AppBar
        appBarTheme: AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.publicSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // Customisation des cartes
        cardTheme: CardThemeData(
          color: cardWhite,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Customisation des boutons élevés
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Customisation des champs de saisie
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      );
}
