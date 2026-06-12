import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/weather_model.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String units;
  final VoidCallback? onTap;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.units,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weather.cityName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${weather.country} · ${Helpers.formatDate(weather.dt)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                CachedNetworkImage(
                  imageUrl: Helpers.weatherIconUrl(weather.icon, large: true),
                  width: 72,
                  height: 72,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.cloud, size: 60, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Helpers.formatTemp(weather.temp, units),
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        Helpers.capitalize(weather.description),
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        'H:${Helpers.formatTemp(weather.tempMax, units)} L:${Helpers.formatTemp(weather.tempMin, units)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InfoChip(
                  icon: Icons.water_drop_outlined,
                  label: Helpers.humidity(weather.humidity),
                  title: 'Humidity',
                ),
                _InfoChip(
                  icon: Icons.air,
                  label: Helpers.windSpeed(weather.windSpeed, units),
                  title: 'Wind',
                ),
                _InfoChip(
                  icon: Icons.visibility_outlined,
                  label: Helpers.visibility(weather.visibility),
                  title: 'Visibility',
                ),
                _InfoChip(
                  icon: Icons.compress,
                  label: Helpers.pressure(weather.pressure),
                  title: 'Pressure',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String title;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppTheme.accent),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
