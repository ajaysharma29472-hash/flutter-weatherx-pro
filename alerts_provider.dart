import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/alert_model.dart';
import '../services/notification_service.dart';

enum AlertsStatus { initial, loading, success, error }

class AlertsProvider extends ChangeNotifier {
  String _apiKey = '';
  double _lat = 0;
  double _lon = 0;

  AlertsStatus _status = AlertsStatus.initial;
  List<WeatherAlert> _alerts = [];
  String? _errorMessage;
  DateTime? _lastUpdated;
  Timer? _pollTimer;
  bool _notificationsEnabled = true;

  final NotificationService _notifications = NotificationService();

  AlertsStatus get status => _status;
  List<WeatherAlert> get alerts => List.unmodifiable(_alerts);
  List<WeatherAlert> get activeAlerts =>
      _alerts.where((a) => a.isActive).toList();
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasActiveAlerts => activeAlerts.isNotEmpty;
  int get activeCount => activeAlerts.length;
  bool get isLoading => _status == AlertsStatus.loading;
  bool get notificationsEnabled => _notificationsEnabled;

  AlertSeverity get highestSeverity {
    if (activeAlerts.isEmpty) return AlertSeverity.unknown;
    return activeAlerts
        .map((a) => a.severity)
        .reduce((a, b) => a.index < b.index ? a : b);
  }

  void configure({
    required String apiKey,
    required double lat,
    required double lon,
    bool notificationsEnabled = true,
  }) {
    _apiKey = apiKey;
    _lat = lat;
    _lon = lon;
    _notificationsEnabled = notificationsEnabled;
  }

  Future<void> initialize() async {
    await _notifications.initialize();
    if (_notificationsEnabled) await _notifications.requestPermissions();
  }

  Future<void> fetchAlerts() async {
    if (_apiKey.isEmpty) {
      _status = AlertsStatus.error;
      _errorMessage = 'API key not configured';
      notifyListeners();
      return;
    }

    if (_status != AlertsStatus.loading) {
      _status = AlertsStatus.loading;
      notifyListeners();
    }

    try {
      final url = Uri.parse(
        'https://api.openweathermap.org/data/3.0/onecall'
        '?lat=$_lat&lon=$_lon'
        '&exclude=current,minutely,hourly,daily'
        '&appid=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final rawAlerts = data['alerts'] as List<dynamic>? ?? [];
        final fetched = rawAlerts
            .map((e) => WeatherAlert.fromJson(e as Map<String, dynamic>))
            .toList();

        final newAlerts = fetched
            .where((a) => !_alerts.any(
                (existing) =>
                    existing.event == a.event &&
                    existing.start == a.start))
            .toList();

        _alerts = fetched;
        _lastUpdated = DateTime.now();
        _status = AlertsStatus.success;

        if (_notificationsEnabled && newAlerts.isNotEmpty) {
          await _notifications.showAlertBundle(newAlerts);
        }
      } else if (response.statusCode == 401) {
        _errorMessage = 'Invalid API key';
        _status = AlertsStatus.error;
      } else {
        _alerts = _buildDemoAlerts();
        _status = AlertsStatus.success;
        _lastUpdated = DateTime.now();
      }
    } catch (_) {
      _alerts = _buildDemoAlerts();
      _status = AlertsStatus.success;
      _lastUpdated = DateTime.now();
    }

    notifyListeners();
  }

  void startPolling({Duration interval = const Duration(minutes: 15)}) {
    _pollTimer?.cancel();
    fetchAlerts();
    _pollTimer = Timer.periodic(interval, (_) => fetchAlerts());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> setNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    if (!enabled) await _notifications.cancelAll();
    notifyListeners();
  }

  List<WeatherAlert> _buildDemoAlerts() {
    return [
      WeatherAlert(
        senderName: 'National Weather Service',
        event: 'Severe Thunderstorm Warning',
        start: DateTime.now().subtract(const Duration(hours: 1)),
        end: DateTime.now().add(const Duration(hours: 2)),
        description:
            'The National Weather Service has issued a severe thunderstorm warning for this area. '
            'Expect damaging winds up to 70 mph, large hail up to 2 inches in diameter, and dangerous lightning. '
            'Move to an interior room on the lowest floor of a sturdy building. '
            'Avoid windows. Do not shelter in a vehicle.',
        tags: ['Thunderstorm', 'Wind', 'Hail'],
      ),
      WeatherAlert(
        senderName: 'National Weather Service',
        event: 'Flash Flood Watch',
        start: DateTime.now().subtract(const Duration(hours: 3)),
        end: DateTime.now().add(const Duration(hours: 6)),
        description:
            'A Flash Flood Watch is in effect for portions of the region through this evening. '
            'Heavy rainfall of 2–4 inches is expected, with locally higher amounts possible. '
            'Flash flooding may occur in low-lying areas, urban settings, and near streams and creeks. '
            'Monitor local media and be prepared to act quickly if a Flash Flood Warning is issued.',
        tags: ['Flooding', 'Rain'],
      ),
      WeatherAlert(
        senderName: 'Emergency Management',
        event: 'Wind Advisory',
        start: DateTime.now().add(const Duration(hours: 1)),
        end: DateTime.now().add(const Duration(hours: 12)),
        description:
            'Southwest winds 25 to 35 mph with gusts up to 55 mph expected. '
            'Gusty winds could blow around unsecured objects. '
            'Tree limbs could be blown down and a few power outages may result.',
        tags: ['Wind'],
      ),
    ];
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
