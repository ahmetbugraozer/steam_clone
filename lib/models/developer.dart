class Developer {
  final int id;
  final String name;
  final DateTime? foundationDate;
  final String? website;
  final String? country;

  Developer({
    required this.id,
    required this.name,
    this.foundationDate,
    this.website,
    this.country,
  });

  factory Developer.fromMap(Map<String, dynamic> map) {
    return Developer(
      id: map['GelistiriciID'],
      name: map['GelistiriciAdi'],
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
      'GelistiriciID': id,
      'GelistiriciAdi': name,
      'KurulusTarihi': foundationDate?.toIso8601String(),
      'WebSitesi': website,
      'Ulke': country,
    };
  }
}
