
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/mock_pet_repository.dart';
import '../models/pet_model.dart';
import '../data/auth_api.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _simulateError = false;

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'Are you sure you want to log out of PetCare?',
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
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true && context.mounted) {
  // Удаляем сохранённый JWT-токен
  await context.read<AuthApi>().logout();

  if (!context.mounted) return;

  // Возвращаем пользователя на экран входа
  context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final petModel = context.watch<PetModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 48,
              child: Icon(
                Icons.person,
                size: 52,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'PetCare User',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 24),

          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Name'),
                  subtitle: Text('Daniil'),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.email_outlined),
                  title: Text('Email'),
                  subtitle: Text('user@petcare.md'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Registered pets'),
              trailing: Text(
                '${petModel.pets.length}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.wifi_off),
              title: const Text('Simulate Network Error'),
              subtitle: const Text(
                'Test repository error handling',
              ),
              value: _simulateError,
              onChanged: (value) {
                setState(() {
                  _simulateError = value;
                });

                context
                    .read<MockPetRepository>()
                    .simulateError = value;
              },
            ),
          ),

          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
