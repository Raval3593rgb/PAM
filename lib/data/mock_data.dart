class Pet{
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
}

class VetVisit{
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


class Vaccination{
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

const mockPets = [
  Pet(
    id: 1,
    ownerId: 1,
    name: 'Barsik',
    species: 'Cat',
    birthDate: '12.04.2004',
    photoUrl: '', 
  ),

  Pet(
    id: 2,
    ownerId: 1,
    name: 'Richie',
    species: 'Dog',
    birthDate: '05.01.2024',
    photoUrl: '',
  ),

  Pet(
    id: 3,
    ownerId: 1,
    name: 'Rex',
    species: 'Dog',
    birthDate: '20.05.2010',
    photoUrl: '',
  ),

  Pet(
    id:4,
    ownerId: 1, 
    name: 'Galaxy Destroyer',
    species: 'Hamster',
    birthDate: '10.09.2025',
    photoUrl: '',
    ),

  Pet(
    id: 5, 
    ownerId: 1, 
    name: 'Cupcake',
    species: 'Snake',
    birthDate: '03.02.2012',
    photoUrl: '',
    ),

  Pet(
    id: 6,
    ownerId: 1,
    name: 'Dexter', 
    species: 'Cat', 
    birthDate: '07.06.2013', 
    photoUrl: '',
    ),
];

const mockVetVisits = [
  VetVisit(
    id: 1,
    petId: 1,
    date: '12.02.2026',
    reason: 'Annual checkup',
    diagnosis: 'Healthy',
    cost: 350.0,
  ),

  VetVisit(
    id: 2,
    petId: 2,
    date: '05.03.2026',
    reason: 'Ear irritation',
    diagnosis: 'Mild otitis',
    cost: 480.0,
  ),

  VetVisit(
    id: 3,
    petId: 3,
    date: '18.01.2026',
    reason: 'Limping',
    diagnosis: 'Minor paw injury',
    cost: 420.0,
  ),

  VetVisit(
    id: 4,
    petId: 4,
    date: '22.04.2026',
    reason: 'Loss of appetite',
    diagnosis: 'Digestive disorder',
    cost: 250.0,
  ),

  VetVisit(
    id: 5,
    petId: 5,
    date: '14.05.2026',
    reason: 'Routine examination',
    diagnosis: 'Healthy',
    cost: 300.0,
  ),

  VetVisit(
    id: 6,
    petId: 6,
    date: '08.06.2026',
    reason: 'Eye irritation',
    diagnosis: 'Mild conjunctivitis',
    cost: 390.0,
  ),
];

const mockVaccinations = [
  Vaccination(
    id: 1,
    petId: 1,
    name: 'Rabies',
    date: '15.04.2025',
    nextDueDate: '15.04.2026',
  ),

  Vaccination(
    id: 2,
    petId: 2,
    name: 'Rabies',
    date: '20.07.2025',
    nextDueDate: '20.07.2026',
  ),

  Vaccination(
    id: 3,
    petId: 3,
    name: 'DHPP',
    date: '10.09.2025',
    nextDueDate: '10.09.2026',
  ),

  Vaccination(
    id: 4,
    petId: 4,
    name: 'Hamster Health Check',
    date: '01.11.2025',
    nextDueDate: '01.11.2026',
  ),

  Vaccination(
    id: 5,
    petId: 5,
    name: 'Reptile Preventive Check',
    date: '12.12.2025',
    nextDueDate: '12.12.2026',
  ),

  Vaccination(
    id: 6,
    petId: 6,
    name: 'Rabies',
    date: '03.08.2025',
    nextDueDate: '03.08.2026',
  ),
];