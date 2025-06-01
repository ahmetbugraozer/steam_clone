class Review {
  final int id;
  final int userId;
  final int gameId;
  final int rating;
  final String? reviewText;
  final DateTime reviewDate;
  final int helpfulCount;
  final int notHelpfulCount;

  // İlişkili veriler
  final String userName;
  final String userProfileImageUrl;

  Review({
    required this.id,
    required this.userId,
    required this.gameId,
    required this.rating,
    this.reviewText,
    required this.reviewDate,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.userName,
    required this.userProfileImageUrl,
  });

  factory Review.fromMap(Map<String, dynamic> map) {
    return Review(
      id: map['YorumID'],
      userId: map['KullaniciID'],
      gameId: map['OyunID'],
      rating: map['Puan'],
      reviewText: map['YorumMetni'],
      reviewDate: DateTime.parse(map['YorumTarihi']),
      helpfulCount: map['YardimciOlduSayisi'],
      notHelpfulCount: map['YardimciOlmadiSayisi'],
      userName: map['KullaniciAdi'],
      userProfileImageUrl: map['ProfilResmiURL'] ?? '',
    );
  }
}
