class AirQualityModel {
  final int aqi;
  final double co;
  final double no;
  final double no2;
  final double o3;
  final double so2;
  final double pm25;
  final double pm10;
  final double nh3;
  final DateTime dt;

  AirQualityModel({
    required this.aqi,
    required this.co,
    required this.no,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm25,
    required this.pm10,
    required this.nh3,
    required this.dt,
  });

  factory AirQualityModel.fromJson(Map<String, dynamic> json) {
    final list = (json['list'] as List).first as Map<String, dynamic>;
    final main = list['main'] as Map<String, dynamic>;
    final components = list['components'] as Map<String, dynamic>;

    return AirQualityModel(
      aqi: main['aqi'] ?? 1,
      co: (components['co'] ?? 0.0).toDouble(),
      no: (components['no'] ?? 0.0).toDouble(),
      no2: (components['no2'] ?? 0.0).toDouble(),
      o3: (components['o3'] ?? 0.0).toDouble(),
      so2: (components['so2'] ?? 0.0).toDouble(),
      pm25: (components['pm2_5'] ?? 0.0).toDouble(),
      pm10: (components['pm10'] ?? 0.0).toDouble(),
      nh3: (components['nh3'] ?? 0.0).toDouble(),
      dt: DateTime.fromMillisecondsSinceEpoch((list['dt'] ?? 0) * 1000),
    );
  }

  String get aqiLabel {
    switch (aqi) {
      case 1: return 'Good';
      case 2: return 'Fair';
      case 3: return 'Moderate';
      case 4: return 'Poor';
      case 5: return 'Very Poor';
      default: return 'Unknown';
    }
  }

  String get healthAdvice {
    switch (aqi) {
      case 1: return 'Air quality is satisfactory, and air pollution poses little or no risk.';
      case 2: return 'Air quality is acceptable. There may be a risk for some people who are unusually sensitive to air pollution.';
      case 3: return 'Members of sensitive groups may experience health effects. The general public is less likely to be affected.';
      case 4: return 'Some members of the general public may experience health effects; members of sensitive groups may experience more serious health effects.';
      case 5: return 'Health alert: The risk of health effects is increased for everyone.';
      default: return 'No data available.';
    }
  }
}
