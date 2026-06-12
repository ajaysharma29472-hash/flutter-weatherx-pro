import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../models/air_quality_model.dart';
import '../utils/constants.dart';

class WeatherServiceException implements Exception {
  final String message;
  final int? statusCode;
  WeatherServiceException(this.message, {this.statusCode});

  @override
  String toString() => 'WeatherServiceException: $message (code: $statusCode)';
}

class WeatherService {
  final String apiKey;
  final http.Client _client;

  WeatherService({required this.apiKey, http.Client? client})
      : _client = client ?? http.Client();

  Future<WeatherModel> getCurrentWeather({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/weather'
      '?lat=$lat&lon=$lon&units=$units&appid=$apiKey',
    );
    final response = await _client.get(url);
    _checkResponse(response);
    return WeatherModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<WeatherModel> getCurrentWeatherByCity({
    required String city,
    String units = 'metric',
  }) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/weather'
      '?q=${Uri.encodeComponent(city)}&units=$units&appid=$apiKey',
    );
    final response = await _client.get(url);
    _checkResponse(response);
    return WeatherModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ForecastResponse> getForecast({
    required double lat,
    required double lon,
    String units = 'metric',
  }) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/onecall'
      '?lat=$lat&lon=$lon&units=$units&exclude=minutely,alerts&appid=$apiKey',
    );
    final response = await _client.get(url);
    _checkResponse(response);
    return ForecastResponse.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<AirQualityModel> getAirQuality({
    required double lat,
    required double lon,
  }) async {
    final url = Uri.parse(
      '${AppConstants.openWeatherAqiUrl}?lat=$lat&lon=$lon&appid=$apiKey',
    );
    final response = await _client.get(url);
    _checkResponse(response);
    return AirQualityModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> searchCities(String query) async {
    if (query.length < 2) return [];
    final url = Uri.parse(
      '${AppConstants.openWeatherGeoUrl}/direct'
      '?q=${Uri.encodeComponent(query)}&limit=5&appid=$apiKey',
    );
    final response = await _client.get(url);
    _checkResponse(response);
    final data = jsonDecode(response.body) as List;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  void _checkResponse(http.Response response) {
    if (response.statusCode == 200) return;
    final body = jsonDecode(response.body) as Map<String, dynamic>?;
    final message = body?['message'] as String? ?? 'Unknown error';
    throw WeatherServiceException(message, statusCode: response.statusCode);
  }
}
