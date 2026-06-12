import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/search_bar_widget.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Map<String, dynamic>> _results = [];
  bool _searching = false;
  String _query = '';

  Future<void> _search(String query) async {
    setState(() {
      _query = query;
      _searching = true;
    });
    final provider = context.read<WeatherProvider>();
    final results = await provider.searchCities(query);
    if (mounted) {
      setState(() {
        _results = results;
        _searching = false;
      });
    }
  }

  Future<void> _selectCity(Map<String, dynamic> city) async {
    final lat = (city['lat'] as num).toDouble();
    final lon = (city['lon'] as num).toDouble();
    final provider = context.read<WeatherProvider>();
    await provider.loadWeatherByCoords(lat: lat, lon: lon);
    if (mounted) {
      setState(() {
        _results = [];
        _query = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Switched to ${city['name']}, ${city['country']}'),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Find weather for any city',
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    CitySearchBar(
                      onSearch: _search,
                      onLocation: () => weather.loadCurrentLocation(),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            if (_searching)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  ),
                ),
              )
            else if (_results.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Text(
                    '${_results.length} results for "$_query"',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _CityResultTile(
                      city: _results[i],
                      onTap: () => _selectCity(_results[i]),
                    ),
                    childCount: _results.length,
                  ),
                ),
              ),
            ] else if (_query.isEmpty) ...[
              SliverToBoxAdapter(
                child: _buildPopularCities(),
              ),
            ] else
              SliverToBoxAdapter(
                child: _buildEmpty(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCities() {
    final cities = [
      {'name': 'New York', 'country': 'US', 'lat': 40.71, 'lon': -74.01},
      {'name': 'London', 'country': 'GB', 'lat': 51.51, 'lon': -0.13},
      {'name': 'Tokyo', 'country': 'JP', 'lat': 35.69, 'lon': 139.69},
      {'name': 'Paris', 'country': 'FR', 'lat': 48.85, 'lon': 2.35},
      {'name': 'Dubai', 'country': 'AE', 'lat': 25.20, 'lon': 55.27},
      {'name': 'Sydney', 'country': 'AU', 'lat': -33.87, 'lon': 151.21},
      {'name': 'Mumbai', 'country': 'IN', 'lat': 19.08, 'lon': 72.88},
      {'name': 'Chicago', 'country': 'US', 'lat': 41.85, 'lon': -87.65},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Cities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
            ),
            itemCount: cities.length,
            itemBuilder: (_, i) {
              final c = cities[i];
              return GestureDetector(
                onTap: () => _selectCity(c),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.07)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.location_city,
                            color: AppTheme.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c['name'] as String,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              c['country'] as String,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            const Icon(Icons.search_off, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            Text(
              'No cities found for "$_query"',
              style: const TextStyle(
                  fontSize: 16, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try a different spelling or check your API key in Settings',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _CityResultTile extends StatelessWidget {
  final Map<String, dynamic> city;
  final VoidCallback onTap;

  const _CityResultTile({required this.city, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = city['name'] as String? ?? '';
    final country = city['country'] as String? ?? '';
    final state = city['state'] as String?;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppTheme.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.07)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.location_on_outlined,
                  color: AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    [if (state != null) state, country].join(', '),
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
