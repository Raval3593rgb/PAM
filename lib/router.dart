
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'data/mock_data.dart';
import 'screens/login_screen.dart';
import 'screens/pet_screen.dart';
import 'screens/pet_details_screen.dart';
import 'screens/pet_form_screen.dart';
import 'screens/vet_visit_form_screen.dart';
import 'screens/vaccination_calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'widgets/app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Login находится вне нижней панели.
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(
          navigationShell: navigationShell,
        );
      },
      branches: [
        // Вкладка 1: питомцы.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pets',
              builder: (context, state) =>
                  const PetsScreen(),
              routes: [
                // Фиксированный маршрут перед :id.
                GoRoute(
                  path: 'new',
                  builder: (context, state) =>
                      const PetFormScreen(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final id = int.tryParse(
                      state.pathParameters['id'] ?? '',
                    );

                    Pet? selectedPet;

                    for (final pet in mockPets) {
                      if (pet.id == id) {
                        selectedPet = pet;
                        break;
                      }
                    }

                    if (selectedPet == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Pet not found'),
                        ),
                      );
                    }

                    return PetDetailsScreen(
                      pet: selectedPet,
                    );
                  },
                  routes: [
                    GoRoute(
                      path: 'visits/new',
                      builder: (context, state) =>
                          const VetVisitFormScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        // Вкладка 2: календарь вакцинаций.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vaccinations',
              builder: (context, state) =>
                  const VaccinationCalendarScreen(),
            ),
          ],
        ),

        // Вкладка 3: профиль.
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) =>
                  const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
