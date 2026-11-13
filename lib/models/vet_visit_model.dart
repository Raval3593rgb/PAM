
import 'package:flutter/foundation.dart';

import 'vet_visit.dart';
import '../data/repositories/vet_visit_repository.dart';
import '../data/result.dart';

class VetVisitModel extends ChangeNotifier {
  VetVisitModel(this._repository);

  final VetVisitRepository _repository;

  List<VetVisit> _visits = [];
  bool _isLoading = false;
  String? _error;

  List<VetVisit> get visits => List.unmodifiable(_visits);

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<VetVisit> visitsForPet(int petId) {
    return List.unmodifiable(
      _visits.where((visit) => visit.petId == petId),
    );
  }

  VetVisit? byId(int id) {
    for (final visit in _visits) {
      if (visit.id == id) {
        return visit;
      }
    }
    return null;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchAll();

    switch (result) {
      case Ok<List<VetVisit>>():
        _visits = List.of(result.value);
        _error = null;

      case Err<List<VetVisit>>():
        _error = result.msg;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> add(VetVisit visit) async {
    final result = await _repository.create(visit);

    switch (result) {
      case Ok<VetVisit>():
        _visits.add(result.value);
        notifyListeners();
        return null;

      case Err<VetVisit>():
        return result.msg;
    }
  }

  Future<String?> update(VetVisit visit) async {
    final result = await _repository.update(visit);

    switch (result) {
      case Ok<VetVisit>():
        final index = _visits.indexWhere(
          (item) => item.id == visit.id,
        );

        if (index != -1) {
          _visits[index] = result.value;
          notifyListeners();
        }

        return null;

      case Err<VetVisit>():
        return result.msg;
    }
  }

  Future<String?> delete(int id) async {
    final result = await _repository.delete(id);

    switch (result) {
      case Ok<void>():
        _visits.removeWhere((visit) => visit.id == id);
        notifyListeners();
        return null;

      case Err<void>():
        return result.msg;
    }
  }
}
