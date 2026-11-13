
import '../../models/vaccination.dart';
import '../result.dart';

abstract class VaccinationRepository {
  // Получить все вакцинации
  Future<Result<List<Vaccination>>> fetchAll();

  // Получить вакцинации конкретного питомца
  Future<Result<List<Vaccination>>> fetchByPetId(int petId);
}
