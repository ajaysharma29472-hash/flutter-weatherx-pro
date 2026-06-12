import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/alerts_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.bgDark,
    ),
  );
  runApp(const WeatherXProApp());
}

class WeatherXProApp extends StatelessWidget {
  const WeatherXProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ChangeNotifierProvider(create: (_) => AlertsProvider()),
      ],
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final settings = context.read<SettingsProvider>();
    final auth = context.read<AuthProvider>();
    final favs = context.read<FavoritesProvider>();
    final weather = context.read<WeatherProvider>();

    await Future.wait([
      settings.load(),
      auth.checkAuth(),
      favs.load(),
    ]);

    final alertsProvider = context.read<AlertsProvider>();
    await alertsProvider.initialize();

    if (settings.apiKey.isNotEmpty) {
      weather.setService(settings.apiKey);
      weather.setUnits(settings.units);
      await weather.loadCurrentLocation();

      alertsProvider.configure(
        apiKey: settings.apiKey,
        lat: weather.currentLat,
        lon: weather.currentLon,
        notificationsEnabled: settings.notificationsEnabled,
      );
      alertsProvider.startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final auth = context.watch<AuthProvider>();

    return MaterialApp(
      title: 'WeatherX Pro',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _buildHome(auth),
    );
  }

  Widget _buildHome(AuthProvider auth) {
    switch (auth.status) {
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        return const LoginScreen();
    }
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_rounded,
                size: 80,
                color: AppTheme.primary,
              ),
              SizedBox(height: 20),
              Text(
                'WeatherX Pro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
