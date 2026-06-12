import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/air_quality_card.dart';
import '../utils/theme.dart';

class AirQualityScreen extends StatelessWidget {
  const AirQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final aqi = weather.airQuality;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: AppTheme.textPrimary, size: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Air Quality',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              weather.currentCity,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (aqi == null)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.air, size: 64, color: AppTheme.textMuted),
                        SizedBox(height: 16),
                        Text(
                          'Air quality data not available',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                    child: AirQualityCard(airQuality: aqi, compact: false),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildInfoCards(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCards() {
    final items = [
      _InfoItem(
        title: 'PM2.5',
        subtitle: 'Fine Particulate Matter',
        description:
            'Particles 2.5 micrometers and smaller. Can penetrate deep into lungs and bloodstream.',
        icon: Icons.blur_circular_outlined,
        color: const Color(0xFFE53935),
      ),
      _InfoItem(
        title: 'PM10',
        subtitle: 'Coarse Particulate Matter',
        description:
            'Particles 10 micrometers and smaller. Can cause respiratory irritation.',
        icon: Icons.blur_on_outlined,
        color: const Color(0xFFFF7043),
      ),
      _InfoItem(
        title: 'O₃',
        subtitle: 'Ground-Level Ozone',
        description:
            'Formed by chemical reactions in sunlight. Causes chest pain and coughing.',
        icon: Icons.wb_sunny_outlined,
        color: const Color(0xFFFFC107),
      ),
      _InfoItem(
        title: 'NO₂',
        subtitle: 'Nitrogen Dioxide',
        description:
            'Emitted by vehicles and power plants. Irritates airways and worsens asthma.',
        icon: Icons.factory_outlined,
        color: const Color(0xFF8BC34A),
      ),
      _InfoItem(
        title: 'SO₂',
        subtitle: 'Sulfur Dioxide',
        description:
            'Released by burning fossil fuels. Causes breathing problems and acid rain.',
        icon: Icons.cloud_queue_outlined,
        color: const Color(0xFF29B6F6),
      ),
      _InfoItem(
        title: 'CO',
        subtitle: 'Carbon Monoxide',
        description:
            'Produced by incomplete combustion. Reduces oxygen delivery to body organs.',
        icon: Icons.car_repair_outlined,
        color: const Color(0xFFAB47BC),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pollutant Guide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _PollutantCard(item: item)),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;

  _InfoItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _PollutantCard extends StatefulWidget {
  final _InfoItem item;
  const _PollutantCard({required this.item});

  @override
  State<_PollutantCard> createState() => _PollutantCardState();
}

class _PollutantCardState extends State<_PollutantCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.item.color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: widget.item.color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.item.icon,
                      color: widget.item.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: widget.item.color,
                        ),
                      ),
                      Text(
                        widget.item.subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              Text(
                widget.item.description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
