import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/alerts_provider.dart';
import '../models/user_model.dart';
import '../widgets/weather_card.dart';
import '../widgets/forecast_tile.dart';
import '../widgets/air_quality_card.dart';
import '../widgets/loading_shimmer.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';
import 'search_screen.dart';
import 'forecast_screen.dart';
import 'air_quality_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'map_screen.dart';
import 'alerts_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    _WeatherPage(),
    SearchScreen(),
    MapScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.cloud_outlined,
                activeIcon: Icons.cloud,
                label: 'Weather',
                selected: _selectedIndex == 0,
                onTap: () => setState(() => _selectedIndex = 0),
              ),
              _NavItem(
                icon: Icons.search_outlined,
                activeIcon: Icons.search,
                label: 'Search',
                selected: _selectedIndex == 1,
                onTap: () => setState(() => _selectedIndex = 1),
              ),
              _NavItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: 'Map',
                selected: _selectedIndex == 2,
                onTap: () => setState(() => _selectedIndex = 2),
              ),
              _NavItem(
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: 'Favorites',
                selected: _selectedIndex == 3,
                onTap: () => setState(() => _selectedIndex = 3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Profile',
                selected: _selectedIndex == 4,
                onTap: () => setState(() => _selectedIndex = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? activeIcon : icon,
              color: selected ? AppTheme.primary : AppTheme.textMuted,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? AppTheme.primary : AppTheme.textMuted,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherPage extends StatefulWidget {
  const _WeatherPage();

  @override
  State<_WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<_WeatherPage> {
  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();
    final favs = context.watch<FavoritesProvider>();
    final alerts = context.watch<AlertsProvider>();

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.primary,
          backgroundColor: AppTheme.cardDark,
          onRefresh: () => weather.refresh(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildTopBar(weather, settings, favs)),
              if (alerts.hasActiveAlerts)
                SliverToBoxAdapter(
                  child: _AlertBanner(
                    count: alerts.activeCount,
                    severity: alerts.highestSeverity,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AlertsScreen()),
                    ),
                  ),
                ),
              if (weather.isLoading && !weather.hasData)
                const SliverToBoxAdapter(child: LoadingShimmer())
              else if (weather.status == WeatherStatus.error && !weather.hasData)
                SliverToBoxAdapter(child: _buildError(weather))
              else if (weather.hasData) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: WeatherCard(
                      weather: weather.current!,
                      units: settings.units,
                    ),
                  ),
                ),
                if (weather.airQuality != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AirQualityScreen(),
                            )),
                        child: AirQualityCard(
                          airQuality: weather.airQuality!,
                          compact: true,
                        ),
                      ),
                    ),
                  ),
                if (weather.forecast != null) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      'Hourly Forecast',
                      onMore: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForecastScreen(),
                          )),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 142,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: weather.forecast!.hourly.length,
                        itemBuilder: (_, i) => HourlyForecastCard(
                          forecast: weather.forecast!.hourly[i],
                          units: settings.units,
                          isNow: i == 0,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSectionHeader(
                      '7-Day Forecast',
                      onMore: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ForecastScreen(),
                          )),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => DailyForecastTile(
                          forecast: weather.forecast!.daily[i],
                          units: settings.units,
                          isToday: i == 0,
                        ),
                        childCount: weather.forecast!.daily.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildSunriseSunset(weather, settings),
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      WeatherProvider weather, SettingsProvider settings, FavoritesProvider favs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppTheme.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      weather.currentCity,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  weather.current != null
                      ? Helpers.formatDate(weather.current!.dt)
                      : 'Loading...',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          if (weather.current != null)
            IconButton(
              onPressed: () async {
                final city = weather.current!;
                await favs.toggleFavorite(FavoriteCity(
                  cityName: city.cityName,
                  country: city.country,
                  lat: city.lat,
                  lon: city.lon,
                ));
              },
              icon: Icon(
                favs.isFavorite(
                        weather.current?.cityName ?? '',
                        weather.current?.country ?? '')
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: favs.isFavorite(
                        weather.current?.cityName ?? '',
                        weather.current?.country ?? '')
                    ? Colors.redAccent
                    : AppTheme.textMuted,
              ),
            ),
          IconButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildError(WeatherProvider weather) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Icon(Icons.cloud_off_rounded, size: 80, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              weather.errorMessage ?? 'Failed to load weather',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: weather.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: const Text(
                'See all',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSunriseSunset(WeatherProvider weather, SettingsProvider settings) {
    final w = weather.current!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SunItem(
              icon: Icons.wb_sunny_outlined,
              label: 'Sunrise',
              value: Helpers.formatTime(w.sunrise),
              color: const Color(0xFFFFB300),
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
            _SunItem(
              icon: Icons.nights_stay_outlined,
              label: 'Sunset',
              value: Helpers.formatTime(w.sunset),
              color: const Color(0xFFFF7043),
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
            _SunItem(
              icon: Icons.thermostat_outlined,
              label: 'Feels Like',
              value: Helpers.formatTemp(w.feelsLike, settings.units),
              color: AppTheme.accent,
            ),
            Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
            _SunItem(
              icon: Icons.compress_outlined,
              label: 'Pressure',
              value: Helpers.pressure(w.pressure),
              color: const Color(0xFFAB47BC),
            ),
          ],
        ),
      ),
    );
  }
}

class _SunItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SunItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final int count;
  final AlertSeverity severity;
  final VoidCallback onTap;

  const _AlertBanner({
    required this.count,
    required this.severity,
    required this.onTap,
  });

  Color get _color {
    switch (severity) {
      case AlertSeverity.extreme:
        return const Color(0xFFF44336);
      case AlertSeverity.severe:
        return const Color(0xFFFF7043);
      case AlertSeverity.moderate:
        return const Color(0xFFFFC107);
      case AlertSeverity.minor:
        return const Color(0xFF29B6F6);
      default:
        return AppTheme.textSecondary;
    }
  }

  String get _label {
    switch (severity) {
      case AlertSeverity.extreme:
        return 'EXTREME';
      case AlertSeverity.severe:
        return 'SEVERE';
      case AlertSeverity.moderate:
        return 'MODERATE';
      case AlertSeverity.minor:
        return 'MINOR';
      default:
        return 'ALERT';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: _color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                color: _color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: _color,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$count weather ${count == 1 ? 'alert' : 'alerts'} active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to view details and safety information',
                    style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: _color, size: 20),
          ],
        ),
      ),
    );
  }
}
