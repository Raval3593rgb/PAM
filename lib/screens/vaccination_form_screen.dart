import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/result.dart';
import '../data/repositories/vaccination_repository.dart';
import '../models/vaccination.dart';
import '../models/vaccination_model.dart';

class VaccinationFormScreen extends StatefulWidget {
  const VaccinationFormScreen({
    super.key,
    required this.petId,
    this.existing,
  });

  final int petId;
  final Vaccination? existing;

  @override
  State<VaccinationFormScreen> createState() =>
      _VaccinationFormScreenState();
}

class _VaccinationFormScreenState extends State<VaccinationFormScreen> {
  final _nameController = TextEditingController();

  DateTime _date = DateTime.now();
  DateTime _nextDueDate = DateTime.now().add(const Duration(days: 365));

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    if (existing != null) {
      _nameController.text = existing.name;
      _date = DateTime.tryParse(existing.date) ?? DateTime.now();
      _nextDueDate = DateTime.tryParse(existing.nextDueDate) ??
          DateTime.now().add(const Duration(days: 365));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate({required bool nextDue}) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: nextDue ? _nextDueDate : _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (selected == null || !mounted) return;

    setState(() {
      if (nextDue) {
        _nextDueDate = selected;
      } else {
        _date = selected;
      }
    });
  }

  Future<void> _save() async {
    if (_saving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter vaccination name')),
      );
      return;
    }

    if (_nextDueDate.isBefore(_date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Next vaccination date cannot be earlier'),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    final vaccination = Vaccination.fromJson({
      'id': widget.existing?.id ?? 0,
      'petId': widget.petId,
      'name': name,
      'date': _formatDate(_date),
      'nextDueDate': _formatDate(_nextDueDate),
    });

    final repository = context.read<VaccinationRepository>();
    final Result<Vaccination> result = widget.existing == null
        ? await repository.create(vaccination)
        : await repository.update(vaccination);

    if (!mounted) return;

    if (result is Ok<Vaccination>) {
      await context.read<VaccinationModel>().load();
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      setState(() => _saving = false);
      if (result is Err<Vaccination>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.msg)),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Vaccination' : 'Add Vaccination'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Vaccination name',
              prefixIcon: Icon(Icons.vaccines),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Vaccination date'),
            subtitle: Text(_formatDate(_date)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _saving ? null : () => _selectDate(nextDue: false),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.event_available),
            title: const Text('Next vaccination'),
            subtitle: Text(_formatDate(_nextDueDate)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: _saving ? null : () => _selectDate(nextDue: true),
          ),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: Text(
              _saving
                  ? 'Saving...'
                  : isEditing
                      ? 'Update Vaccination'
                      : 'Save Vaccination',
            ),
          ),
        ],
      ),
    );
  }
}
