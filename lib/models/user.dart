class User {
  final int id;
  final String username;
  final String email;
  final DateTime registrationDate;
  final DateTime? lastLoginDate;
  final String profileImageUrl;
  final double balance;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.registrationDate,
    this.lastLoginDate,
    required this.profileImageUrl,
    required this.balance,
  });

  // user.dart içinde fromMap metodunu güncelleme
  factory User.fromMap(Map<String, dynamic> map) {
    // Bakiye alanını güvenli şekilde dönüştürelim
    double safeBalance;
    if (map['Bakiye'] is int) {
      safeBalance = (map['Bakiye'] as int).toDouble();
    } else if (map['Bakiye'] is double) {
      safeBalance = map['Bakiye'];
    } else if (map['Bakiye'] is String) {
      safeBalance = double.tryParse(map['Bakiye']) ?? 0.0;
    } else {
      safeBalance = 0.0;
    }

    return User(
      id: map['KullaniciID'],
      username: map['KullaniciAdi'],
      email: map['Email'],
      registrationDate: DateTime.parse(map['KayitTarihi']),
      lastLoginDate: map['SonGirisTarihi'] != null
          ? DateTime.parse(map['SonGirisTarihi'])
          : null,
      profileImageUrl: _sanitizeUrl(map['ProfilResmiURL']),
      balance: safeBalance,
    );
  }

// URL temizleme yardımcı fonksiyonu
  static String _sanitizeUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.contains('example.com') || url.contains('cdn.example')) {
      return 'https://via.placeholder.com/150?text=User';
    }
    return url;
  }
}
