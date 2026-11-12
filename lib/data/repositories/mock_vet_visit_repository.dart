
import '../mock_data.dart';
import '../result.dart';
import 'vet_visit_repository.dart';

class MockVetVisitRepository implements VetVisitRepository {
  final List<VetVisit> _visits = List.of(mockVetVisits);

  late int _nextId = _visits.fold<int>(
    0,
    (maxId, visit) => visit.id > maxId ? visit.id : maxId,
  ) + 1;

  bool simulateError = false;

  static const Duration _latency = Duration(milliseconds: 800);

  Future<bool> _simulateRequest() async {
    await Future.delayed(_latency);
    return !simulateError;
  }

  @override
  Future<Result<List<VetVisit>>> fetchAll() async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to load vet visits');
    }

    return Ok(List.unmodifiable(_visits));
  }

  @override
  Future<Result<List<VetVisit>>> fetchByPetId(int petId) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to load pet visits');
    }

    final visits = _visits
        .where((visit) => visit.petId == petId)
        .toList();

    return Ok(visits);
  }

  @override
  Future<Result<VetVisit>> fetchById(int id) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to load vet visit');
    }

    for (final visit in _visits) {
      if (visit.id == id) {
        return Ok(visit);
      }
    }

    return const Err('Vet visit not found');
  }

  @override
  Future<Result<VetVisit>> create(VetVisit visit) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to create vet visit');
    }

    final newVisit = VetVisit(
      id: _nextId++,
      petId: visit.petId,
      date: visit.date,
      reason: visit.reason,
      diagnosis: visit.diagnosis,
      cost: visit.cost,
    );

    _visits.add(newVisit);

    return Ok(newVisit);
  }

  @override
  Future<Result<VetVisit>> update(VetVisit visit) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to update vet visit');
    }

    final index = _visits.indexWhere(
      (item) => item.id == visit.id,
    );

    if (index == -1) {
      return const Err('Vet visit not found');
    }

    _visits[index] = visit;

    return Ok(visit);
  }

  @override
  Future<Result<void>> delete(int id) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to delete vet visit');
    }

    final index = _visits.indexWhere(
      (visit) => visit.id == id,
    );

    if (index == -1) {
      return const Err('Vet visit not found');
    }

    _visits.removeAt(index);

    return const Ok<void>(null);
  }
}
