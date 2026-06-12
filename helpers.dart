import 'package:intl/intl.dart';

class Helpers {
  static String formatTemp(double temp, String units) {
    final rounded = temp.round();
    return units == 'metric' ? '$rounded°C' : '$rounded°F';
  }

  static String formatDate(DateTime dt) {
    return DateFormat('EEEE, MMM d').format(dt);
  }

  static String formatTime(DateTime dt) {
    return DateFormat('h:mm a').format(dt);
  }

  static String formatShortDay(DateTime dt) {
    return DateFormat('EEE').format(dt);
  }

  static String formatShortDate(DateTime dt) {
    return DateFormat('MMM d').format(dt);
  }

  static String formatHour(DateTime dt) {
    return DateFormat('ha').format(dt);
  }

  static String windDirection(int deg) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    return directions[((deg + 22.5) / 45).floor() % 8];
  }

  static String windSpeed(double speed, String units) {
    return units == 'metric'
        ? '${speed.toStringAsFixed(1)} m/s'
        : '${speed.toStringAsFixed(1)} mph';
  }

  static String visibility(int vis) {
    final km = vis / 1000;
    return '${km.toStringAsFixed(1)} km';
  }

  static String pressure(int p) => '$p hPa';

  static String humidity(int h) => '$h%';

  static String uvIndex(double uvi) {
    if (uvi <= 2) return 'Low';
    if (uvi <= 5) return 'Moderate';
    if (uvi <= 7) return 'High';
    if (uvi <= 10) return 'Very High';
    return 'Extreme';
  }

  static String weatherIconUrl(String icon, {bool large = false}) {
    final size = large ? '@4x' : '@2x';
    return 'https://openweathermap.org/img/wn/$icon$size.png';
  }

  static DateTime fromUnixTimestamp(int ts) {
    return DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  static String feelsLikeDescription(double actual, double feelsLike) {
    final diff = feelsLike - actual;
    if (diff > 3) return 'Feels warmer than actual';
    if (diff < -3) return 'Feels colder than actual';
    return 'Feels about right';
  }
}
