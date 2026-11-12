
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart' show mockVaccinations;
import '../models/pet_model.dart';
import '../models/vet_visit_model.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/info_tile.dart';
import '../widgets/error_view.dart';

class PetDetailsScreen extends StatefulWidget {
  final int id;

  const PetDetailsScreen({
    super.key,
    required this.id,
  });

  @override
  State<PetDetailsScreen> createState() =>
      _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  bool _isDeleting = false;
  int? _deletingVisitId;

  Future<void> _deletePet() async {
    if (_isDeleting || _deletingVisitId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete pet?'),
          content: const Text(
            'Are you sure you want to delete this pet? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isDeleting = true;
    });

    final error =
        await context.read<PetModel>().delete(widget.id);

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pet deleted successfully!'),
      ),
    );

    context.go('/pets');
  }

  Future<void> _deleteVisit(int visitId) async {
    if (_isDeleting || _deletingVisitId != null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete vet visit?'),
          content: const Text(
            'Are you sure you want to delete this '
            'vet visit?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _deletingVisitId = visitId;
    });

    final error =
        await context.read<VetVisitModel>().delete(visitId);

    if (!mounted) return;

    setState(() {
      _deletingVisitId = null;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vet visit deleted successfully!'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetModel>().byId(widget.id);
    final vetVisitModel = context.watch<VetVisitModel>();

    if (pet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet not found'),
        ),
        body: const Center(
          child: Text('This pet does not exist'),
        ),
      );
    }

    final visits = vetVisitModel.visitsForPet(widget.id);

    final vaccinations = mockVaccinations
        .where(
          (vaccination) => vaccination.petId == widget.id,
        )
        .toList();

    final isBusy =
        _isDeleting || _deletingVisitId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            onPressed: isBusy
                ? null
                : () {
                    context.push(
                      '/pets/${widget.id}/edit',
                    );
                  },
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Pet',
          ),
          IconButton(
            onPressed: isBusy ? null : _deletePet,
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete Pet',
          ),
        ],
      ),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium,
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

          if (_isDeleting) ...[
            const SizedBox(height: 16),
            const Center(
              child: CircularProgressIndicator(),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text('Deleting pet...'),
            ),
          ],

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vet Visits',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Vet Visit',
                onPressed: isBusy
                    ? null
                    : () {
                        context.push(
                          '/pets/${widget.id}/visits/new',
                        );
                      },
              ),
            ],
          ),

          if (vetVisitModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (vetVisitModel.error != null)
            ErrorView(
              message: vetVisitModel.error!,
              onRetry: () {
                context.read<VetVisitModel>().load();
              },
            )
          else if (visits.isEmpty)
            const Text('No vet visits')
          else
            ...visits.map(
              (visit) {
                final isDeletingThisVisit =
                    _deletingVisitId == visit.id;

                return Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.medical_services,
                    ),
                    title: Text(visit.reason),
                    subtitle: Text(
                      '${visit.date}\n'
                      'Diagnosis: ${visit.diagnosis}\n'
                      'Cost: ${visit.cost.toStringAsFixed(2)} MDL',
                    ),
                    isThreeLine: true,
                    trailing: isDeletingThisVisit
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        context.push(
                                          '/pets/${widget.id}'
                                          '/visits/${visit.id}/edit',
                                        );
                                      },
                                icon: const Icon(
                                  Icons.edit_outlined,
                                ),
                                tooltip: 'Edit Visit',
                              ),
                              IconButton(
                                onPressed: isBusy
                                    ? null
                                    : () {
                                        _deleteVisit(visit.id);
                                      },
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                tooltip: 'Delete Visit',
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),

          Text(
            'Vaccinations',
            style: Theme.of(context)
                .textTheme
                .titleLarge,
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
