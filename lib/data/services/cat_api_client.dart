import 'package:dio/dio.dart';

import '../../core/app_exception.dart';
import '../models/cat_breed.dart';
import '../models/cat_image.dart';

class CatApiClient {
  CatApiClient(this._dio);

  final Dio _dio;

  Future<List<CatImage>> fetchRandomCats({int limit = 1}) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/images/search',
        queryParameters: {'limit': limit, 'has_breeds': 1},
      );
      final data = response.data;
      if (data == null || data.isEmpty) {
        throw const ParsingException('Empty response from images/search');
      }
      return data
          .map((item) => CatImage.fromMap(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Network error',
        error.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }

  Future<CatImage> fetchRandomCat() async {
    final items = await fetchRandomCats(limit: 1);
    return items.first;
  }

  Future<List<CatBreed>> fetchBreeds() async {
    try {
      final response = await _dio.get<List<dynamic>>('/breeds');
      final list = response.data;
      if (list == null) {
        throw const ParsingException('Breeds response is null');
      }
      return list
          .map((e) => CatBreed.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (error) {
      throw NetworkException(
        error.message ?? 'Network error',
        error.response?.statusCode,
      );
    } on AppException {
      rethrow;
    } catch (error) {
      throw UnknownException(error.toString());
    }
  }
}
