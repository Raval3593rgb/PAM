
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/pets',
              builder: (context, state) => const PetsScreen(),
              routes: [
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

                    if (id == null) {
                      return const Scaffold(
                        body: Center(
                          child: Text('Invalid pet ID'),
                        ),
                      );
                    }

                    return PetDetailsScreen(id: id);
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
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vaccinations',
              builder: (context, state) =>
                  const VaccinationCalendarScreen(),
            ),
          ],
        ),
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
