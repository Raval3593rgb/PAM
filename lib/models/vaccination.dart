
class Vaccination {
  final int id;
  final int petId;
  final String name;
  final String date;
  final String nextDueDate;

  const Vaccination({
    required this.id,
    required this.petId,
    required this.name,
    required this.date,
    required this.nextDueDate,
  });
}
