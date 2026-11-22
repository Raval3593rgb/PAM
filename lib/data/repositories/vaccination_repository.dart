
import '../../models/vaccination.dart';
import '../result.dart';

abstract class VaccinationRepository {
  // Получить все вакцинации
  Future<Result<List<Vaccination>>> fetchAll();

  Future<Result<Vaccination>> create(Vaccination vaccination);

  Future<Result<Vaccination>> update(Vaccination vaccination);

  Future<Result<void>> delete(int id);
  
  
  // Получить вакцинации конкретного питомца

  Future<Result<List<Vaccination>>> fetchByPetId(int petId);
}
