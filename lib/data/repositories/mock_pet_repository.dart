import '../../models/pet.dart';
import '../mock_data.dart' show mockPets;
import '../result.dart';
import 'pet_repository.dart';

class MockPetRepository implements PetRepository {
  final List<Pet> _pets = List.of(mockPets);

  int _nextId = mockPets.length + 1;

  bool simulateError = false;

  static const Duration _latency = Duration(milliseconds: 800);

  Future<bool> _simulateRequest() async {
    await Future.delayed(_latency);
    return !simulateError;
  }

  @override
  Future<Result<List<Pet>>> fetchAll() async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to load pets');
    }

    return Ok(List.unmodifiable(_pets));
  }

  @override
  Future<Result<Pet>> fetchById(int id) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to load pet');
    }

    for (final pet in _pets) {
      if (pet.id == id) {
        return Ok(pet);
      }
    }

    return const Err('Pet not found');
  }

  @override
  Future<Result<Pet>> create(Pet pet) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to create pet');
    }

    final newPet = Pet(
      id: _nextId++,
      ownerId: pet.ownerId,
      name: pet.name,
      species: pet.species,
      birthDate: pet.birthDate,
      photoUrl: pet.photoUrl,
    );

    _pets.add(newPet);

    return Ok(newPet);
  }

  @override
  Future<Result<Pet>> update(Pet pet) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to update pet');
    }

    final index = _pets.indexWhere(
      (item) => item.id == pet.id,
    );

    if (index == -1) {
      return const Err('Pet not found');
    }

    _pets[index] = pet;

    return Ok(pet);
  }

  @override
  Future<Result<void>> delete(int id) async {
    if (!await _simulateRequest()) {
      return const Err('Network error: Failed to delete pet');
    }

    final index = _pets.indexWhere(
      (pet) => pet.id == id,
    );

    if (index == -1) {
      return const Err('Pet not found');
    }

    _pets.removeAt(index);

    return const Ok<void>(null);
  }
}
