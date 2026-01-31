import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final String reportId;
  final bool isAdmin;

  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    required this.isAdmin,
  });

  @override
  State<AdminReportDetailScreen> createState() =>
      _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  DocumentSnapshot? _reportSnapshot;
  bool _isLoading = true;

  List<QueryDocumentSnapshot> _applications = [];
  Map<String, Map<String, dynamic>> _firms = {};

  final List<String> _statuses = [
    'Submitted',
    'Review',
    'In Progress',
    'Completed',
    'Archived'
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  
  String _fmt(dynamic ts) {
    final l10n = AppLocalizations.of(context)!;
    if (ts == null) return l10n.unknown;
    try {
      final d = (ts as Timestamp).toDate();
      return "${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}";
    } catch (e, stack) {
      debugPrint('AdminReportDetailScreen: failed to format timestamp: $e');
      debugPrintStack(stackTrace: stack);
      return l10n.unknown;
    }
  }

  
  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    final reportDoc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .get();

    final data = reportDoc.data() as Map<String, dynamic>;

    List<QueryDocumentSnapshot> applications = [];
    Map<String, Map<String, dynamic>> firms = {};

    if (data[FirestoreReportFields.sentToFirms] == true) {
      final apps = await FirebaseFirestore.instance
          .collection(FirestoreCollections.firmApplications)
          .where('reportId', isEqualTo: widget.reportId)
          .get();

      applications = apps.docs;

      final ids = apps.docs.map((d) => d['firmId'] as String).toList();

      if (ids.isNotEmpty) {
        final firmsSnapshot = await FirebaseFirestore.instance
            .collection(FirestoreCollections.firms)
            .where(FieldPath.documentId, whereIn: ids)
            .get();

        for (final f in firmsSnapshot.docs) {
          firms[f.id] = f.data() as Map<String, dynamic>;
        }
      }
    }

    setState(() {
      _reportSnapshot = reportDoc;
      _applications = applications;
      _firms = firms;
      _isLoading = false;
    });
  }

  
  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .update({'status': newStatus});

    await _loadReport();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.statusUpdated)));
  }

  
  Future<void> _archiveReport() async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .update({'status': 'Archived'});

    await _loadReport();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.reportArchived)));
  }

  
  Future<void> _sendToFirms() async {
    await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .update({
      FirestoreReportFields.sentToFirms: true,
      FirestoreReportFields.sentAt: Timestamp.now(),
      'status': 'Review'
    });

    await _loadReport();
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l10n.sendToFirms)));
  }

  
  Future<void> _selectFirm(String appId) async {
    final appDoc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firmApplications)
        .doc(appId)
        .get();

    final appData = appDoc.data() as Map<String, dynamic>;

    final String firmId = appData['firmId'];
    final dynamic deadline = appData[FirestoreFirmApplicationFields.deadline];

    
    final reportDoc = await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .get();

    final reportData = reportDoc.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance
        .collection(FirestoreCollections.reports)
        .doc(widget.reportId)
        .update({
      FirestoreReportFields.selectedApplicationId: appId,
      FirestoreReportFields.assignedFirmId: firmId,
      FirestoreFirmApplicationFields.deadline: deadline,
      'status': 'In Progress',
      FirestoreReportFields.sentToFirms: true,
    });

    
    await FirebaseFirestore.instance.collection(FirestoreCollections.firmHistory).add({
      FirestoreFirmHistoryFields.firmId: firmId,
      FirestoreFirmHistoryFields.reportId: widget.reportId,

      
      FirestoreFirmHistoryFields.title: reportData[FirestoreReportFields.title],
      FirestoreFirmHistoryFields.category: reportData[FirestoreReportFields.category],

      FirestoreFirmHistoryFields.type: 'assigned',
      FirestoreFirmHistoryFields.timestamp: Timestamp.now(),
    });

    await _loadReport();

    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.firmSelected)),
    );
  }


  
  void _showFullImage(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(url, fit: BoxFit.contain),
              ),
            ),
          ),
        ),
      ),
    );
  }

  
  Widget _card({required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      margin: const EdgeInsets.only(bottom: 22),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _tag(IconData icon, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.grey[800]?.withOpacity(0.5) 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: 18, 
            color: isDark ? Colors.grey[400] : Colors.grey[700],
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _firmAvatar(Map<String, dynamic> firmData) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logo = firmData[FirestoreFirmFields.logoUrl];
    final name = firmData[FirestoreFirmFields.name] ?? l10n.firm;
    final letter = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 48,
        height: 48,
        color: isDark ? Colors.grey[800] : Colors.grey.shade200,
        child: logo != null && logo.toString().isNotEmpty
            ? Image.network(logo, fit: BoxFit.cover)
            : Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = _reportSnapshot!.data() as Map<String, dynamic>;
    final images = (data[FirestoreReportFields.images] as List<dynamic>).cast<String>();
    final sentToFirms = data[FirestoreReportFields.sentToFirms] == true;
    final selectedAppId = data[FirestoreReportFields.selectedApplicationId];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              data[FirestoreReportFields.title] ?? l10n.report,
              style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            );
          },
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.description,
                        style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['description'] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                    ],
                  ),
                );
              },
            ),

            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.category,
                        style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data['category'] ?? "",
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                    ],
                  ),
                );
              },
            ),

            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.room,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data['room']?.toString() ?? "",
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            if (images.isNotEmpty)
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.photos,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: GestureDetector(
                                onTap: () => _showFullImage(images[i]),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    images[i],
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            
            if (widget.isAdmin)
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.adminActions,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color:
                                isDark ? Colors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 18),

                    DropdownButtonFormField<String>(
                      value: data['status'],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? theme.cardColor : Colors.white,
                        labelText: l10n.changeStatus,
                        labelStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.black87,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      items: _statuses
                          .map((s) {
                            String label;
                            switch (s) {
                              case "Submitted":
                                label = l10n.submitted;
                                break;
                              case "Review":
                                label = l10n.review;
                                break;
                              case "In Progress":
                                label = l10n.inProgress;
                                break;
                              case "Completed":
                                label = l10n.completed;
                                break;
                              case "Archived":
                                label = l10n.archived;
                                break;
                              default:
                                label = s;
                            }
                            return DropdownMenuItem(
                              value: s,
                              child: Text(label),
                            );
                          })
                          .toList(),
                      onChanged: (v) {
                        if (v != null) _updateStatus(v);
                      },
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _archiveReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: Text(
                          l10n.archiveReport,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    if (data[FirestoreReportFields.sentToFirms] != true) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _sendToFirms,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            l10n.sendToFirms,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                      ],
                    ),
                  );
              },
            ),

            
            if (widget.isAdmin && sentToFirms)
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        l10n.firmApplications,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (_applications.isEmpty)
                        Text(
                          l10n.noApplicationsYet,
                          style: TextStyle(
                            color: isDark ? Colors.grey[400] : Colors.black54,
                          ),
                        ),

                      ..._applications.map((app) {
                        final appData = app.data() as Map<String, dynamic>;
                        final isWinner = selectedAppId == app.id;

                        final firmId = appData['firmId'];
                        final firmData = _firms[firmId] ?? {};
                        final firmName = firmData[FirestoreFirmFields.name] ?? l10n.unknownFirm;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 22),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: isDark ? theme.cardColor : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(
                              color: isWinner ? Colors.green : Colors.transparent,
                              width: isWinner ? 2.2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _firmAvatar(firmData),
                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Text(
                                      firmName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                        color: isWinner
                                            ? Colors.green
                                            : (isDark ? Colors.white : theme.colorScheme.onSurface),
                                      ),
                                    ),
                                  ),

                                  if (isWinner)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Text(
                                        l10n.selected,
                                        style: TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),

                              const SizedBox(height: 18),

                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  _tag(Icons.attach_money,
                                      "${l10n.price}: \$${appData[FirestoreFirmApplicationFields.price]}"),
                                  _tag(Icons.timer,
                                      "${l10n.deadline}: ${_fmt(appData[FirestoreFirmApplicationFields.deadline])}"),
                                  _tag(Icons.group,
                                      "${l10n.workers}: ${appData[FirestoreFirmApplicationFields.workersCount]}"),
                                ],
                              ),

                              const SizedBox(height: 16),

                              if (appData[FirestoreFirmApplicationFields.comment] != null &&
                                  appData[FirestoreFirmApplicationFields.comment].toString().isNotEmpty)
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark 
                                        ? Colors.grey[800]?.withOpacity(0.5) 
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    appData[FirestoreFirmApplicationFields.comment],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: isDark ? Colors.white70 : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),

                              if (widget.isAdmin &&
                                  selectedAppId == null &&
                                  !isWinner)
                                Container(
                                  margin: const EdgeInsets.only(top: 18),
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => _selectFirm(app.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: Text(
                                      l10n.selectFirm,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),
                    ],
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}

