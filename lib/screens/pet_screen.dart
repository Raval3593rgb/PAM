import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../widgets/error_view.dart';
import '../widgets/pet_avatar.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _species = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search is performed by FastAPI, not by filtering the loaded page locally.
  void _submitSearch(String query) {
    FocusScope.of(context).unfocus();
    context.read<PetModel>().load(search: query.trim());
  }

  void _clearSearch() {
    _searchController.clear();
    _submitSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final petModel = context.watch<PetModel>();

    // Species filtering stays local, just as in the original screen.
    // It applies to the pages that have been loaded so far.
    final filteredPets = petModel.pets.where((pet) {
      return _species == 'All' || pet.species == _species;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('My Pets'),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Pets loaded from server',
              child: Chip(label: Text('${petModel.pets.length}')),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => context.read<PetModel>().load(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Pets',
          ),
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: 'Search pets',
                hintText: 'Type a name and press Search',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                  tooltip: 'Clear search',
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: _submitSearch,
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
                setState(() => _species = value ?? 'All');
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: petModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : petModel.error != null
                    ? ErrorView(
                        message: petModel.error!,
                        onRetry: () => context.read<PetModel>().load(),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: filteredPets.isEmpty
                                ? const Center(child: Text('No pets found'))
                                : ListView.separated(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    itemCount: filteredPets.length,
                                    separatorBuilder: (context, index) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, index) {
                                      final pet = filteredPets[index];
                                      return Card(
                                        child: ListTile(
                                          leading: const PetAvatar(),
                                          title: Text(pet.name),
                                          subtitle: Text(
                                            '${pet.species} · ${pet.birthDate}',
                                          ),
                                          trailing: const Icon(
                                            Icons.chevron_right,
                                          ),
                                          onTap: () =>
                                              context.push('/pets/${pet.id}'),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                          if (petModel.loadMoreError != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(
                                petModel.loadMoreError!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          if (petModel.hasMore || petModel.isLoadingMore)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              child: petModel.isLoadingMore
                                  ? const CircularProgressIndicator()
                                  : OutlinedButton.icon(
                                      onPressed: () =>
                                          context.read<PetModel>().loadMore(),
                                      icon: const Icon(Icons.expand_more),
                                      label: Text(
                                        petModel.loadMoreError != null
                                            ? 'Retry Load More'
                                            : 'Load More',
                                      ),
                                    ),
                            ),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
