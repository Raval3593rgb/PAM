
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_api.dart';
import 'data/token_store.dart';

import 'data/file_api.dart';

import 'data/repositories/pet_repository.dart';
import 'data/repositories/vet_visit_repository.dart';
import 'data/repositories/vaccination_repository.dart';

import 'data/repositories/http_pet_repository.dart';
import 'data/repositories/http_vet_visit_repository.dart';
import 'data/repositories/http_vaccination_repository.dart';

import 'models/pet_model.dart';
import 'models/vet_visit_model.dart';
import 'models/vaccination_model.dart';

import 'router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Адрес сервера FastAPI
  const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  // JWT TokenStore
  final tokens = TokenStore();
  final loggedIn = await tokens.read() != null;

  initializeRouter(loggedIn: loggedIn);

  // При HTTP 401 возвращаемся на Login
  void onUnauthorized() {
    appRouter.go('/login');
  }

  // Настоящие HTTP Repository
  final petRepository = HttpPetRepository(
    apiBaseUrl,
    tokens,
    onUnauthorized: onUnauthorized,
  );

  final vetVisitRepository = HttpVetVisitRepository(
    apiBaseUrl,
    tokens,
    onUnauthorized: onUnauthorized,
  );

  final vaccinationRepository = HttpVaccinationRepository(
    apiBaseUrl,
    tokens,
    onUnauthorized: onUnauthorized,
  );

  runApp(
    MultiProvider(
      providers: [
        // Авторизация
        Provider<TokenStore>.value(value: tokens),

        Provider<FileApi>(
          create: (_) => FileApi(
            apiBaseUrl,
            tokens,
            onUnauthorized: onUnauthorized,
          ),
        ),

        Provider<AuthApi>(
          create: (_) => AuthApi(apiBaseUrl, tokens),
        ),

        // HTTP Repository через интерфейсы L4
        Provider<PetRepository>.value(
          value: petRepository,
        ),

        Provider<VetVisitRepository>.value(
          value: vetVisitRepository,
        ),

        Provider<VaccinationRepository>.value(
          value: vaccinationRepository,
        ),

        // State Management
        ChangeNotifierProvider<PetModel>(
          create: (_) => PetModel(petRepository)..load(),
        ),

        ChangeNotifierProvider<VetVisitModel>(
          create: (_) =>
              VetVisitModel(vetVisitRepository)..load(),
        ),

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
