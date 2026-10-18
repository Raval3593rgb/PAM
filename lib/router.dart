import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/vet_visit_form_screen.dart';
import 'screens/vaccination_calendar_screen.dart';
import 'screens/profile_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetsScreen(),
      routes: [
        GoRoute(
          path: 'new',
          builder: (context, state) => const PetFormScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '');

            Pet? selectedPet;

            for (final pet in mockPets) {
              if (pet.id == id) {
                selectedPet = pet;
                break;
              }
            }

            if (selectedPet == null) {
              return const Scaffold(body: Center(child: Text('Pet not found')));
            }

            return PetDetailsScreen(pet: selectedPet);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/visits/new',
      builder: (context, state) => const VetVisitFormScreen(),
    ),
    GoRoute(
      path: '/vaccinations',
      builder: (context, state) => const VaccinationCalendarScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);
