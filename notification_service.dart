import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/alert_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  final Set<String> _sentIds = {};

  Future<void> initialize() async {
    if (_initialized) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showAlertNotification(WeatherAlert alert) async {
    if (!_initialized) return;

    final alertId = '${alert.event}_${alert.start.millisecondsSinceEpoch}';
    if (_sentIds.contains(alertId)) return;
    _sentIds.add(alertId);

    final priority = _androidPriority(alert.severity);
    final importance = _androidImportance(alert.severity);

    final androidDetails = AndroidNotificationDetails(
      'weather_alerts',
      'Weather Alerts',
      channelDescription: 'Severe weather alerts for your location',
      importance: importance,
      priority: priority,
      color: _severityAndroidColor(alert.severity),
      styleInformation: BigTextStyleInformation(
        alert.shortDescription,
        htmlFormatBigText: false,
        contentTitle: alert.event,
        summaryText: alert.senderName,
      ),
      category: AndroidNotificationCategory.alarm,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      alertId.hashCode.abs() % 100000,
      '⚠️ ${alert.event}',
      alert.shortDescription,
      details,
    );
  }

  Future<void> showAlertBundle(List<WeatherAlert> alerts) async {
    if (!_initialized || alerts.isEmpty) return;
    for (final alert in alerts) {
      await showAlertNotification(alert);
    }
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    _sentIds.clear();
  }

  AndroidNotificationPriority _androidPriority(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.extreme:
        return AndroidNotificationPriority.maximumPriority;
      case AlertSeverity.severe:
        return AndroidNotificationPriority.highPriority;
      default:
        return AndroidNotificationPriority.defaultPriority;
    }
  }

  Importance _androidImportance(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.extreme:
        return Importance.max;
      case AlertSeverity.severe:
        return Importance.high;
      default:
        return Importance.defaultImportance;
    }
  }

  int _severityAndroidColor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.extreme:
        return 0xFFF44336;
      case AlertSeverity.severe:
        return 0xFFFF7043;
      case AlertSeverity.moderate:
        return 0xFFFFC107;
      default:
        return 0xFF1A73E8;
    }
  }
}
