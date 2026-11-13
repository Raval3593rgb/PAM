
class VetVisit {
  final int id;
  final int petId;
  final String date;
  final String reason;
  final String diagnosis;
  final double cost;

  const VetVisit({
    required this.id,
    required this.petId,
    required this.date,
    required this.reason,
    required this.diagnosis,
    required this.cost,
  });
}
