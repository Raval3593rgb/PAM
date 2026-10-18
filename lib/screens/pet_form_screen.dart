
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key});

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();

  String? _selectedSpecies;

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

  void _savePet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pet ${_nameController.text.trim()} validated successfully',
        ),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
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
              onPressed: () {
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
              onChanged: (value) {
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
              onPressed: _savePet,
              icon: const Icon(Icons.save),
              label: const Text('Save Pet'),
            ),
          ],
        ),
      ),
    );
  }
}
