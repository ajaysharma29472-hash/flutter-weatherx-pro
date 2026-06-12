# WeatherX Pro — Flutter App Setup

## Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode for device simulation
- A free OpenWeatherMap API key

## Quick Start

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Get your OpenWeatherMap API Key
1. Go to https://openweathermap.org/api
2. Sign up for a free account
3. Copy your API key from the dashboard

### 3. Run the app
```bash
flutter run
```

### 4. Configure your API Key in the app
- Open the app → Login with any email/password
- Tap **Settings** (gear icon on home screen)
- Tap **Edit** next to "OpenWeatherMap API Key"
- Paste your key and tap **Save & Apply**

---

## Project Structure

```
lib/
├── main.dart                   # App entry point, MultiProvider setup
├── models/
│   ├── weather_model.dart      # Current weather data
│   ├── forecast_model.dart     # Hourly & daily forecast
│   ├── air_quality_model.dart  # AQI & pollutants
│   └── user_model.dart        # User & FavoriteCity
├── providers/
│   ├── auth_provider.dart      # Login/logout state
│   ├── weather_provider.dart   # Weather data + API calls
│   ├── favorites_provider.dart # Saved cities (SharedPrefs)
│   └── settings_provider.dart # Units, theme, notifications
├── services/
│   ├── weather_service.dart    # OpenWeatherMap HTTP client
│   └── auth_service.dart      # Local auth (SharedPrefs)
├── screens/
│   ├── login_screen.dart       # Login & register
│   ├── home_screen.dart        # Main weather + bottom nav
│   ├── search_screen.dart      # City search
│   ├── forecast_screen.dart    # 7-day & hourly charts
│   ├── air_quality_screen.dart # AQI details
│   ├── favorites_screen.dart   # Saved cities
│   ├── profile_screen.dart     # User profile
│   ├── settings_screen.dart    # App settings
│   ├── map_screen.dart         # Live weather radar map
│   └── alerts_screen.dart      # Severe weather alerts + push notifications
├── widgets/
│   ├── weather_card.dart       # Main weather display card
│   ├── forecast_tile.dart      # Daily & hourly tiles
│   ├── air_quality_card.dart   # AQI summary card
│   ├── search_bar_widget.dart  # Debounced search input
│   └── loading_shimmer.dart    # Skeleton loading UI
└── utils/
    ├── constants.dart          # API URLs, pref keys
    ├── theme.dart              # Colors, gradients, ThemeData
    └── helpers.dart            # Formatting utilities
```

## Key Dependencies
| Package | Purpose |
|---------|---------|
| `provider ^6.1.1` | State management |
| `http ^1.2.0` | HTTP requests |
| `shared_preferences ^2.2.2` | Local storage |
| `geolocator ^11.0.0` | GPS location |
| `cached_network_image ^3.3.1` | Weather icons |
| `fl_chart ^0.67.0` | Temperature charts |
| `shimmer ^3.0.0` | Loading skeletons |
| `flutter_map ^6.1.0` | Interactive weather map |
| `latlong2 ^0.9.0` | Lat/lon coordinate types |
| `flutter_local_notifications ^17.1.2` | Push alert notifications |

## Fonts
Download [Poppins](https://fonts.google.com/specimen/Poppins) and place the .ttf files in:
```
assets/fonts/
  Poppins-Regular.ttf
  Poppins-Medium.ttf
  Poppins-SemiBold.ttf
  Poppins-Bold.ttf
```
Or remove the font entries from `pubspec.yaml` to use the system default.

## iOS Setup (additional)
Add to `ios/Runner/Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>WeatherX Pro uses your location to show local weather.</string>
```

## Notes
- Authentication is local (SharedPreferences) — no backend required
- The app uses OpenWeatherMap's free tier (One Call API 3.0 needs subscription for full forecast; fall back to 5-day/3h forecast if needed)
- Favorites and settings persist between sessions
