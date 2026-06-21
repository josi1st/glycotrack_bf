import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool _initialise = false;

  Future<void> initialiser() async {
    if (_initialise) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Ouagadougou'));

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialise = true;
  }

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
