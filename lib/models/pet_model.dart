import 'package:flutter/foundation.dart';

import 'pet.dart';
import '../data/repositories/pet_repository.dart';
import '../data/result.dart';

class PetModel extends ChangeNotifier {
  PetModel(this._repository);

  final PetRepository _repository;

  List<Pet> _pets = [];
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  String? _loadMoreError;

  // Server-side pagination and search.
  int _page = 1;
  static const int _pageSize = 20;
  String _search = '';
  bool _hasMore = false;

  // Prevent an older request from overwriting a newer search.
  int _requestId = 0;

  List<Pet> get pets => List.unmodifiable(_pets);
  bool get isLoading => _loading;
  bool get isLoadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  String? get loadMoreError => _loadMoreError;

  Pet? byId(int id) {
    for (final pet in _pets) {
      if (pet.id == id) {
        return pet;
      }
    }
    return null;
  }

  // Loads the first page. When search is omitted, retains the active filter.
  // Pass search: '' to clear the filter.
  Future<void> load({String? search}) async {
    if (search != null) {
      _search = search.trim();
    }

    final currentRequest = ++_requestId;
    _loading = true;
    _loadingMore = false;
    _error = null;
    _loadMoreError = null;
    _page = 1;
    _hasMore = false;
    _pets = [];
    notifyListeners();

    final result = await _repository.fetchAll(
      page: 1,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    if (currentRequest != _requestId) return;

    switch (result) {
      case Ok<List<Pet>>():
        _pets = List.of(result.value);
        _hasMore = result.value.length == _pageSize;
        _error = null;
      case Err<List<Pet>>():
        _error = result.msg;
    }

    _loading = false;
    notifyListeners();
  }

  // Appends the next server page; call this from a button callback.
  Future<void> loadMore() async {
    if (_loading || _loadingMore || !_hasMore || _error != null) return;

    final currentRequest = _requestId;
    final nextPage = _page + 1;
    _loadingMore = true;
    _loadMoreError = null;
    notifyListeners();

    final result = await _repository.fetchAll(
      page: nextPage,
      limit: _pageSize,
      search: _search.isEmpty ? null : _search,
    );

    if (currentRequest != _requestId) return;

    switch (result) {
      case Ok<List<Pet>>():
        _pets.addAll(result.value);
        _page = nextPage;
        _hasMore = result.value.length == _pageSize;
      case Err<List<Pet>>():
        _loadMoreError = result.msg;
    }

    _loadingMore = false;
    notifyListeners();
  }

  Future<String?> add(Pet pet) async {
    final result = await _repository.create(pet);

    switch (result) {
      case Ok<Pet>():
        _pets.add(result.value);
        notifyListeners();
        return null;
      case Err<Pet>():
        return result.msg;
    }
  }

  Future<String?> update(Pet pet) async {
    final result = await _repository.update(pet);

    switch (result) {
      case Ok<Pet>():
        final index = _pets.indexWhere((item) => item.id == pet.id);
        if (index != -1) {
          _pets[index] = result.value;
          notifyListeners();
        }
        return null;
      case Err<Pet>():
        return result.msg;
    }
  }

  Future<String?> delete(int id) async {
    final result = await _repository.delete(id);

    switch (result) {
      case Ok<void>():
        _pets.removeWhere((pet) => pet.id == id);
        notifyListeners();
        return null;
      case Err<void>():
        return result.msg;
    }
  }
}
