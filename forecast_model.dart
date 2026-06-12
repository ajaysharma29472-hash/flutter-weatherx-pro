class HourlyForecast {
  final DateTime dt;
  final double temp;
  final double feelsLike;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final String mainCondition;
  final double pop;
  final double? rain;
  final double? snow;
  final int clouds;

  HourlyForecast({
    required this.dt,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.pop,
    this.rain,
    this.snow,
    required this.clouds,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>;

    return HourlyForecast(
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      temp: (main['temp'] ?? 0.0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0.0).toDouble(),
      humidity: main['humidity'] ?? 0,
      pressure: main['pressure'] ?? 0,
      windSpeed: (wind['speed'] ?? 0.0).toDouble(),
      windDeg: wind['deg'] ?? 0,
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '01d',
      mainCondition: weather['main'] ?? '',
      pop: ((json['pop'] ?? 0.0) * 100).toDouble(),
      rain: (json['rain'] as Map<String, dynamic>?)?['3h']?.toDouble(),
      snow: (json['snow'] as Map<String, dynamic>?)?['3h']?.toDouble(),
      clouds: clouds['all'] ?? 0,
    );
  }
}

class DailyForecast {
  final DateTime dt;
  final double tempMin;
  final double tempMax;
  final double tempMorn;
  final double tempDay;
  final double tempEve;
  final double tempNight;
  final int humidity;
  final double windSpeed;
  final int windDeg;
  final String description;
  final String icon;
  final String mainCondition;
  final double pop;
  final double? rain;
  final double? snow;
  final double uvi;
  final DateTime sunrise;
  final DateTime sunset;

  DailyForecast({
    required this.dt,
    required this.tempMin,
    required this.tempMax,
    required this.tempMorn,
    required this.tempDay,
    required this.tempEve,
    required this.tempNight,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.pop,
    this.rain,
    this.snow,
    required this.uvi,
    required this.sunrise,
    required this.sunset,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final temp = json['temp'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;

    return DailyForecast(
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
      tempMin: (temp['min'] ?? 0.0).toDouble(),
      tempMax: (temp['max'] ?? 0.0).toDouble(),
      tempMorn: (temp['morn'] ?? 0.0).toDouble(),
      tempDay: (temp['day'] ?? 0.0).toDouble(),
      tempEve: (temp['eve'] ?? 0.0).toDouble(),
      tempNight: (temp['night'] ?? 0.0).toDouble(),
      humidity: json['humidity'] ?? 0,
      windSpeed: (json['wind_speed'] ?? 0.0).toDouble(),
      windDeg: json['wind_deg'] ?? 0,
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '01d',
      mainCondition: weather['main'] ?? '',
      pop: ((json['pop'] ?? 0.0) * 100).toDouble(),
      rain: json['rain']?.toDouble(),
      snow: json['snow']?.toDouble(),
      uvi: (json['uvi'] ?? 0.0).toDouble(),
      sunrise: DateTime.fromMillisecondsSinceEpoch((json['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((json['sunset'] ?? 0) * 1000),
    );
  }
}

class ForecastResponse {
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final double lat;
  final double lon;
  final String timezone;

  ForecastResponse({
    required this.hourly,
    required this.daily,
    required this.lat,
    required this.lon,
    required this.timezone,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    return ForecastResponse(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
      timezone: json['timezone'] ?? '',
      hourly: (json['hourly'] as List? ?? [])
          .map((h) => HourlyForecast.fromJson(h as Map<String, dynamic>))
          .take(24)
          .toList(),
      daily: (json['daily'] as List? ?? [])
          .map((d) => DailyForecast.fromJson(d as Map<String, dynamic>))
          .take(7)
          .toList(),
    );
  }
}
