import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class VaccinationCalendarScreen extends StatelessWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Calendar'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: mockVaccinations.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final vaccination = mockVaccinations[index];

          final pet = mockPets.firstWhere(
            (pet) => pet.id == vaccination.petId,
          );

          return Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.vaccines),
              ),
              title: Text(vaccination.name),
              subtitle: Text(
                '${pet.name} · ${pet.species}\n'
                'Last vaccination: ${vaccination.date}\n'
                'Next due: ${vaccination.nextDueDate}',
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}