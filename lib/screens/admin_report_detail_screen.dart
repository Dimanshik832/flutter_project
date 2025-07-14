import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminReportDetailScreen extends StatefulWidget {
  final String reportId;
  final bool isAdmin;

  const AdminReportDetailScreen({
    super.key,
    required this.reportId,
    required this.isAdmin,
  });

  @override
  State<AdminReportDetailScreen> createState() => _AdminReportDetailScreenState();
}

class _AdminReportDetailScreenState extends State<AdminReportDetailScreen> {
  DocumentSnapshot? _reportSnapshot;
  bool _isLoading = true;
  List<QueryDocumentSnapshot> _applications = [];
  Map<String, String> _firmNames = {};
  final List<String> _statuses = ['Submitted', 'Review', 'In Progress', 'Completed', 'Archived'];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);

    final reportDoc = await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).get();
    final data = reportDoc.data() as Map<String, dynamic>;

    List<QueryDocumentSnapshot> applications = [];
    Map<String, String> firmNames = {};

    if (data['sentToFirms'] == true) {
      final appsSnap = await FirebaseFirestore.instance
          .collection('firmApplications')
          .where('reportId', isEqualTo: widget.reportId)
          .get();
      applications = appsSnap.docs;

      final firmIds = appsSnap.docs.map((doc) => doc['firmId'] as String).toSet().toList();

      if (firmIds.isNotEmpty) {
        final firmsSnap = await FirebaseFirestore.instance
            .collection('firms')
            .where(FieldPath.documentId, whereIn: firmIds)
            .get();
        for (final firm in firmsSnap.docs) {
          firmNames[firm.id] = firm['name'];
        }
      }
    }

    setState(() {
      _reportSnapshot = reportDoc;
      _applications = applications;
      _firmNames = firmNames;
      _isLoading = false;
    });
  }

  Future<void> _updateStatus(String newStatus) async {
    await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).update({'status': newStatus});
    await _loadReport();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Status updated')));
  }

  Future<void> _archiveReport() async {
    await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).update({'status': 'Archived'});
    await _loadReport();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report archived')));
  }

  Future<void> _sendToFirms() async {
    await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).update({
      'sentToFirms': true,
      'sentAt': Timestamp.now(),
    });
    await _loadReport();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report sent to firms')));
  }

  Future<void> _selectWinner(String applicationId) async {
    await FirebaseFirestore.instance.collection('reports').doc(widget.reportId).update({
      'selectedApplicationId': applicationId,
      'status': 'In Progress',
    });
    await _loadReport();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Winner selected')));
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: InteractiveViewer(
          child: Image.network(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final data = _reportSnapshot!.data() as Map<String, dynamic>;
    final images = (data['images'] as List<dynamic>).cast<String>();
    final sentToFirms = data['sentToFirms'] == true;
    final selectedApplicationId = data['selectedApplicationId'];

    final isWinnerFirm = _applications.any((app) => app.id == selectedApplicationId);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: ${data['title']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Description: ${data['description']}'),
            const SizedBox(height: 8),
            Text('Room Number: ${data['roomNumber']}'),
            const SizedBox(height: 8),
            Text('Category: ${data['category']}'),
            const SizedBox(height: 8),
            Text('Status: ${data['status']}'),
            const SizedBox(height: 8),
            if (widget.isAdmin)
              Text('User Email: ${data['userEmail'] ?? 'Unknown'}'),
            const SizedBox(height: 16),
            if (images.isNotEmpty) ...[
              const Text('Photos:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _showFullImage(images[index]),
                        child: Image.network(
                          images[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.isAdmin) ...[
              DropdownButtonFormField<String>(
                value: data['status'],
                items: _statuses.map((status) {
                  return DropdownMenuItem(value: status, child: Text(status));
                }).toList(),
                onChanged: (val) {
                  if (val != null) _updateStatus(val);
                },
                decoration: const InputDecoration(labelText: 'Change Status'),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.archive),
                label: const Text('Archive Report'),
                onPressed: _archiveReport,
              ),
              const SizedBox(height: 16),
              if (!sentToFirms)
                ElevatedButton.icon(
                  icon: const Icon(Icons.send),
                  label: const Text('Send to Firms'),
                  onPressed: _sendToFirms,
                ),
            ],
            if (sentToFirms && (widget.isAdmin || isWinnerFirm)) ...[
              const Divider(height: 40),
              const Text('Firm Applications:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_applications.isEmpty)
                const Text('No applications submitted yet.')
              else
                ..._applications.map((app) {
                  final appData = app.data() as Map<String, dynamic>;
                  final isWinner = selectedApplicationId == app.id;
                  final firmName = _firmNames[appData['firmId']] ?? 'Unknown Firm';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('$firmName ${isWinner ? '✅' : ''}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Price: \$${appData['price']}'),
                          Text('Deadline: ${appData['deadline']}'),
                          Text('Workers: ${appData['workersCount']}'),
                          if (appData['comment'] != null && appData['comment'].toString().trim().isNotEmpty)
                            Text('Comment: ${appData['comment']}'),
                        ],
                      ),
                      trailing: isWinner
                          ? const Text('Winner', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                          : widget.isAdmin && selectedApplicationId == null
                          ? TextButton(
                        onPressed: () => _selectWinner(app.id),
                        child: const Text('Select Winner'),
                      )
                          : null,
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }
}
