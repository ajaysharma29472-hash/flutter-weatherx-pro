import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../models/user_model.dart';
import '../utils/theme.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favs = context.watch<FavoritesProvider>();
    final weather = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            'Your saved locations',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${favs.count} saved',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (favs.favorites.isEmpty)
              const SliverFillRemaining(child: _EmptyFavorites())
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: AppTheme.textMuted),
                      const SizedBox(width: 6),
                      const Text(
                        'Tap a city to view its weather',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) {
                      final city = favs.favorites[i];
                      final isCurrent = city.cityName == weather.currentCity;
                      return _FavoriteCityCard(
                        city: city,
                        isCurrent: isCurrent,
                        onTap: () async {
                          await weather.loadWeatherByCoords(
                            lat: city.lat,
                            lon: city.lon,
                          );
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Switched to ${city.cityName}'),
                                backgroundColor: AppTheme.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        },
                        onRemove: () => favs.removeFavorite(
                            city.cityName, city.country),
                      );
                    },
                    childCount: favs.favorites.length,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FavoriteCityCard extends StatelessWidget {
  final FavoriteCity city;
  final bool isCurrent;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCityCard({
    required this.city,
    required this.isCurrent,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('${city.cityName}_${city.country}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline, color: AppTheme.error, size: 24),
            SizedBox(height: 4),
            Text('Remove',
                style: TextStyle(color: AppTheme.error, fontSize: 12)),
          ],
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: isCurrent
                ? LinearGradient(
                    colors: [
                      AppTheme.primary.withOpacity(0.2),
                      AppTheme.primary.withOpacity(0.05),
                    ],
                  )
                : AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isCurrent
                  ? AppTheme.primary.withOpacity(0.4)
                  : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppTheme.primary.withOpacity(0.2)
                      : Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isCurrent ? Icons.my_location : Icons.location_on_outlined,
                  color: isCurrent ? AppTheme.primary : AppTheme.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          city.cityName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Current',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      city.country,
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
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.cardDark,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 48,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No favorites yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the heart icon on the home screen to save cities here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
