/// Service pour la gestion des notifications locales
///
/// Gère:
/// - Initialisation du système de notifications (fuseau horaire d'Afrique de l'Ouest)
/// - Planification de rappels quotidiens
/// - Envoi de notifications de test
/// - Stockage et récupération des horaires de rappel sauvegardés

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service singleton pour la gestion des notifications
class NotificationService {
  /// Plugin Flutter pour les notifications locales
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Stockage sécurisé pour les horaires de rappel
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Flag pour éviter d'initialiser plusieurs fois
  bool _initialise = false;

  /// Initialise le système de notifications
  Future<void> initialiser() async {
    if (_initialise) return;

    // Initialiser les données de fuseaux horaires
    tz_data.initializeTimeZones();
    // Définir le fuseau horaire local (Ouagadougou = Afrique de l'Ouest)
    tz.setLocalLocation(tz.getLocation('Africa/Ouagadougou'));

    // Créer le canal de notification Android
    const androidSettings = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    // Demander la permission pour les notifications (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialise = true;
  }

  /// Planifie un rappel quotidien à l'heure spécifiée
  ///
  /// Va:
  /// - Créer une notification répétée chaque jour à heure/minute
  /// - Sauvegarder l'horaire pour réaffichage dans le profil
  /// - Fonctionner même en arrière-plan ou écran verrouillé
  Future<void> planifierRappelQuotidien({
    required int heure,
    required int minute,
  }) async {
    await initialiser();

    final prochaine = _prochaineInstance(heure, minute);

    await _plugin.zonedSchedule(
      0,
      'GlycoTrack BF — Rappel',
      'N\'oubliez pas de mesurer votre glycémie aujourd\'hui',
      prochaine,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rappel_glycemie',
          'Rappels de mesure',
          channelDescription: 'Rappel quotidien pour mesurer la glycémie',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // On sauvegarde l'heure choisie pour pouvoir l'afficher dans le diagnostic
    await _storage.write(key: 'rappel_heure', value: heure.toString());
    await _storage.write(key: 'rappel_minute', value: minute.toString());
    await _storage.write(
        key: 'rappel_prochaine_date', value: prochaine.toIso8601String());
  }

  Future<Map<String, String>?> infosRappelSauvegarde() async {
    final heure = await _storage.read(key: 'rappel_heure');
    final minute = await _storage.read(key: 'rappel_minute');
    final prochaine = await _storage.read(key: 'rappel_prochaine_date');
    if (heure == null || minute == null) return null;
    return {
      'heure': heure,
      'minute': minute,
      'prochaine': prochaine ?? '',
    };
  }

  /// Retourne un résumé lisible des rappels programmés (pour debug/affichage utilisateur)
  Future<List<String>> rappelsActifsLisibles() async {
    final rappels = await _plugin.pendingNotificationRequests();
    return rappels.map((r) {
      return '${r.title ?? "Rappel"} — ${r.body ?? ""}';
    }).toList();
  }

  /// Envoie une notification de test IMMÉDIATE (utile pour vérifier que tout fonctionne)
  Future<void> testerNotificationImmediate() async {
    await initialiser();
    await _plugin.show(
      999,
      'GlycoTrack BF — Test',
      'Si vous voyez ceci, les notifications fonctionnent correctement !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rappel_glycemie',
          'Rappels de mesure',
          channelDescription: 'Rappel quotidien pour mesurer la glycémie',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  tz.TZDateTime _prochaineInstance(int heure, int minute) {
    final maintenant = tz.TZDateTime.now(tz.local);
    var date = tz.TZDateTime(
      tz.local,
      maintenant.year,
      maintenant.month,
      maintenant.day,
      heure,
      minute,
    );
    if (date.isBefore(maintenant)) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }

  Future<void> annulerRappels() async {
    await _plugin.cancelAll();
    await _storage.delete(key: 'rappel_heure');
    await _storage.delete(key: 'rappel_minute');
    await _storage.delete(key: 'rappel_prochaine_date');
  }

  Future<List<PendingNotificationRequest>> rappelsActifs() async {
    return await _plugin.pendingNotificationRequests();
  }
}
