class AppConstants {
  static const String appName = 'WeatherX Pro';
  static const String openWeatherBaseUrl = 'https://api.openweathermap.org/data/2.5';
  static const String openWeatherGeoUrl = 'https://api.openweathermap.org/geo/1.0';
  static const String openWeatherAqiUrl = 'https://api.openweathermap.org/data/2.5/air_pollution';
  static const String openWeatherIconUrl = 'https://openweathermap.org/img/wn';

  static const String apiKeyPref = 'owm_api_key';
  static const String unitsPref = 'units';
  static const String themePref = 'theme_mode';
  static const String notifPref = 'notifications_enabled';
  static const String favoritesKey = 'favorites';
  static const String userKey = 'user_data';

  static const String metricUnits = 'metric';
  static const String imperialUnits = 'imperial';

  static const int forecastDays = 7;
  static const double defaultLat = 40.7128;
  static const double defaultLon = -74.0060;
  static const String defaultCity = 'New York';
}
