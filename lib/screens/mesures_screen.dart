import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mesures_provider.dart';
import '../widgets/carte_mesure.dart';

class MesuresScreen extends StatelessWidget {
  const MesuresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MesuresProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Mesures')),
      body: provider.chargement
          ? const Center(child: CircularProgressIndicator())
          : provider.mesures.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Aucune mesure enregistrée',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: provider.mesures.length,
                  itemBuilder: (_, i) => CarteMesure(
                    mesure: provider.mesures[i],
                    onSupprimer: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Supprimer ?'),
                          content: const Text('Cette mesure sera supprimée définitivement.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context, false),
                                child: const Text('Annuler')),
                            TextButton(onPressed: () => Navigator.pop(context, true),
                                child: const Text('Supprimer',
                                    style: TextStyle(color: Colors.red))),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        provider.supprimer(provider.mesures[i]);
                      }
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/ajout'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle mesure'),
      ),
    );
  }
}