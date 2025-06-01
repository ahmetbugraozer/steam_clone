class Tag {
  final int id;
  final String name;

  Tag({required this.id, required this.name});

  factory Tag.fromMap(Map<String, dynamic> map) {
    return Tag(id: map['EtiketID'], name: map['EtiketAdi']);
  }

  Map<String, dynamic> toMap() {
    return {'EtiketID': id, 'EtiketAdi': name};
  }
}
