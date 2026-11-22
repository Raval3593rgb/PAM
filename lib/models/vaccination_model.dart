
import 'package:flutter/foundation.dart';

import '../data/repositories/vaccination_repository.dart';
import '../data/result.dart';
import 'vaccination.dart';

class VaccinationModel extends ChangeNotifier {
  VaccinationModel(this._repository);

  final VaccinationRepository _repository;

  List<Vaccination> _vaccinations = [];
  bool _isLoading = false;
  String? _error;

  List<Vaccination> get vaccinations =>
      List.unmodifiable(_vaccinations);

  bool get isLoading => _isLoading;

  String? get error => _error;

  List<Vaccination> vaccinationsForPet(int petId) {
    return List.unmodifiable(
      _vaccinations.where(
        (vaccination) => vaccination.petId == petId,
      ),
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchAll();

    switch (result) {
      case Ok<List<Vaccination>>():
        _vaccinations = List.of(result.value);
        _error = null;

      case Err<List<Vaccination>>():
        _error = result.msg;
    }

    _isLoading = false;
    notifyListeners();
  }


  Future<String?> update(Vaccination vaccination) async {
    final result = await _repository.update(vaccination);

    switch (result) {
      case Ok():
        await load();
        return null;

      case Err(:final msg):
        return msg;
    }
  }

  Future<String?> delete(int id) async {
    final result = await _repository.delete(id);

    switch (result) {
      case Ok():
        await load();
        return null;

      case Err(:final msg):
        return msg;
    }
  }
}
