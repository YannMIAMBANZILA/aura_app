import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    // CORRECTION V18 : Argument nommé 'initializationSettings' OBLIGATOIRE
    await _notifications.initialize(
      initializationSettings: settings, 
    );
  }

  Future<void> scheduleDailyReminder(bool hasStudiedToday) async {
    const int reminderId = 100;

    if (hasStudiedToday) {
      // CORRECTION V18 : Argument nommé 'id' OBLIGATOIRE
      await _notifications.cancel(id: reminderId);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // CORRECTION V18 : TOUS les arguments sont nommés ici
    await _notifications.zonedSchedule(
      id: reminderId,
      title: 'Ton Aura s\'assombrit...',
      body: 'N\'oublie pas ta session pour maintenir ton niveau !',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'aura_reminders', 
          'Rappels Aura',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showRankUpNotification(String newTitle) async {
    // CORRECTION V18 : TOUS les arguments sont nommés ici aussi
    await _notifications.show(
      id: 200,
      title: 'Félicitations !',
      body: 'Tu es désormais : $newTitle !',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'aura_rank', 
          'Succès Aura',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}