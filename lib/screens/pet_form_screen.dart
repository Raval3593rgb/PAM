import 'package:flutter/material.dart';

class PetFormScreen extends StatelessWidget {
  const PetFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Pet'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(
                Icons.pets,
                size: 50,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.photo_camera),
              label: const Text('Choose photo'),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Pet name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const DropdownMenu<String>(
              label: Text('Species'),
              dropdownMenuEntries: [
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
                DropdownMenuEntry(
                  value: 'Other',
                  label: 'Other',
                ),
              ],
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Birth date',
                hintText: 'DD.MM.YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Save Pet'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}