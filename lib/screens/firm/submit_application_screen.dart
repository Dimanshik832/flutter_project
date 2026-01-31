import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/bottom_sheet_handle.dart';
import '../../services/firestore_paths.dart';

class SubmitApplicationScreen extends StatefulWidget {
  final String reportId;
  final String firmId;

  const SubmitApplicationScreen({
    super.key,
    required this.reportId,
    required this.firmId,
  });

  @override
  State<SubmitApplicationScreen> createState() =>
      _SubmitApplicationScreenState();
}

class _SubmitApplicationScreenState extends State<SubmitApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _priceController = TextEditingController();
  final _workersController = TextEditingController();
  final _commentController = TextEditingController();

  DateTime? _selectedDeadline;
  bool _attemptedSubmit = false;
  bool _isSubmitting = false;

  
  
  
  Future<void> _pickDeadline() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
      helpText: AppLocalizations.of(context)!.selectDeadline,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
      });
    }
  }

  
  
  
  Future<bool?> _showPreviewSheet() async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? theme.cardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: BottomSheetHandle(
                        width: 42,
                        height: 4.5,
                        radius: 20,
                        margin: EdgeInsets.only(bottom: 18),
                      ),
                    ),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                          AppLocalizations.of(context)!.previewApplication,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),

                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                          AppLocalizations.of(context)!.confirmDetailsBelow,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark ? Colors.grey[400] : Colors.grey.shade600,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),

                    
                    
                    
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.black12
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark = theme.brightness == Brightness.dark;
                              
                              return Row(
                                children: [
                                  const Icon(Icons.list_alt, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.applicationDetails,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          _previewRow(
                            AppLocalizations.of(context)!.price,
                            "${_priceController.text} USD",
                          ),
                          _previewRow(
                            AppLocalizations.of(context)!.deadline,
                            _selectedDeadline != null
                                ? "${_selectedDeadline!.day}.${_selectedDeadline!.month}.${_selectedDeadline!.year}"
                                : "-",
                          ),
                          _previewRow(
                            AppLocalizations.of(context)!.workers,
                            _workersController.text,
                          ),
                        ],
                      ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    
                    
                    
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isDark ? Colors.grey[700]! : Colors.black12
                            ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Builder(
                            builder: (context) {
                              final theme = Theme.of(context);
                              final isDark = theme.brightness == Brightness.dark;
                              
                              return Row(
                                children: [
                                  const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                                  const SizedBox(width: 8),
                                  Text(
                                    AppLocalizations.of(context)!.comment,
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 14),

                          Text(
                            _commentController.text.isEmpty
                                ? AppLocalizations.of(context)!.noComment
                                : _commentController.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.blue, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              AppLocalizations.of(context)!.cancel,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              AppLocalizations.of(context)!.submitApplication,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _previewRow(String label, String value) {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text(
                "$label:",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? Colors.white70 : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  
  
  
  Future<void> _submit() async {
    setState(() => _attemptedSubmit = true);

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (_selectedDeadline == null) {
      setState(() {});
      return;
    }

    final confirmed = await _showPreviewSheet();
    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    await FirebaseFirestore.instance.collection(FirestoreCollections.firmApplications).add({
      "firmId": widget.firmId,
      "reportId": widget.reportId,
      FirestoreFirmApplicationFields.price: double.parse(_priceController.text.trim()),
      FirestoreFirmApplicationFields.workersCount: int.parse(_workersController.text.trim()),
      FirestoreFirmApplicationFields.deadline: Timestamp.fromDate(_selectedDeadline!),
      FirestoreFirmApplicationFields.comment: _commentController.text.trim(),
      FirestoreFirmApplicationFields.createdAt: Timestamp.now(),
    });

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final showPriceError = _attemptedSubmit && _priceController.text.isEmpty;
    final showWorkersError = _attemptedSubmit && _workersController.text.isEmpty;
    final showDeadlineError = _attemptedSubmit && _selectedDeadline == null;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.submitApplication,
          style: TextStyle(
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              
              _inputCard(
                child: TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.proposedPrice,
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: showPriceError
                          ? const Color(0xFFBA1A1A)
                          : (isDark ? Colors.grey[400] : Colors.black87),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "" : null,
                ),
              ),
              const SizedBox(height: 16),

              
              _inputCard(
                child: TextFormField(
                  controller: _workersController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: l10n.numberOfWorkers,
                    border: InputBorder.none,
                    labelStyle: TextStyle(
                      color: showWorkersError
                          ? const Color(0xFFBA1A1A)
                          : (isDark ? Colors.grey[400] : Colors.black87),
                    ),
                  ),
                  validator: (v) => v!.isEmpty ? "" : null,
                ),
              ),
              const SizedBox(height: 16),

              
              GestureDetector(
                onTap: _pickDeadline,
                child: _inputCard(
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_month,
                        color: showDeadlineError
                            ? const Color(0xFFBA1A1A)
                            : Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _selectedDeadline == null
                              ? l10n.selectDeadline
                              : "${_selectedDeadline!.day}.${_selectedDeadline!.month}.${_selectedDeadline!.year}",
                          style: TextStyle(
                            fontSize: 16,
                            color: showDeadlineError
                                ? const Color(0xFFBA1A1A)
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              
              _inputCard(
                child: Builder(
                  builder: (context) {
                    final theme = Theme.of(context);
                    final isDark = theme.brightness == Brightness.dark;
                    
                    return TextFormField(
                      controller: _commentController,
                      maxLines: 3,
                      style: TextStyle(
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                      decoration: InputDecoration(
                        labelText: l10n.commentOptional,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black87,
                        ),
                        border: InputBorder.none,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: _isSubmitting ? null : _submit,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      _isSubmitting
                          ? l10n.submitting
                          : l10n.submitApplication,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputCard({
    required Widget child,
    Color borderColor = Colors.transparent,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: child,
    );
  }
}
