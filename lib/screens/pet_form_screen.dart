
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/pet.dart';
import '../models/pet_model.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({
    super.key,
    this.petId,
  });

  final int? petId;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedSpecies;
  Pet? _editingPet;

  bool _isSaving = false;
  bool _initialized = false;

  bool get _isEditing => widget.petId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (_isEditing) {
      _editingPet = context.read<PetModel>().byId(widget.petId!);

      if (_editingPet != null) {
        _nameController.text = _editingPet!.name;
        _birthDateController.text = _editingPet!.birthDate;
        _selectedSpecies = _editingPet!.species;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Birth date is required';
    }

    final pattern = RegExp(
      r'^(\d{2})\.(\d{2})\.(\d{4})$',
    );

    final match = pattern.firstMatch(value.trim());

    if (match == null) {
      return 'Use DD.MM.YYYY';
    }

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    final date = DateTime(year, month, day);

    if (date.day != day ||
        date.month != month ||
        date.year != year) {
      return 'Invalid date';
    }

    if (date.isAfter(DateTime.now())) {
      return 'Birth date cannot be in the future';
    }

    return null;
  }

  Future<void> _savePet() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final pet = Pet(
      id: _editingPet?.id ?? 0,
      ownerId: _editingPet?.ownerId ?? 1,
      name: _nameController.text.trim(),
      species: _selectedSpecies!,
      birthDate: _birthDateController.text.trim(),
      photoUrl: _editingPet?.photoUrl ?? '',
    );

    final petModel = context.read<PetModel>();

    final String? error;

    if (_isEditing) {
      error = await petModel.update(pet);
    } else {
      error = await petModel.add(pet);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
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
      SnackBar(
        content: Text(
          _isEditing
              ? 'Pet ${pet.name} updated successfully!'
              : 'Pet ${pet.name} added successfully!',
        ),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && _editingPet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pet not found'),
        ),
        body: const Center(
          child: Text('This pet does not exist'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Pet' : 'Add Pet'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.pets, size: 50),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: _isSaving
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Photo selection will be added in L5',
                          ),
                        ),
                      );
                    },
              icon: const Icon(Icons.photo_camera),
              label: const Text('Choose photo'),
            ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _nameController,
              enabled: !_isSaving,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Pet name',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Pet name is required';
                }

                if (value.trim().length < 2) {
                  return 'Name must contain at least 2 characters';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedSpecies,
              decoration: const InputDecoration(
                labelText: 'Species',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Cat',
                  child: Text('Cat'),
                ),
                DropdownMenuItem(
                  value: 'Dog',
                  child: Text('Dog'),
                ),
                DropdownMenuItem(
                  value: 'Hamster',
                  child: Text('Hamster'),
                ),
                DropdownMenuItem(
                  value: 'Snake',
                  child: Text('Snake'),
                ),
                DropdownMenuItem(
                  value: 'Other',
                  child: Text('Other'),
                ),
              ],
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedSpecies = value;
                      });
                    },
              validator: (value) {
                if (value == null) {
                  return 'Please select a species';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _birthDateController,
              enabled: !_isSaving,
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.]'),
                ),
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Birth date',
                hintText: 'DD.MM.YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: _validateDate,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _isSaving ? null : _savePet,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : _isEditing
                        ? 'Update Pet'
                        : 'Save Pet',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
