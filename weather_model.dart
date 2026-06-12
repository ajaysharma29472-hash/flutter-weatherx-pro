class WeatherModel {
  final int id;
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final int pressure;
  final int visibility;
  final double windSpeed;
  final int windDeg;
  final double? windGust;
  final int clouds;
  final String description;
  final String icon;
  final String mainCondition;
  final DateTime sunrise;
  final DateTime sunset;
  final DateTime dt;
  final double? uvi;
  final double? dewPoint;
  final int? pop;

  WeatherModel({
    required this.id,
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.pressure,
    required this.visibility,
    required this.windSpeed,
    required this.windDeg,
    this.windGust,
    required this.clouds,
    required this.description,
    required this.icon,
    required this.mainCondition,
    required this.sunrise,
    required this.sunset,
    required this.dt,
    this.uvi,
    this.dewPoint,
    this.pop,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final wind = json['wind'] as Map<String, dynamic>;
    final sys = json['sys'] as Map<String, dynamic>;
    final weather = (json['weather'] as List).first as Map<String, dynamic>;
    final clouds = json['clouds'] as Map<String, dynamic>;

    return WeatherModel(
      id: json['id'] ?? 0,
      cityName: json['name'] ?? '',
      country: sys['country'] ?? '',
      lat: (json['coord']?['lat'] ?? 0.0).toDouble(),
      lon: (json['coord']?['lon'] ?? 0.0).toDouble(),
      temp: (main['temp'] ?? 0.0).toDouble(),
      feelsLike: (main['feels_like'] ?? 0.0).toDouble(),
      tempMin: (main['temp_min'] ?? 0.0).toDouble(),
      tempMax: (main['temp_max'] ?? 0.0).toDouble(),
      humidity: main['humidity'] ?? 0,
      pressure: main['pressure'] ?? 0,
      visibility: json['visibility'] ?? 0,
      windSpeed: (wind['speed'] ?? 0.0).toDouble(),
      windDeg: wind['deg'] ?? 0,
      windGust: wind['gust']?.toDouble(),
      clouds: clouds['all'] ?? 0,
      description: weather['description'] ?? '',
      icon: weather['icon'] ?? '01d',
      mainCondition: weather['main'] ?? '',
      sunrise: DateTime.fromMillisecondsSinceEpoch((sys['sunrise'] ?? 0) * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch((sys['sunset'] ?? 0) * 1000),
      dt: DateTime.fromMillisecondsSinceEpoch((json['dt'] ?? 0) * 1000),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cityName': cityName,
        'country': country,
        'lat': lat,
        'lon': lon,
        'temp': temp,
        'feelsLike': feelsLike,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'humidity': humidity,
        'pressure': pressure,
        'visibility': visibility,
        'windSpeed': windSpeed,
        'windDeg': windDeg,
        'windGust': windGust,
        'clouds': clouds,
        'description': description,
        'icon': icon,
        'mainCondition': mainCondition,
        'sunrise': sunrise.millisecondsSinceEpoch ~/ 1000,
        'sunset': sunset.millisecondsSinceEpoch ~/ 1000,
        'dt': dt.millisecondsSinceEpoch ~/ 1000,
        'uvi': uvi,
        'dewPoint': dewPoint,
        'pop': pop,
      };
}
