import 'package:flutter/material.dart';

class VetVisitFormScreen extends StatelessWidget {
  const VetVisitFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vet Visit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'DD.MM.YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              decoration: InputDecoration(
                labelText: 'Reason',
                prefixIcon: Icon(Icons.help_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Diagnosis',
                prefixIcon: Icon(Icons.medical_information),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Cost',
                suffixText: 'MDL',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Save Visit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}