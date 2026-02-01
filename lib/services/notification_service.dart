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

    // VERSION 17 : Argument positionnel (pas de nom 'initializationSettings')
    await _notifications.initialize(settings);
  }

  Future<void> scheduleDailyReminder(bool hasStudiedToday) async {
    const int reminderId = 100;

    if (hasStudiedToday) {
      // VERSION 17 : Argument positionnel
      await _notifications.cancel(reminderId);
      return;
    }

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, 18);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // VERSION 17 : Arguments mélangés (positionnels au début, nommés à la fin)
    await _notifications.zonedSchedule(
      reminderId,                                      // id (positionnel)
      'Ton Aura s\'assombrit...',                      // title (positionnel)
      'N\'oublie pas ta session pour maintenir ton niveau !', // body (positionnel)
      scheduledDate,                                   // date (positionnel)
      const NotificationDetails(                       // details (positionnel)
        android: AndroidNotificationDetails(
          'aura_reminders', 
          'Rappels Aura',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Nommé
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime, // Nommé
    );
  }

  Future<void> showRankUpNotification(String newTitle) async {
    // VERSION 17 : Arguments positionnels
    await _notifications.show(
      200, // id
      'Félicitations !', // titre
      'Tu es désormais : $newTitle !', // corps
      const NotificationDetails( // details
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