import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alerts_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/weather_provider.dart';
import '../models/alert_model.dart';
import '../utils/theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alerts = context.read<AlertsProvider>();
      final weather = context.read<WeatherProvider>();
      final settings = context.read<SettingsProvider>();
      alerts.configure(
        apiKey: settings.apiKey,
        lat: weather.currentLat,
        lon: weather.currentLon,
        notificationsEnabled: settings.notificationsEnabled,
      );
      alerts.fetchAlerts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final alerts = context.watch<AlertsProvider>();
    final weather = context.watch<WeatherProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context, alerts, weather)),
              if (alerts.isLoading && alerts.alerts.isEmpty)
                const SliverFillRemaining(child: _LoadingView())
              else if (alerts.status == AlertsStatus.error)
                SliverFillRemaining(
                  child: _ErrorView(
                    message: alerts.errorMessage ?? 'Failed to load alerts',
                    onRetry: alerts.fetchAlerts,
                  ),
                )
              else if (alerts.activeAlerts.isEmpty &&
                  alerts.status == AlertsStatus.success)
                const SliverFillRemaining(child: _NoAlertsView())
              else ...[
                SliverToBoxAdapter(
                  child: _buildSummaryBanner(alerts),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final active = alerts.activeAlerts;
                        return _AlertCard(
                          alert: active[i],
                          index: i,
                        );
                      },
                      childCount: alerts.activeAlerts.length,
                    ),
                  ),
                ),
                if (alerts.alerts
                    .where((a) => !a.isActive)
                    .isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _buildSectionLabel('Expired Alerts'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) {
                          final expired =
                              alerts.alerts.where((a) => !a.isActive).toList();
                          return _AlertCard(
                            alert: expired[i],
                            index: i,
                            expired: true,
                          );
                        },
                        childCount:
                            alerts.alerts.where((a) => !a.isActive).length,
                      ),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
      BuildContext context, AlertsProvider alerts, WeatherProvider weather) {
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
                  'Weather Alerts',
                  style: TextStyle(
                    fontSize: 22,
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
                          fontSize: 13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (alerts.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                'Updated ${DateFormat('h:mm a').format(alerts.lastUpdated!)}',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textMuted),
              ),
            ),
          IconButton(
            onPressed: alerts.isLoading ? null : alerts.fetchAlerts,
            icon: alerts.isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppTheme.primary),
                  )
                : const Icon(Icons.refresh,
                    color: AppTheme.textMuted, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBanner(AlertsProvider alerts) {
    final severity = alerts.highestSeverity;
    final color = _severityColor(severity);
    final count = alerts.activeCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _severityIcon(severity),
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Active ${count == 1 ? 'Alert' : 'Alerts'}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  'Highest severity: ${_severityLabel(severity)}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          _NotifToggle(alerts: alerts),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppTheme.textMuted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final WeatherAlert alert;
  final int index;
  final bool expired;

  const _AlertCard({
    required this.alert,
    required this.index,
    this.expired = false,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _ctrl;
  late Animation<double> _expand;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _expand = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final alert = widget.alert;
    final color = widget.expired
        ? AppTheme.textMuted
        : _severityColor(alert.severity);

    return GestureDetector(
      onTap: _toggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.expired
              ? Colors.white.withOpacity(0.03)
              : color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: widget.expired
                ? Colors.white.withOpacity(0.07)
                : color.withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SeverityPill(
                      severity: alert.severity, expired: widget.expired),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.event,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: widget.expired
                                ? AppTheme.textMuted
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          alert.senderName,
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_outlined,
                              size: 13,
                              color: widget.expired
                                  ? AppTheme.textMuted
                                  : color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.expired
                                  ? 'Expired'
                                  : alert.timeRemainingLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: widget.expired
                                    ? AppTheme.textMuted
                                    : (alert.isExpiringSoon
                                        ? AppTheme.warning
                                        : color),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: AppTheme.textMuted,
                    size: 22,
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expand,
              child: _buildExpandedContent(alert, color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedContent(WeatherAlert alert, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(height: 1, color: color.withOpacity(0.2)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimeRow(alert, color),
              const SizedBox(height: 14),
              if (alert.tags.isNotEmpty) ...[
                _buildTags(alert.tags, color),
                const SizedBox(height: 14),
              ],
              const Text(
                'Full Details',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  alert.description.trim(),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeRow(WeatherAlert alert, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TimeItem(
              label: 'Starts',
              value: DateFormat('MMM d, h:mm a').format(alert.start),
              icon: Icons.play_circle_outline,
              color: color,
            ),
          ),
          Container(
              width: 1,
              height: 36,
              color: color.withOpacity(0.2)),
          Expanded(
            child: _TimeItem(
              label: 'Ends',
              value: DateFormat('MMM d, h:mm a').format(alert.end),
              icon: Icons.stop_circle_outlined,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTags(List<String> tags, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TimeItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _TimeItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppTheme.textMuted)),
        const SizedBox(height: 2),
        Text(value,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _SeverityPill extends StatelessWidget {
  final AlertSeverity severity;
  final bool expired;

  const _SeverityPill({required this.severity, required this.expired});

  @override
  Widget build(BuildContext context) {
    final color =
        expired ? AppTheme.textMuted : _severityColor(severity);
    final label =
        expired ? 'EXPIRED' : _severityLabel(severity).toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _NotifToggle extends StatelessWidget {
  final AlertsProvider alerts;

  const _NotifToggle({required this.alerts});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => alerts.setNotifications(!alerts.notificationsEnabled),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: alerts.notificationsEnabled
              ? AppTheme.primary.withOpacity(0.15)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: alerts.notificationsEnabled
                ? AppTheme.primary.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Icon(
          alerts.notificationsEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          size: 20,
          color: alerts.notificationsEnabled
              ? AppTheme.primary
              : AppTheme.textMuted,
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.primary),
          SizedBox(height: 16),
          Text('Checking for alerts...',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 15)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoAlertsView extends StatelessWidget {
  const _NoAlertsView();

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
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppTheme.success.withOpacity(0.3), width: 2),
              ),
              child: const Icon(Icons.check_circle_outline,
                  size: 52, color: AppTheme.success),
            ),
            const SizedBox(height: 20),
            const Text(
              'All Clear!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'No active weather alerts for your location.\nEnjoy the calm weather!',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 15, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

Color _severityColor(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.extreme:
      return const Color(0xFFF44336);
    case AlertSeverity.severe:
      return const Color(0xFFFF7043);
    case AlertSeverity.moderate:
      return const Color(0xFFFFC107);
    case AlertSeverity.minor:
      return const Color(0xFF29B6F6);
    case AlertSeverity.unknown:
      return AppTheme.textSecondary;
  }
}

String _severityLabel(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.extreme:
      return 'Extreme';
    case AlertSeverity.severe:
      return 'Severe';
    case AlertSeverity.moderate:
      return 'Moderate';
    case AlertSeverity.minor:
      return 'Minor';
    case AlertSeverity.unknown:
      return 'Unknown';
  }
}

IconData _severityIcon(AlertSeverity severity) {
  switch (severity) {
    case AlertSeverity.extreme:
      return Icons.warning_amber_rounded;
    case AlertSeverity.severe:
      return Icons.warning_outlined;
    case AlertSeverity.moderate:
      return Icons.info_outline;
    case AlertSeverity.minor:
      return Icons.notifications_outlined;
    case AlertSeverity.unknown:
      return Icons.help_outline;
  }
}
