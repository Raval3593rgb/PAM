
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/mock_pet_repository.dart';
import 'data/repositories/pet_repository.dart';
import 'models/pet_model.dart';
import 'router.dart';

void main() {
  final petRepository = MockPetRepository();

  runApp(
    MultiProvider(
      providers: [
        Provider<MockPetRepository>.value(
          value: petRepository,
        ),
        Provider<PetRepository>.value(
          value: petRepository,
        ),
        ChangeNotifierProvider(
          create: (_) => PetModel(petRepository)..load(),
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
