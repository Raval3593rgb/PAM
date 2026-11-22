
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../data/file_api.dart';
import '../data/result.dart';
import '../models/pet.dart';
import '../models/vaccination_model.dart';
import '../models/pet_model.dart';
import '../models/vet_visit_model.dart';
import '../widgets/pet_avatar.dart';
import '../widgets/info_tile.dart';
import '../widgets/error_view.dart';
import 'vaccination_form_screen.dart';

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
  bool _uploadingPhoto = false;
  int? _deletingVisitId;
  int? _deletingVaccinationId;

  Future<void> _deletePet() async {
    if (_isDeleting || _uploadingPhoto || _deletingVisitId != null || _deletingVaccinationId != null) return;

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
    if (_isDeleting || _uploadingPhoto || _deletingVisitId != null || _deletingVaccinationId != null) return;

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

  Future<void> _deleteVaccination(int vaccinationId) async {
    if (_isDeleting ||
        _uploadingPhoto ||
        _deletingVisitId != null ||
        _deletingVaccinationId != null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete vaccination?'),
        content: const Text(
          'Are you sure you want to delete this vaccination? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deletingVaccinationId = vaccinationId);

    final error =
        await context.read<VaccinationModel>().delete(vaccinationId);

    if (!mounted) return;

    setState(() => _deletingVaccinationId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Vaccination deleted successfully!'),
        backgroundColor: error == null ? null : Colors.redAccent,
      ),
    );
  }

  // Gallery -> POST /files -> PUT /pets/{id} -> refresh in PetModel.
  Future<void> _changePhoto(Pet pet) async {
    if (_isDeleting ||
        _uploadingPhoto ||
        _deletingVisitId != null ||
        _deletingVaccinationId != null) {
      return;
    }

    try {
      final selected = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
      );
      if (selected == null || !mounted) return;

      setState(() => _uploadingPhoto = true);

      final uploaded = await context.read<FileApi>().upload(selected.path);
      if (!mounted) return;

      switch (uploaded) {
        case Ok<String>(:final value):
          // Copy the existing pet, changing only photoUrl.
          final updatedPet = Pet.fromJson({
            'id': pet.id,
            'ownerId': pet.ownerId,
            'name': pet.name,
            'species': pet.species,
            'birthDate': pet.birthDate,
            'photoUrl': value,
          });

          final error = await context.read<PetModel>().update(updatedPet);
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Photo updated successfully!'),
              backgroundColor: error == null ? null : Colors.redAccent,
            ),
          );

        case Err<String>(:final msg):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.redAccent,
            ),
          );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not select a photo')),
      );
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.watch<PetModel>().byId(widget.id);
    final vetVisitModel = context.watch<VetVisitModel>();
    final vaccinationModel = context.watch<VaccinationModel>();

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

    final vaccinations = vaccinationModel.vaccinationsForPet(widget.id);

    final isBusy = _isDeleting ||
        _uploadingPhoto ||
        _deletingVisitId != null ||
        _deletingVaccinationId != null;

    final photoPath = pet.photoUrl.trim();
    final imageUrl = photoPath.isEmpty
        ? null
        : Uri.parse(context.read<FileApi>().baseUrl)
            .resolve(photoPath)
            .toString();

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
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipOval(
                      child: imageUrl == null
                          ? const Center(child: PetAvatar(radius: 50))
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Center(child: PetAvatar(radius: 50)),
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: IconButton.filled(
                      tooltip: 'Change Photo',
                      onPressed: isBusy ? null : () => _changePhoto(pet),
                      icon: _uploadingPhoto
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.camera_alt),
                    ),
                  ),
                ],
              ),
            ),
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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vaccinations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Add Vaccination',
                onPressed: isBusy
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => VaccinationFormScreen(
                              petId: widget.id,
                            ),
                          ),
                        );
                      },
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (vaccinationModel.isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          else if (vaccinationModel.error != null)
            ErrorView(
              message: vaccinationModel.error!,
              onRetry: () {
                context.read<VaccinationModel>().load();
              },
            )
          else if (vaccinations.isEmpty)
            const Text('No vaccinations')
          else
            ...vaccinations.map((vaccination) {
              final isDeletingThisVaccination =
                  _deletingVaccinationId == vaccination.id;

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.vaccines),
                  title: Text(vaccination.name),
                  subtitle: Text(
                    'Date: ${vaccination.date}\n'
                    'Next due: ${vaccination.nextDueDate}',
                  ),
                  isThreeLine: true,
                  trailing: isDeletingThisVaccination
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              tooltip: 'Edit Vaccination',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: isBusy
                                  ? null
                                  : () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                          builder: (_) => VaccinationFormScreen(
                                            petId: widget.id,
                                            existing: vaccination,
                                          ),
                                        ),
                                      );
                                    },
                            ),
                            IconButton(
                              tooltip: 'Delete Vaccination',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: isBusy
                                  ? null
                                  : () => _deleteVaccination(vaccination.id),
                            ),
                          ],
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
