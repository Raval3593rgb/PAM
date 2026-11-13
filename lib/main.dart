
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/mock_pet_repository.dart';
import 'data/repositories/pet_repository.dart';

import 'data/repositories/mock_vet_visit_repository.dart';
import 'data/repositories/vet_visit_repository.dart';

import 'data/repositories/mock_vaccination_repository.dart';
import 'data/repositories/vaccination_repository.dart';

import 'models/pet_model.dart';
import 'models/vet_visit_model.dart';
import 'models/vaccination_model.dart';

import 'router.dart';

void main() {
  final petRepository = MockPetRepository();
  final vetVisitRepository = MockVetVisitRepository();
  final vaccinationRepository = MockVaccinationRepository();

  runApp(
    MultiProvider(
      providers: [
        // Pet Repository
        Provider<MockPetRepository>.value(
          value: petRepository,
        ),
        Provider<PetRepository>.value(
          value: petRepository,
        ),

        // Vet Visit Repository
        Provider<MockVetVisitRepository>.value(
          value: vetVisitRepository,
        ),
        Provider<VetVisitRepository>.value(
          value: vetVisitRepository,
        ),

        // Vaccination Repository
        Provider<MockVaccinationRepository>.value(
          value: vaccinationRepository,
        ),
        Provider<VaccinationRepository>.value(
          value: vaccinationRepository,
        ),

        // Pet State Management
        ChangeNotifierProvider<PetModel>(
          create: (_) => PetModel(petRepository)..load(),
        ),

        // Vet Visit State Management
        ChangeNotifierProvider<VetVisitModel>(
          create: (_) =>
              VetVisitModel(vetVisitRepository)..load(),
        ),

        // Vaccination State Management
        ChangeNotifierProvider<VaccinationModel>(
          create: (_) =>
              VaccinationModel(vaccinationRepository)..load(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'PetCare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightGreen,
        ),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
