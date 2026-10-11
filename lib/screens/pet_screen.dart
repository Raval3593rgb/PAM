import 'package:flutter/material.dart';
import '../widgets/pet_avatar.dart';
import '../data/mock_data.dart';

class PetsScreen extends StatelessWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search pets',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownMenu<String>(
              label: const Text('Species'),
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  value: 'All',
                  label: 'All',
                ),
                DropdownMenuEntry(
                  value: 'Cat',
                  label: 'Cat',
                ),
                DropdownMenuEntry(
                  value: 'Dog',
                  label: 'Dog',
                ),
                DropdownMenuEntry(
                  value: 'Hamster',
                  label: 'Hamster',
                ),
                DropdownMenuEntry(
                  value: 'Snake',
                  label: 'Snake',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockPets.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final pet = mockPets[index];

                return Card(
                  child: ListTile(
                    leading: const PetAvatar(),
                    title: Text(pet.name),
                    subtitle: Text(
                      '${pet.species} · ${pet.birthDate}',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}   