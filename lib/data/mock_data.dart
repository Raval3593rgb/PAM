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