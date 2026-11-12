
import 'package:flutter/foundation.dart';

import '../data/mock_data.dart' show Pet;
import '../data/repositories/pet_repository.dart';
import '../data/result.dart';

class PetModel extends ChangeNotifier {
  PetModel(this._repository);

  final PetRepository _repository;

  List<Pet> _pets = [];

  bool _loading = false;
  String? _error;

  List<Pet> get pets => List.unmodifiable(_pets);

  bool get isLoading => _loading;

  String? get error => _error;

  Pet? byId(int id) {
    for (final pet in _pets) {
      if (pet.id == id) {
        return pet;
      }
    }
    return null;
  }
  
  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchAll();

    switch (result) {
      case Ok<List<Pet>>():
        _pets = List.of(result.value);
        _error = null;

      case Err<List<Pet>>():
        _error = result.msg;
    }

    _loading = false;
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
        final index = _pets.indexWhere(
          (item) => item.id == pet.id,
        );

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
