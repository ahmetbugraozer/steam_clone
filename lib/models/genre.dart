class Genre {
  final int id;
  final String name;

  Genre({required this.id, required this.name});

  factory Genre.fromMap(Map<String, dynamic> map) {
    return Genre(id: map['TurID'], name: map['TurAdi']);
  }

  Map<String, dynamic> toMap() {
    return {'TurID': id, 'TurAdi': name};
  }
}
