import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../core/app_exception.dart';
import '../../core/load_state.dart';
import '../../data/models/cat_image.dart';
import '../../data/repositories/cat_repository.dart';

class SwipeController extends ChangeNotifier {
  SwipeController(this._repository);

  final CatRepository _repository;

  static const int _prefetchTarget = 4;
  final Queue<CatImage> _buffer = Queue<CatImage>();
  bool _isFetching = false;

  LoadState state = LoadState.loading;
  CatImage? currentCat;
  AppException? lastError;
  int likes = 0;

  Future<void> init() async {
    if (currentCat != null) {
      return;
    }
    await _reloadDeck();
  }

  Future<void> refresh() async {
    await _reloadDeck(force: true);
  }

  Future<void> like() async {
    likes++;
    await _showNextCat();
  }

  Future<void> dislike() async {
    await _showNextCat();
  }

  Future<void> _reloadDeck({bool force = false}) async {
    if (force) {
      _buffer.clear();
      currentCat = null;
    }
    state = LoadState.loading;
    notifyListeners();
    await _ensureBufferFilled();
    if (_buffer.isNotEmpty) {
      currentCat = _buffer.removeFirst();
      state = LoadState.idle;
      notifyListeners();
      unawaited(_ensureBufferFilled());
    } else if (lastError != null) {
      state = LoadState.error;
      notifyListeners();
    }
  }

  Future<void> _showNextCat() async {
    if (_buffer.isEmpty) {
      state = LoadState.loading;
      notifyListeners();
      await _ensureBufferFilled();
    }
    if (_buffer.isNotEmpty) {
      currentCat = _buffer.removeFirst();
      state = LoadState.idle;
      notifyListeners();
      unawaited(_ensureBufferFilled());
    } else if (lastError != null) {
      state = LoadState.error;
      notifyListeners();
    }
  }

  Future<void> _ensureBufferFilled() async {
    if (_isFetching) {
      return;
    }
    if (_buffer.length >= _prefetchTarget) {
      return;
    }
    _isFetching = true;
    final needed = _prefetchTarget - _buffer.length;
    try {
      final cats = await _repository.getRandomCats(limit: needed);
      if (cats.isNotEmpty) {
        _buffer.addAll(cats);
      }
      lastError = null;
    } on AppException catch (error) {
      lastError = error;
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }
}
