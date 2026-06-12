import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/air_quality_model.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  WeatherService? _service;
  String _units = AppConstants.metricUnits;

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _current;
  ForecastResponse? _forecast;
  AirQualityModel? _airQuality;
  String? _errorMessage;
  String _currentCity = AppConstants.defaultCity;
  double _currentLat = AppConstants.defaultLat;
  double _currentLon = AppConstants.defaultLon;
  bool _locationLoading = false;

  WeatherStatus get status => _status;
  WeatherModel? get current => _current;
  ForecastResponse? get forecast => _forecast;
  AirQualityModel? get airQuality => _airQuality;
  String? get errorMessage => _errorMessage;
  String get currentCity => _currentCity;
  double get currentLat => _currentLat;
  double get currentLon => _currentLon;
  bool get locationLoading => _locationLoading;
  bool get isLoading => _status == WeatherStatus.loading;
  bool get hasData => _current != null;

  void setService(String apiKey) {
    _service = WeatherService(apiKey: apiKey);
  }

  void setUnits(String units) {
    _units = units;
  }

  Future<void> loadCurrentLocation() async {
    _locationLoading = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationLoading = false;
        notifyListeners();
        await loadWeatherByCity(AppConstants.defaultCity);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        _locationLoading = false;
        notifyListeners();
        await loadWeatherByCity(AppConstants.defaultCity);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      _currentLat = position.latitude;
      _currentLon = position.longitude;
      _locationLoading = false;
      await loadWeatherByCoords(lat: _currentLat, lon: _currentLon);
    } catch (e) {
      _locationLoading = false;
      notifyListeners();
      await loadWeatherByCity(AppConstants.defaultCity);
    }
  }

  Future<void> loadWeatherByCity(String city) async {
    if (_service == null) return;
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _current = await _service!.getCurrentWeatherByCity(
          city: city, units: _units);
      _currentCity = _current!.cityName;
      _currentLat = _current!.lat;
      _currentLon = _current!.lon;

      await Future.wait([
        _loadForecast(),
        _loadAirQuality(),
      ]);

      _status = WeatherStatus.success;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _status = WeatherStatus.error;
    }
    notifyListeners();
  }

  Future<void> loadWeatherByCoords({
    required double lat,
    required double lon,
  }) async {
    if (_service == null) return;
    _status = WeatherStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _current = await _service!.getCurrentWeather(
          lat: lat, lon: lon, units: _units);
      _currentCity = _current!.cityName;
      _currentLat = lat;
      _currentLon = lon;

      await Future.wait([
        _loadForecast(),
        _loadAirQuality(),
      ]);

      _status = WeatherStatus.success;
    } catch (e) {
      _errorMessage = _friendlyError(e);
      _status = WeatherStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_current != null) {
      await loadWeatherByCoords(lat: _currentLat, lon: _currentLon);
    }
  }

  Future<void> _loadForecast() async {
    _forecast = await _service!.getForecast(
      lat: _currentLat,
      lon: _currentLon,
      units: _units,
    );
  }

  Future<void> _loadAirQuality() async {
    _airQuality = await _service!.getAirQuality(
      lat: _currentLat,
      lon: _currentLon,
    );
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (_service == null) return [];
    try {
      return await _service!.searchCities(query);
    } catch (_) {
      return [];
    }
  }

  String _friendlyError(dynamic e) {
    final msg = e.toString().toLowerCase();
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Invalid API key. Please check your settings.';
    }
    if (msg.contains('404') || msg.contains('city not found')) {
      return 'City not found. Please try another search.';
    }
    if (msg.contains('socket') || msg.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }
    return 'Failed to load weather data. Please try again.';
  }
}
