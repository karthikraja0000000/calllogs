import 'dart:async';
import 'dart:ui';

import 'package:call_logs/repositories/call_log_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _syncCallLogs() async {
  try {
    final repo = CallLogRepository();
    final logs = await repo.getCallLogs();
    final prefs = await SharedPreferences.getInstance();
    final lastSentMills = prefs.getInt('last_sent_timestamp');
    final lastSent =
        lastSentMills != null
            ? DateTime.fromMillisecondsSinceEpoch(lastSentMills)
            : null;

    for (var log in logs) {
      if (lastSent == null || log.dateTime.isAfter(lastSent)) {
        final success = await repo.sendCallLogsToApi(log);
        if (success) {
          await prefs.setInt(
            'last_sent_timestamp',
            log.dateTime.millisecondsSinceEpoch,
          );
          if (kDebugMode) {
            print("BackgroundFetch: Sent log at ${log.dateTime}");
          }
        }
      }else{
        if (kDebugMode) {
          print("Background Fetch no new call data to send");
        }
      }
    }
  } catch (e) {
    if (kDebugMode) {
      print("Sync error: $e");
    }
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initializeService() async {
  final services = FlutterBackgroundService();

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    "call_logs_sync",
    "Call Logs Sync",
    description: 'Your call logs Syncing in background',
    importance: Importance.low,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
  >()
      ?.createNotificationChannel(channel);

  await services.configure(
    iosConfiguration: IosConfiguration(autoStart: true),

    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: "call_logs_sync",
      initialNotificationTitle: "Call Logs Sync",
      initialNotificationContent: 'Your call logs Syncing in background',
      foregroundServiceNotificationId: 888,
    ),
  );
  await services.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {

    await service.setForegroundNotificationInfo(
      title: "Call Logs Sync",
      content: 'Your call logs Syncing in background',

    );
    service.on('stopServices').listen((event) {
      service.stopSelf();
    });
  }
  await Future.delayed(const Duration(seconds: 20));
  Timer.periodic(const Duration(minutes: 15), (timer) async {
    await _syncCallLogs();

    service.invoke('syncComplete');
  });
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  await _syncCallLogs();
  return true;
}


