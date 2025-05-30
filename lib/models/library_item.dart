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
      id: map['KutuphaneKayitID'],
      userId: map['KullaniciID'],
      gameId: map['OyunID'],
      purchaseDate: DateTime.parse(map['SahipOlmaTarihi']),
      playTimeHours: map['OynamaSuresiSaat'],
      lastPlayedDate: map['SonOynamaTarihi'] != null
          ? DateTime.parse(map['SonOynamaTarihi'])
          : null,
      gameName: map['OyunAdi'],
      coverImageUrl: map['KapakGorseliURL'] ?? '',
    );
  }
}
