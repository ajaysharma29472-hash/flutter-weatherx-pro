import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/favorites_provider.dart';
import '../utils/theme.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final favs = context.watch<FavoritesProvider>();
    final user = auth.user;

    return Container(
      decoration: BoxDecoration(gradient: AppTheme.bgGradient),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              _buildHeader(user?.name ?? ''),
              const SizedBox(height: 24),
              _buildAvatar(user?.name ?? 'U'),
              const SizedBox(height: 20),
              if (!_editing) ...[
                Text(
                  user?.name ?? 'User',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 8),
                Text(
                  'Member since ${user?.createdAt.year ?? ''}',
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 24),
                _buildStatsRow(favs.count),
                const SizedBox(height: 24),
                _buildEditButton(),
              ] else ...[
                _buildEditForm(auth),
              ],
              const SizedBox(height: 24),
              _buildMenuSection(context),
              const SizedBox(height: 24),
              _buildLogoutButton(auth),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Profile',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        IconButton(
          onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen())),
          icon: const Icon(Icons.settings_outlined, color: AppTheme.textMuted),
        ),
      ],
    );
  }

  Widget _buildAvatar(String initial) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.accent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial.isNotEmpty ? initial[0].toUpperCase() : 'U',
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _editing = true;
              _nameController.text =
                  context.read<AuthProvider>().user?.name ?? '';
              _emailController.text =
                  context.read<AuthProvider>().user?.email ?? '';
            });
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.15), width: 2),
            ),
            child: const Icon(Icons.edit, size: 14, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int favCount) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            value: favCount.toString(),
            label: 'Saved Cities',
            icon: Icons.favorite,
            color: Colors.redAccent,
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          const _StatItem(
            value: 'Pro',
            label: 'Plan',
            icon: Icons.workspace_premium,
            color: Color(0xFFFFD700),
          ),
          Container(width: 1, height: 40, color: Colors.white.withOpacity(0.1)),
          const _StatItem(
            value: '7',
            label: 'Day Forecast',
            icon: Icons.calendar_today_outlined,
            color: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          setState(() {
            _editing = true;
            _nameController.text =
                context.read<AuthProvider>().user?.name ?? '';
            _emailController.text =
                context.read<AuthProvider>().user?.email ?? '';
          });
        },
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('Edit Profile'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textPrimary,
          side: BorderSide(color: Colors.white.withOpacity(0.2)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildEditForm(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDec('Full Name', Icons.person_outline),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _emailController,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: _inputDec('Email', Icons.email_outlined),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _editing = false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textSecondary,
                    side: BorderSide(color: Colors.white.withOpacity(0.15)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    await auth.updateProfile(
                      name: _nameController.text.trim(),
                      email: _emailController.text.trim(),
                    );
                    if (mounted) setState(() => _editing = false);
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textMuted),
      prefixIcon: Icon(icon, color: AppTheme.textMuted, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primary),
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      _MenuItem(
        icon: Icons.settings_outlined,
        label: 'Settings',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Notifications',
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
      ),
      _MenuItem(
        icon: Icons.privacy_tip_outlined,
        label: 'Privacy Policy',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Help & Support',
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.info_outline,
        label: 'About WeatherX Pro',
        onTap: () => _showAbout(context),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: AppTheme.primary, size: 18),
                ),
                title: Text(
                  item.label,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.textMuted),
                onTap: item.onTap,
                shape: i == items.length - 1
                    ? const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      )
                    : null,
              ),
              if (i < items.length - 1)
                Divider(
                    height: 1,
                    indent: 60,
                    endIndent: 16,
                    color: Colors.white.withOpacity(0.06)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider auth) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppTheme.cardDark,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.textPrimary)),
              content: const Text('Are you sure you want to sign out?',
                  style: TextStyle(color: AppTheme.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error),
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await auth.logout();
          }
        },
        icon: const Icon(Icons.logout, size: 18, color: AppTheme.error),
        label: const Text('Sign Out',
            style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppTheme.error.withOpacity(0.4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cloud_rounded, color: AppTheme.primary, size: 28),
            SizedBox(width: 10),
            Text('WeatherX Pro',
                style: TextStyle(color: AppTheme.textPrimary)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version 1.0.0',
                style: TextStyle(color: AppTheme.textSecondary)),
            SizedBox(height: 8),
            Text(
              'Powered by OpenWeatherMap API.\nBuilt with Flutter & Provider.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
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
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        Text(label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  _MenuItem({required this.icon, required this.label, required this.onTap});
}
