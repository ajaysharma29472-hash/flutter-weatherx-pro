class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }
}

class FavoriteCity {
  final String cityName;
  final String country;
  final double lat;
  final double lon;

  FavoriteCity({
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory FavoriteCity.fromJson(Map<String, dynamic> json) {
    return FavoriteCity(
      cityName: json['cityName'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lon: (json['lon'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'cityName': cityName,
        'country': country,
        'lat': lat,
        'lon': lon,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteCity &&
          cityName == other.cityName &&
          country == other.country;

  @override
  int get hashCode => cityName.hashCode ^ country.hashCode;
}
