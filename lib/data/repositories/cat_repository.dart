import '../../core/app_exception.dart';
import '../models/cat_breed.dart';
import '../models/cat_image.dart';
import '../services/cat_api_client.dart';

class CatRepository {
  CatRepository(this._apiClient);

  final CatApiClient _apiClient;
  List<CatBreed>? _cachedBreeds;

  Future<CatImage> getRandomCat() async {
    try {
      return await _apiClient.fetchRandomCat();
    } on AppException {
      rethrow;
    }
  }

  Future<List<CatImage>> getRandomCats({int limit = 4}) async {
    try {
      return await _apiClient.fetchRandomCats(limit: limit);
    } on AppException {
      rethrow;
    }
  }

  Future<List<CatBreed>> getBreeds({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedBreeds != null && _cachedBreeds!.isNotEmpty) {
      return _cachedBreeds!;
    }
    final breeds = await _apiClient.fetchBreeds();
    _cachedBreeds = breeds;
    return breeds;
  }

  CatBreed? findBreedById(String id) {
    final breeds = _cachedBreeds;
    if (breeds == null) {
      return null;
    }
    try {
      return breeds.firstWhere((breed) => breed.id == id);
    } catch (_) {
      return null;
    }
  }
}
