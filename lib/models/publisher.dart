class Publisher {
  final int id;
  final String name;
  final DateTime? foundationDate;
  final String? website;
  final String? country;

  Publisher({
    required this.id,
    required this.name,
    this.foundationDate,
    this.website,
    this.country,
  });

  factory Publisher.fromMap(Map<String, dynamic> map) {
    return Publisher(
      id: map['YayinciID'],
      name: map['YayinciAdi'],
      foundationDate:
          map['KurulusTarihi'] != null
              ? DateTime.parse(map['KurulusTarihi'])
              : null,
      website: map['WebSitesi'],
      country: map['Ulke'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'YayinciID': id,
      'YayinciAdi': name,
      'KurulusTarihi': foundationDate?.toIso8601String(),
      'WebSitesi': website,
      'Ulke': country,
    };
  }
}
