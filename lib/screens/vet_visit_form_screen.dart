
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/mock_data.dart' show VetVisit;
import '../models/vet_visit_model.dart';

class VetVisitFormScreen extends StatefulWidget {
  const VetVisitFormScreen({
    super.key,
    required this.petId,
    this.visitId,
  });

  final int petId;
  final int? visitId;

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

  VetVisit? _editingVisit;
  bool _initialized = false;
  bool _isSaving = false;

  bool get _isEditing => widget.visitId != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (_isEditing) {
      _editingVisit = context
          .read<VetVisitModel>()
          .byId(widget.visitId!);

      if (_editingVisit != null &&
          _editingVisit!.petId == widget.petId) {
        _dateController.text = _editingVisit!.date;
        _reasonController.text = _editingVisit!.reason;
        _diagnosisController.text = _editingVisit!.diagnosis;
        _costController.text =
            _editingVisit!.cost.toStringAsFixed(2);
      } else {
        _editingVisit = null;
      }
    }
  }

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

  Future<void> _saveVisit() async {
    if (_isSaving) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final visit = VetVisit(
      id: _editingVisit?.id ?? 0,
      petId: widget.petId,
      date: _dateController.text.trim(),
      reason: _reasonController.text.trim(),
      diagnosis: _diagnosisController.text.trim(),
      cost: double.parse(_costController.text.trim()),
    );

    final model = context.read<VetVisitModel>();

    final String? error;

    if (_isEditing) {
      error = await model.update(visit);
    } else {
      error = await model.add(visit);
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing
              ? 'Vet visit updated successfully!'
              : 'Vet visit added successfully!',
        ),
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && _editingVisit == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Visit not found'),
        ),
        body: const Center(
          child: Text('This vet visit does not exist'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Vet Visit' : 'Add Vet Visit',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _dateController,
              enabled: !_isSaving,
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
              enabled: !_isSaving,
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
              enabled: !_isSaving,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Diagnosis',
                prefixIcon: Icon(Icons.medical_information),
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
              enabled: !_isSaving,
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

                if (cost == null || !cost.isFinite) {
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
              onPressed: _isSaving ? null : _saveVisit,
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                _isSaving
                    ? 'Saving...'
                    : _isEditing
                        ? 'Update Visit'
                        : 'Save Visit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
