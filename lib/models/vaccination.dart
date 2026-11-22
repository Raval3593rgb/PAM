
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

  // JSON от FastAPI -> объект Vaccination
  factory Vaccination.fromJson(Map<String, dynamic> json) {
    return Vaccination(
      id: json['id'] as int,
      petId: json['petId'] as int,
      name: json['name'] as String,
      date: json['date'] as String,
      nextDueDate: json['nextDueDate'] as String,
    );
  }

  // Объект Vaccination -> JSON для FastAPI
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'name': name,
      'date': date,
      'nextDueDate': nextDueDate,
    };
  }
}
