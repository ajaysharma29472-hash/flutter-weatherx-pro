import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';
import '../utils/helpers.dart';

enum WeatherLayer { precipitation, clouds, wind, temperature, pressure }

extension WeatherLayerExt on WeatherLayer {
  String get label {
    switch (this) {
      case WeatherLayer.precipitation: return 'Rain';
      case WeatherLayer.clouds: return 'Clouds';
      case WeatherLayer.wind: return 'Wind';
      case WeatherLayer.temperature: return 'Temp';
      case WeatherLayer.pressure: return 'Pressure';
    }
  }

  IconData get icon {
    switch (this) {
      case WeatherLayer.precipitation: return Icons.water_drop_outlined;
      case WeatherLayer.clouds: return Icons.cloud_outlined;
      case WeatherLayer.wind: return Icons.air;
      case WeatherLayer.temperature: return Icons.thermostat_outlined;
      case WeatherLayer.pressure: return Icons.compress_outlined;
    }
  }

  String tileId(String apiKey) {
    switch (this) {
      case WeatherLayer.precipitation: return 'precipitation_new';
      case WeatherLayer.clouds: return 'clouds_new';
      case WeatherLayer.wind: return 'wind_new';
      case WeatherLayer.temperature: return 'temp_new';
      case WeatherLayer.pressure: return 'pressure_new';
    }
  }

  Color get color {
    switch (this) {
      case WeatherLayer.precipitation: return const Color(0xFF29B6F6);
      case WeatherLayer.clouds: return const Color(0xFF90A4AE);
      case WeatherLayer.wind: return const Color(0xFF66BB6A);
      case WeatherLayer.temperature: return const Color(0xFFFF7043);
      case WeatherLayer.pressure: return const Color(0xFFAB47BC);
    }
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  WeatherLayer _activeLayer = WeatherLayer.precipitation;
  late MapController _mapController;
  double _opacity = 0.7;
  bool _showLegend = true;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String _tileUrl(String apiKey) {
    final layerId = _activeLayer.tileId(apiKey);
    return 'https://tile.openweathermap.org/map/$layerId/{z}/{x}/{y}.png?appid=$apiKey';
  }

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();
    final settings = context.watch<SettingsProvider>();
    final apiKey = settings.apiKey;

    final center = LatLng(weather.currentLat, weather.currentLon);

    return Container(
      color: AppTheme.bgDark,
      child: SafeArea(
        child: Stack(
          children: [
            _buildMap(center, apiKey),
            _buildTopBar(weather),
            _buildLayerSelector(),
            if (_showLegend) _buildLegend(),
            _buildControls(center),
          ],
        ),
      ),
    );
  }

