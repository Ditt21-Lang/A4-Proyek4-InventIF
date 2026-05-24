import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workmanager/workmanager.dart';

class NotificationService {
  static const String pendingSyncNotificationTask =
      'pendingSyncNotificationTask';

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _fln =
      FlutterLocalNotificationsPlugin();
  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;

    final androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    final initSettings =
        InitializationSettings(android: androidSettings, iOS: darwinSettings);
    await _fln.initialize(settings: initSettings);
    await _requestPermissions();
    initialized = true;
  }

  Future<void> _requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _fln
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> showNotification(int id, String title, String body) async {
    await init();
    final androidDetails = AndroidNotificationDetails(
      'inventif_channel',
      'InventIF Notifications',
      channelDescription: 'Notifications for InventIF app',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'InventIF Notification',
      playSound: true,
    );
    final iosDetails = DarwinNotificationDetails();
    final platformDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await _fln.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: platformDetails,
    );
  }

  Future<void> scheduleBackgroundReminder({
    required String title,
    required String body,
    Duration frequency = const Duration(minutes: 15),
  }) async {
    await Workmanager().registerPeriodicTask(
      pendingSyncNotificationTask,
      pendingSyncNotificationTask,
      frequency: frequency,
      existingWorkPolicy: ExistingWorkPolicy.keep,
      inputData: {
        'title': title,
        'body': body,
      },
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }

  Future<void> cancelBackgroundReminder() async {
    await Workmanager().cancelByUniqueName(pendingSyncNotificationTask);
  }
}
