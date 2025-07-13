import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubmitApplicationScreen extends StatefulWidget {
  final String reportId;
  final String firmId;

  const SubmitApplicationScreen({
    super.key,
    required this.reportId,
    required this.firmId,
  });

  @override
  State<SubmitApplicationScreen> createState() => _SubmitApplicationScreenState();
}

class _SubmitApplicationScreenState extends State<SubmitApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _workersCountController = TextEditingController();
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    await FirebaseFirestore.instance.collection('firmApplications').add({
      'firmId': widget.firmId,
      'reportId': widget.reportId,
      'price': double.parse(_priceController.text),
      'deadline': _deadlineController.text.trim(),
      'workersCount': int.parse(_workersCountController.text),
      'comment': _commentController.text.trim(),
      'createdAt': Timestamp.now(),
    });

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Application submitted')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Application')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Proposed Price (USD)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deadlineController,
                decoration: const InputDecoration(labelText: 'Deadline (e.g. 5 days)'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workersCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of Workers'),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Comment (optional)'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