  Widget _buildMap(LatLng center, String apiKey) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 6.0,
        minZoom: 2.0,
        maxZoom: 12.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.weatherxpro.app',
          tileBuilder: _darkTileBuilder,
        ),
        if (apiKey.isNotEmpty)
          TileLayer(
            urlTemplate: _tileUrl(apiKey),
            userAgentPackageName: 'com.weatherxpro.app',
            opacity: _opacity,
          ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 48,
              height: 56,
              child: _LocationMarker(
                cityName: context.read<WeatherProvider>().currentCity,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _darkTileBuilder(BuildContext context, Widget tile, TileImage tileImage) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix([
        -0.9, 0, 0, 0, 255,
        0, -0.9, 0, 0, 255,
        0, 0, -0.9, 0, 255,
        0, 0, 0, 1, 0,
      ]),
      child: tile,
    );
  }

  Widget _buildTopBar(WeatherProvider weather) {
    return Positioned(
      top: 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cardDark.withOpacity(0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.map_outlined,
                      color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weather Map',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined,
                                size: 12, color: AppTheme.accent),
                            const SizedBox(width: 2),
                            Text(
                              weather.currentCity,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _activeLayer.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _activeLayer.color.withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_activeLayer.icon,
                            size: 13, color: _activeLayer.color),
                        const SizedBox(width: 4),
                        Text(
                          _activeLayer.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _activeLayer.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayerSelector() {
    return Positioned(
      bottom: 140,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withOpacity(0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: WeatherLayer.values
              .map((layer) => _LayerChip(
                    layer: layer,
                    selected: _activeLayer == layer,
                    onTap: () => setState(() => _activeLayer = layer),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Positioned(
      bottom: 220,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardDark.withOpacity(0.92),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(_activeLayer.icon,
                    size: 13, color: _activeLayer.color),
                const SizedBox(width: 4),
                Text(
                  _activeLayer.label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _activeLayer.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ..._legendItems(_activeLayer).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: item.$2,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.$1,
                      style: const TextStyle(
                          fontSize: 10, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Column(
              children: [
                const Text('Opacity',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textMuted)),
                SizedBox(
                  width: 80,
                  child: Slider(
                    value: _opacity,
                    min: 0.1,
                    max: 1.0,
                    divisions: 9,
                    activeColor: _activeLayer.color,
                    inactiveColor: Colors.white.withOpacity(0.1),
                    onChanged: (v) => setState(() => _opacity = v),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(LatLng center) {
    return Positioned(
      bottom: 220,
      left: 16,
      child: Column(
        children: [
          _MapButton(
            icon: Icons.add,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom + 1,
            ),
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: Icons.remove,
            onTap: () => _mapController.move(
              _mapController.camera.center,
              _mapController.camera.zoom - 1,
            ),
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: Icons.my_location,
            onTap: () => _mapController.move(center, 6.0),
            color: AppTheme.primary,
          ),
          const SizedBox(height: 8),
          _MapButton(
            icon: _showLegend ? Icons.layers : Icons.layers_outlined,
            onTap: () => setState(() => _showLegend = !_showLegend),
          ),
        ],
      ),
    );
  }

  List<(String, Color)> _legendItems(WeatherLayer layer) {
    switch (layer) {
      case WeatherLayer.precipitation:
        return [
          ('0 mm/h', const Color(0xFF4FC3F7)),
          ('0.1 mm/h', const Color(0xFF29B6F6)),
          ('0.5 mm/h', const Color(0xFF0288D1)),
          ('1 mm/h', const Color(0xFF01579B)),
          ('4+ mm/h', const Color(0xFF1A237E)),
        ];
      case WeatherLayer.clouds:
        return [
          ('0%', const Color(0xFFFFFFFF)),
          ('25%', const Color(0xFFB0BEC5)),
          ('50%', const Color(0xFF78909C)),
          ('75%', const Color(0xFF455A64)),
          ('100%', const Color(0xFF263238)),
        ];
      case WeatherLayer.wind:
        return [
          ('< 5 m/s', const Color(0xFF81C784)),
          ('5–15 m/s', const Color(0xFFFFD54F)),
          ('15–25 m/s', const Color(0xFFFF8A65)),
          ('25–35 m/s', const Color(0xFFE53935)),
          ('> 35 m/s', const Color(0xFF880E4F)),
        ];
      case WeatherLayer.temperature:
        return [
          ('< -20°C', const Color(0xFF1565C0)),
          ('-10°C', const Color(0xFF29B6F6)),
          ('0°C', const Color(0xFFB3E5FC)),
          ('15°C', const Color(0xFF66BB6A)),
          ('30°C+', const Color(0xFFE53935)),
        ];
      case WeatherLayer.pressure:
        return [
          ('< 980 hPa', const Color(0xFFCE93D8)),
          ('995 hPa', const Color(0xFF9C27B0)),
          ('1013 hPa', const Color(0xFF4A148C)),
          ('1025 hPa', const Color(0xFF311B92)),
          ('> 1040 hPa', const Color(0xFF1A237E)),
        ];
    }
  }
}

class _LayerChip extends StatelessWidget {
  final WeatherLayer layer;
  final bool selected;
  final VoidCallback onTap;

  const _LayerChip({
    required this.layer,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? layer.color.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? layer.color.withOpacity(0.6)
                : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              layer.icon,
              size: 20,
              color: selected ? layer.color : AppTheme.textMuted,
            ),
            const SizedBox(height: 4),
            Text(
              layer.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? layer.color : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _MapButton({
    required this.icon,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color != null
              ? color!.withOpacity(0.2)
              : AppTheme.cardDark.withOpacity(0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color != null
                ? color!.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: color ?? AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _LocationMarker extends StatefulWidget {
  final String cityName;

  const _LocationMarker({required this.cityName});

  @override
  State<_LocationMarker> createState() => _LocationMarkerState();
}

class _LocationMarkerState extends State<_LocationMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulse = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.cardDark.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
          ),
          child: Text(
            widget.cityName,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulse,
              builder: (_, __) => Container(
                width: 24 * _pulse.value,
                height: 24 * _pulse.value,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
