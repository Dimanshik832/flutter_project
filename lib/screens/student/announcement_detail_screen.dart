import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';




class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 5,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}




class AnnouncementDetailScreen extends StatelessWidget {
  final String title;
  final String text;
  final String? type;
  final DateTime? createdAt;
  final String? authorEmail;
  final List<String>? images;

  const AnnouncementDetailScreen({
    super.key,
    required this.title,
    required this.text,
    this.type,
    this.createdAt,
    this.authorEmail,
    this.images,
  });

  
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

  
  IconData _getIcon(String? type) {
    switch (type) {
      case "important":
        return Icons.error_outline;
      case "warning":
        return Icons.warning_amber_rounded;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final Color color = _getColor(type);

    final String formattedDate = createdAt != null
        ? DateFormat('yyyy-MM-dd • HH:mm').format(createdAt!)
        : l10n.unknown;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.announcement,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? theme.cardColor : Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              
              
              
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: color.withOpacity(0.15),
                    child: Icon(_getIcon(type), color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    (switch (type) {
                      "important" => l10n.important,
                      "warning" => l10n.warning,
                      _ => l10n.info,
                    })
                        .toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              
              
              
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),

              const SizedBox(height: 24),

              
              
              
              if (images != null && images!.isNotEmpty)
                Column(
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
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 130,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images!.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 12),
                        itemBuilder: (context, i) {
                          final url = images![i];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ImageViewerScreen(imageUrl: url),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: Image.network(
                                url,
                                width: 130,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),

              Text(
                l10n.details,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Icon(Icons.access_time_rounded,
                      size: 20, color: isDark ? Colors.grey[400] : Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.publishedAt(formattedDate),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              if (authorEmail != null)
                Row(
                  children: [
                    Icon(Icons.email_rounded,
                        size: 20, color: isDark ? Colors.grey[400] : Colors.grey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.authorWithEmail(authorEmail!),
                        style: TextStyle(
                          fontSize: 15, 
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
