
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class VetVisitFormScreen extends StatefulWidget {
  const VetVisitFormScreen({super.key});

  @override
  State<VetVisitFormScreen> createState() =>
      _VetVisitFormScreenState();
}

class _VetVisitFormScreenState
    extends State<VetVisitFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _dateController = TextEditingController();
  final _reasonController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _costController = TextEditingController();

  @override
  void dispose() {
    _dateController.dispose();
    _reasonController.dispose();
    _diagnosisController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String? _validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Visit date is required';
    }

    final match = RegExp(
      r'^(\d{2})\.(\d{2})\.(\d{4})$',
    ).firstMatch(value.trim());

    if (match == null) {
      return 'Use DD.MM.YYYY';
    }

    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);

    final date = DateTime(year, month, day);

    if (date.day != day ||
        date.month != month ||
        date.year != year) {
      return 'Invalid date';
    }

    if (date.isAfter(DateTime.now())) {
      return 'Visit date cannot be in the future';
    }

    return null;
  }

  void _saveVisit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vet visit validated successfully'),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vet Visit'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _dateController,
              keyboardType: TextInputType.datetime,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.]'),
                ),
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: const InputDecoration(
                labelText: 'Visit date',
                hintText: 'DD.MM.YYYY',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: _validateDate,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _reasonController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Reason',
                prefixIcon: Icon(Icons.help_outline),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Reason is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _diagnosisController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                prefixIcon: Icon(
                  Icons.medical_information,
                ),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Diagnosis is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _costController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                  RegExp(r'[0-9.]'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Cost',
                suffixText: 'MDL',
                prefixIcon: Icon(Icons.payments),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final cost = double.tryParse(value ?? '');

                if (cost == null) {
                  return 'Enter a valid number';
                }

                if (cost <= 0) {
                  return 'Cost must be greater than zero';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _saveVisit,
              icon: const Icon(Icons.save),
              label: const Text('Save Visit'),
            ),
          ],
        ),
      ),
    );
  }
}
