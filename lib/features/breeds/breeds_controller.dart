import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../core/load_state.dart';
import '../../data/models/cat_breed.dart';
import '../../data/repositories/cat_repository.dart';

class BreedsController extends ChangeNotifier {
  BreedsController(this._repository);

  final CatRepository _repository;

  LoadState state = LoadState.loading;
  List<CatBreed> breeds = const [];
  AppException? lastError;

  Future<void> loadBreeds({bool force = false}) async {
    state = LoadState.loading;
    lastError = null;
    notifyListeners();
    try {
      breeds = await _repository.getBreeds(forceRefresh: force);
      state = LoadState.initial;
    } on AppException catch (error) {
      lastError = error;
      state = LoadState.error;
    }
    notifyListeners();
  }
}
