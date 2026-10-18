import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/mock_data.dart';
import '../widgets/pet_avatar.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  String _search = '';
  String _species = 'All';

  @override
  Widget build(BuildContext context) {
    final filteredPets = mockPets.where((pet) {
      final matchesName = pet.name.toLowerCase().contains(
        _search.toLowerCase(),
      );

      final matchesSpecies = _species == 'All' || pet.species == _species;

      return matchesName && matchesSpecies;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            onPressed: () => context.push('/pets/new'),
            icon: const Icon(Icons.add),
            tooltip: 'Add Pet',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search pets',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              initialValue: _species,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'All', child: Text('All')),
                DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                DropdownMenuItem(value: 'Hamster', child: Text('Hamster')),
                DropdownMenuItem(value: 'Snake', child: Text('Snake')),
              ],
              onChanged: (value) {
                setState(() {
                  _species = value ?? 'All';
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredPets.isEmpty
                ? const Center(child: Text('No pets found'))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredPets.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final pet = filteredPets[index];

                      return Card(
                        child: ListTile(
                          leading: const PetAvatar(),
                          title: Text(pet.name),
                          subtitle: Text('${pet.species} · ${pet.birthDate}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/pets/${pet.id}');
                          },
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
