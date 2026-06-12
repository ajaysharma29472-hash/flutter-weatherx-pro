import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/forecast_model.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class DailyForecastTile extends StatelessWidget {
  final DailyForecast forecast;
  final String units;
  final bool isToday;

  const DailyForecastTile({
    super.key,
    required this.forecast,
    required this.units,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isToday
            ? AppTheme.primary.withOpacity(0.15)
            : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppTheme.primary.withOpacity(0.4)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              isToday ? 'Today' : Helpers.formatShortDay(forecast.dt),
              style: TextStyle(
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                color: isToday ? AppTheme.primary : AppTheme.textPrimary,
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: Helpers.weatherIconUrl(forecast.icon),
            width: 36,
            height: 36,
            errorWidget: (_, __, ___) =>
                const Icon(Icons.cloud, size: 28, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              Helpers.capitalize(forecast.description),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (forecast.pop > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, size: 14, color: AppTheme.accent),
                  const SizedBox(width: 2),
                  Text(
                    '${forecast.pop.toInt()}%',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
            ),
          Text(
            Helpers.formatTemp(forecast.tempMax, units),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            Helpers.formatTemp(forecast.tempMin, units),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class HourlyForecastCard extends StatelessWidget {
  final HourlyForecast forecast;
  final String units;
  final bool isNow;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.units,
    this.isNow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: isNow
            ? AppTheme.primary.withOpacity(0.25)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNow
              ? AppTheme.primary.withOpacity(0.5)
              : Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isNow ? 'Now' : Helpers.formatHour(forecast.dt),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isNow ? FontWeight.w700 : FontWeight.w400,
              color: isNow ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CachedNetworkImage(
            imageUrl: Helpers.weatherIconUrl(forecast.icon),
            width: 36,
            height: 36,
            errorWidget: (_, __, ___) =>
                const Icon(Icons.cloud, size: 28, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            Helpers.formatTemp(forecast.temp, units),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (forecast.pop > 0) ...[
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, size: 10, color: AppTheme.accent),
                Text(
                  '${forecast.pop.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.accent,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
