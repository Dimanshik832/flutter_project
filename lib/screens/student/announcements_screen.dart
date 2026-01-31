import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'announcement_detail_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  
  Color _getColor(String? type) {
    switch (type) {
      case "important":
        return Colors.red;
      case "warning":
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.announcements,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),

      
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(FirestoreCollections.announcements)
            .orderBy(FirestoreAnnouncementFields.createdAt, descending: true)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                l10n.noAnnouncements,
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey, 
                  fontSize: 16,
                ),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final raw = docs[i].data();

              if (raw == null || raw is! Map<String, dynamic>) {
                return const SizedBox.shrink();
              }

              final data = raw;

              
              final String title = data[FirestoreAnnouncementFields.title] ?? l10n.untitled;
              final String text = data[FirestoreAnnouncementFields.text] ?? l10n.noDescription;
              final String type = data[FirestoreAnnouncementFields.type] ?? "info";

              final Timestamp? ts = data[FirestoreAnnouncementFields.createdAt];
              final DateTime? createdAt =
              ts != null ? ts.toDate() : null;

              final String? authorEmail = data[FirestoreAnnouncementFields.authorEmail];
              final String? authorId = data[FirestoreAnnouncementFields.authorId];

              final List<String> images =
              data[FirestoreAnnouncementFields.images] != null
                  ? List<String>.from(data[FirestoreAnnouncementFields.images])
                  : [];

              final String announcementId = docs[i].id;

              final color = _getColor(type);

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnnouncementDetailScreen(
                        title: title,
                        text: text,
                        type: type,
                        createdAt: createdAt,
                        authorEmail: authorEmail,
                        images: images,
                      ),
                    ),
                  );
                },

                child: Container(
                  margin: const EdgeInsets.only(bottom: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isDark ? theme.cardColor : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: color.withOpacity(0.12),
                        child: Icon(Icons.notifications, color: color, size: 20),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              text,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.grey[400] : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
