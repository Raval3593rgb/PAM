import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import 'login_screen.dart';
import 'pet_screen.dart';
import 'pet_details_screen.dart';
import 'pet_form_screen.dart';
import 'vet_visit_form_screen.dart';
import 'vaccination_calendar_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCare'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
              );
            },
            child: const Text('Login'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetsScreen(),
                ),
              );
            },
            child: const Text('My Pets'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PetDetailsScreen(
                    pet: mockPets[0],
                  ),
                ),
              );
            },
            child: const Text('Pet Details'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PetFormScreen(),
                ),
              );
            },
            child: const Text('Add Pet'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VetVisitFormScreen(),
                ),
              );
            },
            child: const Text('Vet Visit'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const VaccinationCalendarScreen(),
                ),
              );
            },
            child: const Text('Vaccination Calendar'),
          ),

          const SizedBox(height: 12),

          FilledButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            child: const Text('Profile'),
          ),
        ],
      ),
    );
  }
}