
import 'package:flutter_test/flutter_test.dart';
import 'package:petcare/models/pet.dart';
import 'package:petcare/data/result.dart';

void main() {
  test('Pet.fromJson parses backend response', () {
    final pet = Pet.fromJson({
      'id': 4,
      'ownerId': 2,
      'name': 'Barsik',
      'species': 'Cat',
      'birthDate': '2024-06-15',
      'photoUrl': '',
    });

    expect(pet.id, 4);
    expect(pet.ownerId, 2);
    expect(pet.name, 'Barsik');
    expect(pet.species, 'Cat');
  });

  test('Pet.toJson creates correct API payload', () {
    final pet = Pet.fromJson({
      'id': 4,
      'ownerId': 2,
      'name': 'Barsik',
      'species': 'Cat',
      'birthDate': '2024-06-15',
      'photoUrl': '',
    });

    final json = pet.toJson();

    expect(json['name'], 'Barsik');
    expect(json['species'], 'Cat');
    expect(json['birthDate'], '2024-06-15');
  });

  test('Result handles success and errors', () {
    const success = Ok<String>('Success');
    const failure = Err<String>('Network error');

    expect(success.value, 'Success');
    expect(failure.msg, 'Network error');
  });
}
