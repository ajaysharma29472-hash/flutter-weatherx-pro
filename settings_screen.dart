import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final weather = context.watch<WeatherProvider>();

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
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildApiKeySection(context, settings, weather),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Units & Display',
                      children: [
                        _buildUnitsToggle(settings),
                        _buildDivider(),
                        _buildThemeToggle(context, settings),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Notifications',
                      children: [
                        _buildSwitchTile(
                          icon: Icons.notifications_outlined,
                          label: 'Weather Alerts',
                          subtitle: 'Get notified about severe weather',
                          value: settings.notificationsEnabled,
                          onChanged: settings.setNotifications,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'Location',
                      children: [
                        _buildSwitchTile(
                          icon: Icons.location_on_outlined,
                          label: 'Use My Location',
                          subtitle:
                              'Automatically detect your current location',
                          value: settings.locationEnabled,
                          onChanged: (v) async {
                            await settings.setLocation(v);
                            if (v) {
                              await weather.loadCurrentLocation();
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      title: 'About',
                      children: [
                        _buildInfoTile(
                          icon: Icons.info_outline,
                          label: 'Version',
                          value: '1.0.0',
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          icon: Icons.cloud_outlined,
                          label: 'Data Source',
                          value: 'OpenWeatherMap',
                        ),
                        _buildDivider(),
                        _buildInfoTile(
                          icon: Icons.code_outlined,
                          label: 'Framework',
                          value: 'Flutter',
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApiKeySection(
      BuildContext context, SettingsProvider settings, WeatherProvider weather) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.apiKey.isEmpty
            ? AppTheme.warning.withOpacity(0.08)
            : AppTheme.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: settings.apiKey.isEmpty
              ? AppTheme.warning.withOpacity(0.3)
              : AppTheme.success.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                settings.apiKey.isEmpty
                    ? Icons.warning_amber_outlined
                    : Icons.check_circle_outline,
                color: settings.apiKey.isEmpty
                    ? AppTheme.warning
                    : AppTheme.success,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'OpenWeatherMap API Key',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: settings.apiKey.isEmpty
                      ? AppTheme.warning
                      : AppTheme.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            settings.apiKey.isEmpty
                ? 'Enter your API key to enable live weather data. Get a free key at openweathermap.org'
                : 'API key configured. Weather data is live.',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    settings.apiKey.isEmpty
                        ? 'Not configured'
                        : '${settings.apiKey.substring(0, 8)}••••••••',
                    style: TextStyle(
                      fontSize: 14,
                      color: settings.apiKey.isEmpty
                          ? AppTheme.textMuted
                          : AppTheme.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showApiKeyDialog(context, settings, weather),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, SettingsProvider settings,
      WeatherProvider weather) {
    final ctrl = TextEditingController(text: settings.apiKey);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('API Key',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Get your free API key from openweathermap.org',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              style: const TextStyle(
                  color: AppTheme.textPrimary, fontFamily: 'monospace'),
              decoration: InputDecoration(
                hintText: 'Paste API key here',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = ctrl.text.trim();
              await settings.setApiKey(key);
              weather.setService(key);
              await weather.loadWeatherByCity(weather.currentCity);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save & Apply'),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMuted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.07)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildUnitsToggle(SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.thermostat_outlined,
                color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Temperature Unit',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                Text('Choose Celsius or Fahrenheit',
                    style: TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _UnitChip(
                  label: '°C',
                  selected: settings.isMetric,
                  onTap: () => settings.setUnits('metric'),
                ),
                _UnitChip(
                  label: '°F',
                  selected: !settings.isMetric,
                  onTap: () => settings.setUnits('imperial'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, SettingsProvider settings) {
    final isDark = settings.themeMode == ThemeMode.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: AppTheme.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Theme',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                Text(isDark ? 'Dark mode' : 'Light mode',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (v) => settings.setThemeMode(
                v ? ThemeMode.dark : ThemeMode.light),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required Future<void> Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textMuted, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(
      height: 1,
      indent: 60,
      endIndent: 16,
      color: Colors.white.withOpacity(0.06));
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.all(3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppTheme.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
