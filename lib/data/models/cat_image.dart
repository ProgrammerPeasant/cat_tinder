import 'dart:convert';

import 'cat_breed.dart';

class CatImage {
  CatImage({
    required this.id,
    required this.url,
    required this.width,
    required this.height,
    this.breed,
  });

  final String id;
  final String url;
  final int width;
  final int height;
  final CatBreed? breed;

  factory CatImage.fromMap(Map<String, dynamic> map) {
    final breeds = map['breeds'] as List<dynamic>?;
    return CatImage(
      id: map['id'] as String? ?? '',
      url: map['url'] as String? ?? '',
      width: (map['width'] as num?)?.round() ?? 0,
      height: (map['height'] as num?)?.round() ?? 0,
      breed: breeds != null && breeds.isNotEmpty
          ? CatBreed.fromMap(breeds.first as Map<String, dynamic>)
          : null,
    );
  }

  factory CatImage.fromJson(String source) =>
      CatImage.fromMap(json.decode(source) as Map<String, dynamic>);
}
