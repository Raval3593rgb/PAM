
import '../../models/vet_visit.dart';
import '../result.dart';

abstract class VetVisitRepository {
  Future<Result<List<VetVisit>>> fetchAll();

  Future<Result<List<VetVisit>>> fetchByPetId(int petId);

  Future<Result<VetVisit>> fetchById(int id);

  Future<Result<VetVisit>> create(VetVisit visit);

  Future<Result<VetVisit>> update(VetVisit visit);

  Future<Result<void>> delete(int id);
}
