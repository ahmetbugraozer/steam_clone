class Game {
  final int id;
  final String name;
  final String description;
  final DateTime? releaseDate;
  final double price;
  final String coverImageUrl;
  final int developerId;
  final int publisherId;
  final double? averageRating;
  final String systemRequirements;

  // İlişkili veriler
  final String developerName;
  final String publisherName;
  final List<String> genres;
  final List<String> tags;

  Game({
    required this.id,
    required this.name,
    required this.description,
    this.releaseDate,
    required this.price,
    required this.coverImageUrl,
    required this.developerId,
    required this.publisherId,
    this.averageRating,
    required this.systemRequirements,
    required this.developerName,
    required this.publisherName,
    required this.genres,
    required this.tags,
  });

  factory Game.fromMap(
    Map<String, dynamic> map, {
    required List<String> genres,
    required List<String> tags,
  }) {
    return Game(
      id: map['OyunID'],
      name: map['OyunAdi'],
      description: map['Aciklama'] ?? '',
      releaseDate: map['CikisTarihi'] != null
          ? DateTime.parse(map['CikisTarihi'])
          : null,
      price: map['Fiyat'],
      coverImageUrl: map['KapakGorseliURL'] ?? '',
      developerId: map['GelistiriciID'],
      publisherId: map['YayinciID'],
      averageRating: map['OrtalamaPuan'],
      systemRequirements: map['SistemGereksinimleri'] ?? '',
      developerName: map['GelistiriciAdi'],
      publisherName: map['YayinciAdi'],
      genres: genres,
      tags: tags,
    );
  }
}
