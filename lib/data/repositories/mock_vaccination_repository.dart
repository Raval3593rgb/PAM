
import '../../models/vaccination.dart';
import '../mock_data.dart' show mockVaccinations;
import '../result.dart';
import 'vaccination_repository.dart';

class MockVaccinationRepository
    implements VaccinationRepository {

  final List<Vaccination> _vaccinations =
      List.of(mockVaccinations);

  bool simulateError = false;

  static const Duration _latency =
      Duration(milliseconds: 800);

  Future<bool> _simulateRequest() async {
    await Future.delayed(_latency);
    return !simulateError;
  }

  @override
  Future<Result<List<Vaccination>>> fetchAll() async {
    if (!await _simulateRequest()) {
      return const Err(
        'Network error: Failed to load vaccinations',
      );
    }

    return Ok(List.unmodifiable(_vaccinations));
  }

  @override
  Future<Result<List<Vaccination>>> fetchByPetId(
    int petId,
  ) async {
    if (!await _simulateRequest()) {
      return const Err(
        'Network error: Failed to load pet vaccinations',
      );
    }

    final vaccinations = _vaccinations
        .where(
          (vaccination) => vaccination.petId == petId,
        )
        .toList();

    return Ok(vaccinations);
  }
}
