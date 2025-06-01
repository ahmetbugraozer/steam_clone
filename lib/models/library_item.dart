class LibraryItem {
  final int id;
  final int userId;
  final int gameId;
  final DateTime purchaseDate;
  final double playTimeHours;
  final DateTime? lastPlayedDate;

  // İlişkili veri
  final String gameName;
  final String coverImageUrl;

  LibraryItem({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.purchaseDate,
    required this.playTimeHours,
    this.lastPlayedDate,
    required this.gameName,
    required this.coverImageUrl,
  });

  factory LibraryItem.fromMap(Map<String, dynamic> map) {
    return LibraryItem(
      id: map['KutuphaneKayitID'] ?? 0,
      userId: map['KullaniciID'] ?? 0,
      gameId: map['OyunID'] ?? 0,
      purchaseDate: DateTime.parse(map['SahipOlmaTarihi']),
      playTimeHours: (map['OynamaSuresiSaat'] ?? 0.0).toDouble(),
      lastPlayedDate: map['SonOynamaTarihi'] != null
          ? DateTime.parse(map['SonOynamaTarihi'])
          : null,
      gameName: map['OyunAdi'] ?? 'Bilinmeyen Oyun',
      coverImageUrl: map['KapakGorseliURL'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'KutuphaneKayitID': id,
      'KullaniciID': userId,
      'OyunID': gameId,
      'SahipOlmaTarihi': purchaseDate.toIso8601String(),
      'OynamaSuresiSaat': playTimeHours,
      'SonOynamaTarihi': lastPlayedDate?.toIso8601String(),
    };
  }
}
