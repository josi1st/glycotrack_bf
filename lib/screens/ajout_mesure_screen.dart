import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mesure_glycemie.dart';
import '../providers/mesures_provider.dart';
import '../theme/app_theme.dart';

class AjoutMesureScreen extends StatefulWidget {
  const AjoutMesureScreen({super.key});

  @override
  State<AjoutMesureScreen> createState() => _AjoutMesureScreenState();
}

class _AjoutMesureScreenState extends State<AjoutMesureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valeurController = TextEditingController();
  final _noteController = TextEditingController();
  String _moment = 'À jeun';
  bool _enregistrement = false;

  final List<String> _moments = ['À jeun', 'Après repas', 'Au coucher', 'Autre'];

  Future<void> _enregistrer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _enregistrement = true; });

    final mesure = MesureGlycemie()
      ..valeur = double.parse(_valeurController.text.replaceAll(',', '.'))
      ..date = DateTime.now()
      ..moment = _moment
      ..note = _noteController.text;

    await context.read<MesuresProvider>().ajouter(mesure);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Mesure enregistrée : ${mesure.valeurFormatee} — ${mesure.statut}'),
        backgroundColor: mesure.estCritique ? AppTheme.alertRed : AppTheme.accentGreen,
      ));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une mesure')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Valeur de glycémie (g/L)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _valeurController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  hintText: 'Ex: 1.10',
                  suffixText: 'g/L',
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Valeur requise';
                  final val = double.tryParse(v.replaceAll(',', '.'));
                  if (val == null) return 'Valeur invalide';
                  if (val < 0 || val > 5) return 'Valeur hors plage (0–5 g/L)';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Moment de la mesure',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _moments.map((m) => ChoiceChip(
                  label: Text(m),
                  selected: _moment == m,
                  onSelected: (_) => setState(() { _moment = m; }),
                  selectedColor: AppTheme.primaryBlue,
                  labelStyle: TextStyle(
                    color: _moment == m ? Colors.white : Colors.black,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 24),
              const Text('Note (optionnelle)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Ex: Après déjeuner copieux...',
                  prefixIcon: Icon(Icons.note_outlined),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _enregistrement ? null : _enregistrer,
                icon: _enregistrement
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                label: const Text('Enregistrer la mesure'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _valeurController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}