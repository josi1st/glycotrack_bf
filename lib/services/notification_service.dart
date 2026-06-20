import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialiser() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> planifierRappelQuotidien({
    required int heure,
    required int minute,
  }) async {
    await _plugin.zonedSchedule(
      0,
      'GlycoTrack BF — Rappel',
      'N\'oubliez pas de mesurer votre glycémie aujourd\'hui',
      _prochaineInstance(heure, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'rappel_glycemie',
          'Rappels de mesure',
          channelDescription: 'Rappel quotidien pour mesurer la glycémie',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
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
  }
}
