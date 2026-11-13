
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../lib/data/repositories/mock_pet_repository.dart';
import '../lib/models/pet_model.dart';
import '../lib/screens/pet_screen.dart';

void main() {
  testWidgets(
    'PetCare loads pets from repository',
    (WidgetTester tester) async {
      final repository = MockPetRepository();
      final petModel = PetModel(repository);

      await tester.pumpWidget(
        ChangeNotifierProvider<PetModel>.value(
          value: petModel,
          child: const MaterialApp(
            home: PetsScreen(),
          ),
        ),
      );

      // Start loading pets from MockRepository.
      petModel.load();

      await tester.pump();

      // Check loading state.
      expect(
        find.byType(CircularProgressIndicator),
        findsOneWidget,
      );

      // Simulate repository delay (800 ms).
      await tester.pump(
        const Duration(milliseconds: 900),
      );
      await tester.pump();

      // Check loaded pets.
      expect(find.text('Barsik'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    },
  );
}
