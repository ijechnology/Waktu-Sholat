// lib/services/notification_service.dart

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../models/prayer_times_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() {
    return _notificationService;
  }
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inisialisasi Timezone
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // Menangani notifikasi saat app di foreground (iOS)
  }

  // Notifikasi untuk Waktu Sholat
  Future<void> schedulePrayerNotifications(PrayerTimes prayerTimes) async {
    await flutterLocalNotificationsPlugin.cancelAll();

    final location = tz.local;
    final now = tz.TZDateTime.now(location);
    final prayerMap = prayerTimes.toMap();

    int id = 0;
    for (var entry in prayerMap.entries) {
      String name = entry.key;
      String timeString = entry.value;

      List<String> parts = timeString.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      var scheduledTime = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Jika waktu sholat hari ini sudah lewat, jadwalkan untuk besok
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id,
          'Waktunya Sholat!',
          'Sekarang masuk waktu sholat $name (${entry.value})',
          scheduledTime,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_channel_id',
              'Prayer Times',
              channelDescription: 'Channel for prayer time notifications',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default.wav',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        id++;
      } catch (e) {
        print("Error scheduling notification for $name: $e");
      }
    }
  }

  // --- PERUBAHAN DI SINI ---
  // Notifikasi simpel untuk perhitungan zakat
  Future<void> showZakatCalculationNotification(String amount) async {
    await flutterLocalNotificationsPlugin.show(
      99, // ID unik untuk zakat
      'Perhitungan Zakat Selesai',
      'Jumlah zakat mal Anda adalah: $amount',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'zakat_channel_id',
          'Zakat Notifications',
          channelDescription: 'Channel for zakat calculation notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Notifikasi untuk Registrasi
  Future<void> showRegistrationSuccessNotification() async {
    await flutterLocalNotificationsPlugin.show(
      100, // ID unik untuk registrasi
      'Registrasi Berhasil',
      'Akun Anda telah berhasil dibuat. Silakan login.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'auth_channel_id',
          'Auth Notifications',
          channelDescription: 'Channel for auth notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}