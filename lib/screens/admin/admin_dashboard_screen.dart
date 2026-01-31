import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'admin_reports_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}




enum _TimeRange { all, d7, d30, d90 }

extension _TimeRangeExt on _TimeRange {
  String label(AppLocalizations l10n) {
    switch (this) {
      case _TimeRange.all:
        return l10n.allTime;
      case _TimeRange.d7:
        return l10n.last7Days;
      case _TimeRange.d30:
        return l10n.last30Days;
      case _TimeRange.d90:
        return l10n.last90Days;
    }
  }

  int? get days {
    switch (this) {
      case _TimeRange.all:
        return null;
      case _TimeRange.d7:
        return 7;
      case _TimeRange.d30:
        return 30;
      case _TimeRange.d90:
        return 90;
    }
  }
}




class _DashboardData {
  final int totalReports;
  final int submitted;
  final int review;
  final int inProgress;
  final int completed;
  final int archived;

  final List<int> chartBuckets;
  final List<String> chartLabels;
  final int? daysRange;

  final Map<String, int> categoryStats;

  _DashboardData({
    required this.totalReports,
    required this.submitted,
    required this.review,
    required this.inProgress,
    required this.completed,
    required this.archived,
    required this.chartBuckets,
    required this.chartLabels,
    required this.daysRange,
    required this.categoryStats,
  });
}




