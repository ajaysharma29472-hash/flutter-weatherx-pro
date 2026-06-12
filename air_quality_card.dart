import 'package:flutter/material.dart';
import '../models/air_quality_model.dart';
import '../utils/theme.dart';

class AirQualityCard extends StatelessWidget {
  final AirQualityModel airQuality;
  final bool compact;

  const AirQualityCard({
    super.key,
    required this.airQuality,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.aqiColor(airQuality.aqi);
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      airQuality.aqiLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Air Quality Index',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                'AQI ${airQuality.aqi}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 16),
            Text(
              airQuality.healthAdvice,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _AqiProgressBar(aqi: airQuality.aqi, color: color),
            const SizedBox(height: 20),
            _PollutantsGrid(airQuality: airQuality),
          ],
        ],
      ),
    );
  }
}

class _AqiProgressBar extends StatelessWidget {
  final int aqi;
  final Color color;

  const _AqiProgressBar({required this.aqi, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Good', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
            Text('Very Poor', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
          ],
        ),
        const SizedBox(height: 6),
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF4CAF50),
                    Color(0xFF8BC34A),
                    Color(0xFFFFC107),
                    Color(0xFFFF7043),
                    Color(0xFFF44336),
                  ],
                ),
              ),
            ),
            Positioned(
              left: ((aqi - 1) / 4 * (MediaQuery.of(context).size.width - 80)).clamp(0.0, double.infinity),
              top: -3,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PollutantsGrid extends StatelessWidget {
  final AirQualityModel airQuality;

  const _PollutantsGrid({required this.airQuality});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('PM2.5', '${airQuality.pm25.toStringAsFixed(1)} µg/m³'),
      ('PM10', '${airQuality.pm10.toStringAsFixed(1)} µg/m³'),
      ('O₃', '${airQuality.o3.toStringAsFixed(1)} µg/m³'),
      ('NO₂', '${airQuality.no2.toStringAsFixed(1)} µg/m³'),
      ('SO₂', '${airQuality.so2.toStringAsFixed(1)} µg/m³'),
      ('CO', '${airQuality.co.toStringAsFixed(1)} µg/m³'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              items[i].$1,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
              ),
            ),
            Text(
              items[i].$2,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
