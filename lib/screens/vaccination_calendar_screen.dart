
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pet_model.dart';
import '../models/vaccination_model.dart';
import '../widgets/error_view.dart';

class VaccinationCalendarScreen extends StatelessWidget {
  const VaccinationCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaccinationModel = context.watch<VaccinationModel>();
    final petModel = context.watch<PetModel>();

    final vaccinations = vaccinationModel.vaccinations;

    final isLoading =
        vaccinationModel.isLoading || petModel.isLoading;

    final error =
        vaccinationModel.error ?? petModel.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaccination Calendar'),
        actions: [
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    context.read<VaccinationModel>().load();
                    context.read<PetModel>().load();
                  },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Vaccinations',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? ErrorView(
                  message: error,
                  onRetry: () {
                    context.read<VaccinationModel>().load();
                    context.read<PetModel>().load();
                  },
                )
              : vaccinations.isEmpty
                  ? const Center(
                      child: Text('No vaccinations found'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: vaccinations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final vaccination =
                            vaccinations[index];

                        final pet = petModel.byId(
                          vaccination.petId,
                        );

                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.vaccines),
                            ),
                            title: Text(vaccination.name),
                            subtitle: Text(
                              '${pet?.name ?? 'Unknown pet'}'
                              ' · ${pet?.species ?? 'Unknown'}\n'
                              'Last vaccination: '
                              '${vaccination.date}\n'
                              'Next due: '
                              '${vaccination.nextDueDate}',
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
    );
  }
}
