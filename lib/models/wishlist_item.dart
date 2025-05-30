class WishlistItem {
  final int id;
  final int userId;
  final int gameId;
  final DateTime addDate;

  // İlişkili veri
  final String? gameName;
  final String? coverImageUrl;
  final double? gamePrice;

  WishlistItem({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.addDate,
    this.gameName,
    this.coverImageUrl,
    this.gamePrice,
  });

  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['IstekListesiID'],
      userId: map['KullaniciID'],
      gameId: map['OyunID'],
      addDate: DateTime.parse(map['EklemeTarihi']),
      gameName: map['OyunAdi'],
      coverImageUrl: map['KapakGorseliURL'],
      gamePrice: map['Fiyat'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IstekListesiID': id,
      'KullaniciID': userId,
      'OyunID': gameId,
      'EklemeTarihi': addDate.toIso8601String(),
    };
  }
}
