import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class PetDetailsScreen extends StatelessWidget {
  final Pet pet;

  const PetDetailsScreen({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    final visits = mockVetVisits
        .where((visit) => visit.petId == pet.id)
        .toList();

    final vaccinations = mockVaccinations
        .where((vaccination) => vaccination.petId == pet.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                child: const Icon(
                  Icons.pets,
                  size: 50,
                ),
              ),
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
                  ListTile(
                    leading: const Icon(Icons.pets),
                    title: const Text('Species'),
                    subtitle: Text(pet.species),
                  ),
                  ListTile(
                    leading: const Icon(Icons.cake),
                    title: const Text('Birth date'),
                    subtitle: Text(pet.birthDate),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'Vet Visits',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

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
      ),
    );
  }
}