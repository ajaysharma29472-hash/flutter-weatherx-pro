import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/forecast_tile.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(weather),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    if (weather.forecast != null)
                      _HourlyTab(
                        hourly: weather.forecast!.hourly,
                        units: settings.units,
                      )
                    else
                      const Center(
                        child: Text('No forecast data',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                    if (weather.forecast != null)
                      _DailyTab(
                        daily: weather.forecast!.daily,
                        units: settings.units,
                      )
                    else
                      const Center(
                        child: Text('No forecast data',
                            style: TextStyle(color: AppTheme.textSecondary)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WeatherProvider weather) {
    return Padding(
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
                  'Forecast',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  weather.currentCity,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        labelStyle: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 14),
        unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins', fontWeight: FontWeight.w400, fontSize: 14),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textMuted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'Hourly'),
          Tab(text: '7-Day'),
        ],
      ),
    );
  }
}

class _HourlyTab extends StatelessWidget {
  final List hourly;
  final String units;

  const _HourlyTab({required this.hourly, required this.units});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTempChart(context),
        const SizedBox(height: 16),
        ...List.generate(
          hourly.length,
          (i) => _HourlyDetailTile(
            forecast: hourly[i],
            units: units,
          ),
        ),
      ],
    );
  }

  Widget _buildTempChart(BuildContext context) {
    final spots = List.generate(
      hourly.length > 12 ? 12 : hourly.length,
      (i) => FlSpot(i.toDouble(), hourly[i].temp),
    );

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 5,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  Helpers.formatTemp(v, units),
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textMuted),
                ),
                reservedSize: 44,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 3,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= hourly.length) return const SizedBox();
                  return Text(
                    Helpers.formatHour(hourly[i].dt),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textMuted),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppTheme.primary,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppTheme.primary.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HourlyDetailTile extends StatelessWidget {
  final dynamic forecast;
  final String units;

  const _HourlyDetailTile({required this.forecast, required this.units});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              Helpers.formatHour(forecast.dt),
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Helpers.capitalize(forecast.description),
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
          if (forecast.pop > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Row(
                children: [
                  const Icon(Icons.water_drop, size: 13, color: AppTheme.accent),
                  Text(
                    '${forecast.pop.toInt()}%',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.accent),
                  ),
                ],
              ),
            ),
          Text(
            Helpers.formatTemp(forecast.temp, units),
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary),
          ),
          const SizedBox(width: 8),
          Row(
            children: [
              const Icon(Icons.air, size: 13, color: AppTheme.textMuted),
              Text(
                Helpers.windSpeed(forecast.windSpeed, units),
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyTab extends StatelessWidget {
  final List daily;
  final String units;

  const _DailyTab({required this.daily, required this.units});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTempRangeChart(context),
        const SizedBox(height: 16),
        ...List.generate(
          daily.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: DailyForecastTile(
              forecast: daily[i],
              units: units,
              isToday: i == 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTempRangeChart(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) => Text(
                  Helpers.formatTemp(v, units),
                  style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                ),
                reservedSize: 44,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i >= daily.length) return const SizedBox();
                  return Text(
                    i == 0 ? 'Today' : Helpers.formatShortDay(daily[i].dt),
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                  daily.length, (i) => FlSpot(i.toDouble(), daily[i].tempMax)),
              isCurved: true,
              color: const Color(0xFFFFB300),
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: List.generate(
                  daily.length, (i) => FlSpot(i.toDouble(), daily[i].tempMin)),
              isCurved: true,
              color: AppTheme.accent,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              dashArray: [6, 3],
            ),
          ],
        ),
      ),
    );
  }
}
