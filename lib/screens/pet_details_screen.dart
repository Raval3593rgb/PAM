
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/info_tile.dart';

class PetDetailsScreen extends StatelessWidget {
  final int id;

  const PetDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    Pet? pet;

    for (final item in mockPets) {
      if (item.id == id) {
        pet = item;
        break;
      }
    }

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pet not found')),
        body: const Center(
          child: Text('This pet does not exist'),
        ),
      );
    }

    final visits = mockVetVisits
        .where((visit) => visit.petId == id)
        .toList();

    final vaccinations = mockVaccinations
        .where((vaccination) => vaccination.petId == id)
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(pet.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: PetAvatar(radius: 50),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              pet.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                InfoTile(
                  icon: Icons.pets,
                  title: 'Species',
                  value: pet.species,
                ),
                InfoTile(
                  icon: Icons.cake,
                  title: 'Birth date',
                  value: pet.birthDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vet Visits',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Vet Visit',
                onPressed: () {
                  context.push('/pets/$id/visits/new');
                },
              ),
            ],
          ),
          if (visits.isEmpty)
            const Text('No vet visits')
          else
            ...visits.map(
              (visit) => Card(
                child: ListTile(
                  leading: const Icon(Icons.medical_services),
                  title: Text(visit.reason),
                  subtitle: Text(
                    '${visit.date}\n'
                    'Diagnosis: ${visit.diagnosis}\n'
                    'Cost: ${visit.cost.toStringAsFixed(2)} MDL',
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(
            'Vaccinations',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (vaccinations.isEmpty)
            const Text('No vaccinations')
          else
            ...vaccinations.map(
              (vaccination) => Card(
                child: ListTile(
                  leading: const Icon(Icons.vaccines),
                  title: Text(vaccination.name),
                  subtitle: Text(
                    'Date: ${vaccination.date}\n'
                    'Next due: ${vaccination.nextDueDate}',
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
