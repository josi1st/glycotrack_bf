/// Widget pour afficher un graphique linéaire de l'évolution de la glycémie
///
/// Affiche:
/// - Courbe d'évolution des mesures au fil du temps
/// - Lignes de seuil (normal, alerte orange, alerte critique)
/// - Grille avec labels de date et valeurs
/// - Gère l'historique complet des mesures

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/mesure_glycemie.dart';
import '../theme/app_theme.dart';

/// Widget stateless pour le graphique de glycémie
class GraphiqueGlycemie extends StatelessWidget {
  /// Liste des mesures à afficher (sera inversée pour la chronologie)
  final List<MesureGlycemie> mesures;

  const GraphiqueGlycemie({super.key, required this.mesures});

  @override
  Widget build(BuildContext context) {
    // Afficher un message si aucune donnée
    if (mesures.isEmpty) {
      return const Center(child: Text('Aucune donnée à afficher'));
    }

    // Inverser pour afficher la chronologie correcte (ancien -> récent)
    final reversed = mesures.reversed.toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          horizontalInterval: 0.5,
          getDrawingHorizontalLine: (_) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index < 0 || index >= reversed.length) {
                  return const SizedBox.shrink();
                }
                final date = reversed[index].date;
                return Text(
                  '${date.day}/${date.month}',
                  style: const TextStyle(fontSize: 9),
                );
              },
            ),
          ),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: 1.26,
              color: AppTheme.alertRed,
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Seuil élevé',
                style: TextStyle(color: AppTheme.alertRed, fontSize: 10),
              ),
            ),
            HorizontalLine(
              y: 0.70,
              color: AppTheme.alertOrange,
              strokeWidth: 1.5,
              dashArray: [5, 5],
              label: HorizontalLineLabel(
                show: true,
                labelResolver: (_) => 'Seuil bas',
                style: TextStyle(color: AppTheme.alertOrange, fontSize: 10),
              ),
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: reversed
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value.valeur))
                .toList(),
            isCurved: true,
            color: AppTheme.primaryBlue,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, _, __, ___) {
                final mesure = reversed[spot.x.toInt()];
                return FlDotCirclePainter(
                  radius: 5,
                  color: mesure.estCritique
                      ? AppTheme.alertRed
                      : mesure.estAlerteOrange
                          ? AppTheme.alertOrange
                          : AppTheme.accentGreen,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryBlue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }
}
