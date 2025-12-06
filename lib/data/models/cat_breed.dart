import 'dart:convert';

class CatBreed {
  CatBreed({
    required this.id,
    required this.name,
    required this.origin,
    required this.description,
    required this.temperament,
    required this.lifeSpan,
    required this.intelligence,
    required this.adaptability,
    required this.wikipediaUrl,
  });

  final String id;
  final String name;
  final String origin;
  final String description;
  final String temperament;
  final String lifeSpan;
  final int intelligence;
  final int adaptability;
  final String? wikipediaUrl;

  factory CatBreed.fromMap(Map<String, dynamic> map) {
    return CatBreed(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Unknown',
      origin: map['origin'] as String? ?? 'Unknown',
      description: map['description'] as String? ?? 'No description',
      temperament: map['temperament'] as String? ?? 'Calm',
      lifeSpan: map['life_span'] as String? ?? 'N/A',
      intelligence: (map['intelligence'] as num?)?.round() ?? 0,
      adaptability: (map['adaptability'] as num?)?.round() ?? 0,
      wikipediaUrl: map['wikipedia_url'] as String?,
    );
  }

  factory CatBreed.fromJson(String source) =>
      CatBreed.fromMap(json.decode(source) as Map<String, dynamic>);
}
