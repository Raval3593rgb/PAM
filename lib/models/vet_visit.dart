
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

  // JSON от FastAPI -> объект VetVisit
  factory VetVisit.fromJson(Map<String, dynamic> json) {
    return VetVisit(
      id: json['id'] as int,
      petId: json['petId'] as int,
      date: json['date'] as String,
      reason: json['reason'] as String,
      diagnosis: json['diagnosis'] as String? ?? '',
      cost: (json['cost'] as num).toDouble(),
    );
  }

  // Объект VetVisit -> JSON для FastAPI
  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'date': date,
      'reason': reason,
      'diagnosis': diagnosis,
      'cost': cost,
    };
  }
}