class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  _TimeRange _timeRange = _TimeRange.all;
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Color _generateColor(int index, int total) {
    final hue = (360.0 / total) * index;
    return HSVColor.fromAHSV(1, hue, 0.65, 0.95).toColor();
  }

  
  
  
  Future<_DashboardData> _loadData() async {
    final now = DateTime.now();
    final rangeDays = _timeRange.days;

    final DateTime? fromDate =
    rangeDays != null ? now.subtract(Duration(days: rangeDays)) : null;

    Query query = FirebaseFirestore.instance.collection(FirestoreCollections.reports);

    if (fromDate != null) {
      query = query.where(FirestoreReportFields.createdAt,
        isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate),
      );
    }

    final snap = await query.get();

    int submitted = 0;
    int review = 0;
    int inProgress = 0;
    int completed = 0;
    int archived = 0;

    final Map<String, int> categoryStats = {};

    late List<int> buckets;
    late List<String> labels;

    
    
    
    if (_timeRange == _TimeRange.d7) {
      buckets = List.filled(7, 0);
      labels = List.generate(7, (i) {
        final d = now.subtract(Duration(days: 6 - i));
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        return DateFormat.E(localeTag).format(d);
      });

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final created = _dateOnly(ts.toDate());
        final diff = now.difference(created).inDays;

        if (diff >= 0 && diff < 7) {
          buckets[6 - diff]++;
        }
      }
    }

    
    
    
    else if (_timeRange == _TimeRange.d30) {
      buckets = List.filled(5, 0);
      labels = const ['01–07', '08–14', '15–21', '22–28', '29–31'];

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final day = ts.toDate().day;
        int index = (day - 1) ~/ 7;
        if (index < 0) index = 0;
        if (index > 4) index = 4;

        buckets[index]++;
      }
    }

    
    
    
    else if (_timeRange == _TimeRange.d90) {
      final months = List.generate(3, (i) {
        return DateTime(now.year, now.month - 2 + i);
      });

      labels = months.map((m) {
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        return DateFormat.MMMM(localeTag).format(m);
      }).toList();

      buckets = List.filled(3, 0);

      for (final doc in snap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final created = ts.toDate();

        for (int i = 0; i < months.length; i++) {
          if (created.year == months[i].year &&
              created.month == months[i].month) {
            buckets[i]++;
          }
        }
      }
    }
    


    else {
    final Map<int, int> yearMap = {};

    for (final doc in snap.docs) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data[FirestoreReportFields.createdAt];
    if (ts is! Timestamp) continue;

    final year = ts.toDate().year;
    yearMap[year] = (yearMap[year] ?? 0) + 1;
    }

    final years = yearMap.keys.toList()..sort();

    labels = years.map((y) => y.toString()).toList();
    buckets = years.map((y) => yearMap[y]!).toList();
    }




    
    
    
    for (final doc in snap.docs) {
      final data = doc.data() as Map<String, dynamic>;

      switch ((data['status'] ?? '').toString()) {
        case 'Submitted':
          submitted++;
          break;
        case 'Review':
          review++;
          break;
        case 'In Progress':
          inProgress++;
          break;
        case 'Completed':
          completed++;
          break;
        case 'Archived':
          archived++;
          break;
      }

      final category = (data['category'] ?? 'Other').toString();
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }

    return _DashboardData(
      totalReports: snap.size,
      submitted: submitted,
      review: review,
      inProgress: inProgress,
      completed: completed,
      archived: archived,
      chartBuckets: buckets,
      chartLabels: labels,
      daysRange: rangeDays,
      categoryStats: categoryStats,
    );
  }

  void _onTimeRangeSelected(_TimeRange range) {
    if (range == _timeRange) return;
    setState(() {
      _timeRange = range;
      _future = _loadData();
    });
  }

  
  
  
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          l10n.adminDashboard,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildTimeFilter()],
            ),
          ),
          Expanded(
            child: FutureBuilder<_DashboardData>(
              future: _future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildStatSection(data),
                      const SizedBox(height: 26),
                      _barChartCard(data),
                      const SizedBox(height: 26),
                      _pieChartCard(data.categoryStats),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildTimeFilter() {
    return PopupMenuButton<_TimeRange>(
      initialValue: _timeRange,
      onSelected: _onTimeRangeSelected,
      itemBuilder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return [
          for (final v in _TimeRange.values)
            PopupMenuItem(value: v, child: Text(v.label(l10n))),
        ];
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: _box(),
        child: Row(
          children: [
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
              _timeRange.label(l10n),
                  style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
                );
              },
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(_DashboardData data) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _statRow(
          _statCard('${l10n.reports} ${l10n.all}', '${data.totalReports}', Icons.list,
              Colors.blue, "All"),
          _statCard(l10n.submitted, '${data.submitted}', Icons.upload,
              Colors.deepPurple, "Submitted"),
        ),
        const SizedBox(height: 16),
        _statRow(
          _statCard(l10n.review, '${data.review}', Icons.rule, Colors.orange,
              "Review"),
          _statCard(l10n.inProgress, '${data.inProgress}', Icons.work_history,
              Colors.teal, "In Progress"),
        ),
        const SizedBox(height: 16),
        _statRow(
          _statCard(l10n.completed, '${data.completed}', Icons.check_circle,
              Colors.green, "Completed"),
          _statCard(l10n.archived, '${data.archived}', Icons.archive, Colors.grey,
              "Archived"),
        ),
      ],
    );
  }

  Widget _statRow(Widget a, Widget b) {
    return Row(
      children: [
        Expanded(child: a),
        const SizedBox(width: 16),
        Expanded(child: b),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color,
      String status) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AdminReportsScreen(initialStatus: status),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _box(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 16),
            Builder(
              builder: (context) {
                final theme = Theme.of(context);
                final isDark = theme.brightness == Brightness.dark;
                
                return Text(
              value,
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
              title,
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDark ? Colors.grey[400] : Colors.black54
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _barChartCard(_DashboardData data) {
    final buckets = data.chartBuckets;
    final labels = data.chartLabels;
    final maxValue = buckets.isEmpty ? 0 : buckets.reduce(max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return Text(
            '${l10n.reports} ${_timeRange.label(l10n)}',
                style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
              );
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(buckets.length, (i) {
                final value = buckets[i];
                final double barHeight =
                maxValue == 0 ? 8.0 : (value / maxValue) * 140.0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          
                          return Text(
                        value.toString(),
                            style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                          );
                        },
                      ),
                      const SizedBox(height: 6),

                      
                      Container(
                        height: max(8.0, barHeight),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),

                      
                      Builder(
                        builder: (context) {
                          final theme = Theme.of(context);
                          final isDark = theme.brightness == Brightness.dark;
                          
                          return Text(
                        labels[i],
                        textAlign: TextAlign.center,
                            style: TextStyle(
                          fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.black54,
                        ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }


  Widget _pieChartCard(Map<String, int> stats) {
    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            
            return Text(
              AppLocalizations.of(context)!.noReportsInSelectedPeriod,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54)
            );
          },
        ),
      );
    }

    final entries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final values = entries.map((e) => e.value.toDouble()).toList();
    final total = values.fold(0.0, (a, b) => a + b);
    final colors =
    List.generate(values.length, (i) => _generateColor(i, values.length));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final isDark = theme.brightness == Brightness.dark;
              
              return Text(
            AppLocalizations.of(context)!.categoriesBreakdown,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
                  color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
              );
            },
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _PieChartPainter(values: values, colors: colors),
              ),
            ),
          ),
          const SizedBox(height: 26),
          Column(
            children: List.generate(entries.length, (i) {
              final percent =
              total == 0 ? 0 : (entries[i].value / total * 100);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors[i],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Builder(
                      builder: (context) {
                        final theme = Theme.of(context);
                        final isDark = theme.brightness == Brightness.dark;
                        
                        return Text(
                      '${entries[i].key} — ${entries[i].value} (${percent.toStringAsFixed(0)}%)',
                          style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
                        );
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  BoxDecoration _box() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return BoxDecoration(
      color: isDark ? theme.cardColor : Colors.white,
      borderRadius: BorderRadius.circular(26),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}




class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double strokeWidth = 32;
    const double gap = 0.015;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final total = values.fold(0.0, (a, b) => a + b);
    double start = -pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 2 * pi - gap;
      if (sweep <= 0) continue;

      paint.color = colors[i];
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
