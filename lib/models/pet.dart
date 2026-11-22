
class Pet {
  final int id;
  final int ownerId;
  final String name;
  final String species;
  final String birthDate;
  final String photoUrl;

  const Pet({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.birthDate,
    required this.photoUrl,
  });

  // JSON от FastAPI -> объект Pet
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as int,
      ownerId: json['ownerId'] as int,
      name: json['name'] as String,
      species: json['species'] as String,
      birthDate: json['birthDate'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
    );
  }

  // Объект Pet -> JSON для FastAPI
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'birthDate': birthDate,
      'photoUrl': photoUrl,
    };
  }
}
