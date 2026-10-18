import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PetCare')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.pets, size: 80, color: Colors.lightGreen),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Welcome to PetCare',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => context.go('/login'),
            child: const Text('Login'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/pets'),
            child: const Text('My Pets'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/pets/1'),
            child: const Text('Pet Details'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/pets/new'),
            child: const Text('Add Pet'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/visits/new'),
            child: const Text('Vet Visit'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/vaccinations'),
            child: const Text('Vaccination Calendar'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => context.push('/profile'),
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}
