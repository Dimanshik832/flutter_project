import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'assigned_reports_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../services/firestore_paths.dart';

class FirmStatisticsScreen extends StatefulWidget {
  const FirmStatisticsScreen({super.key});

  @override
  State<FirmStatisticsScreen> createState() => _FirmStatisticsScreenState();
}

enum _TimeRange { all, d7, d30, d90 }

extension _TimeRangeExt on _TimeRange {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
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

class _FirmStatisticsData {
  final int assigned;
  final int active;
  final int completed;

  final List<int> chartBuckets;
  final List<String> chartLabels;
  final int? daysRange;

  final Map<String, int> categoryStats;

  _FirmStatisticsData({
    required this.assigned,
    required this.active,
    required this.completed,
    required this.chartBuckets,
    required this.chartLabels,
    required this.daysRange,
    required this.categoryStats,
  });
}

class _FirmStatisticsScreenState extends State<FirmStatisticsScreen> {
  String? _firmId;
  bool _isLoadingFirm = true;
  bool _hasFirm = true;
  _TimeRange _timeRange = _TimeRange.all;
  Future<_FirmStatisticsData>? _future;

  @override
  void initState() {
    super.initState();
    _loadFirmId();
  }

  Future<void> _loadFirmId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoadingFirm = false;
        _hasFirm = false;
        _firmId = null;
      });
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.firms)
          .where(FirestoreFirmFields.ownerId, isEqualTo: uid)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        setState(() {
          _firmId = snap.docs.first.id;
          _hasFirm = true;
          _isLoadingFirm = false;
          _future = _loadData();
        });
      } else {
        setState(() {
          _firmId = null;
          _hasFirm = false;
          _isLoadingFirm = false;
        });
      }
    } catch (e, stack) {
      debugPrint('FirmStatisticsScreen: failed to load firm id: $e');
      debugPrintStack(stackTrace: stack);
      setState(() {
        _firmId = null;
        _hasFirm = false;
        _isLoadingFirm = false;
      });
    }
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Color _generateColor(int index, int total) {
    final hue = (360.0 / total) * index;
    return HSVColor.fromAHSV(1, hue, 0.65, 0.95).toColor();
    }

  Future<_FirmStatisticsData> _loadData() async {
    if (_firmId == null) {
      return _FirmStatisticsData(
        assigned: 0,
        active: 0,
        completed: 0,
        chartBuckets: [],
        chartLabels: [],
        daysRange: _timeRange.days,
        categoryStats: {},
      );
    }

    final appsSnap = await FirebaseFirestore.instance
        .collection(FirestoreCollections.firmApplications)
        .where("firmId", isEqualTo: _firmId)
        .get();

    if (appsSnap.docs.isEmpty) {
      return _FirmStatisticsData(
        assigned: 0,
        active: 0,
        completed: 0,
        chartBuckets: [],
        chartLabels: [],
        daysRange: _timeRange.days,
        categoryStats: {},
      );
    }

    final appIds = appsSnap.docs.map((d) => d.id).toList();

    final List<QueryDocumentSnapshot<Map<String, dynamic>>> reportDocs = [];
    const int chunkSize = 10;

    for (int i = 0; i < appIds.length; i += chunkSize) {
      final chunk = appIds.sublist(
        i,
        i + chunkSize > appIds.length ? appIds.length : i + chunkSize,
      );

      final repSnap = await FirebaseFirestore.instance
          .collection(FirestoreCollections.reports)
          .where(FirestoreReportFields.selectedApplicationId, whereIn: chunk)
          .get();

      reportDocs.addAll(repSnap.docs);
    }

    final now = DateTime.now();
    final rangeDays = _timeRange.days;
    final DateTime? fromDate =
        rangeDays != null ? now.subtract(Duration(days: rangeDays)) : null;

    final filteredDocs = reportDocs.where((doc) {
      if (fromDate == null) return true;
      final data = doc.data();
      final ts = data[FirestoreReportFields.createdAt];
      if (ts is! Timestamp) return false;
      return ts.toDate().isAfter(fromDate) || ts.toDate().isAtSameMomentAs(fromDate);
    }).toList();

    int assigned = 0;
    int active = 0;
    int completed = 0;

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

      for (final doc in filteredDocs) {
        final data = doc.data();
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final created = _dateOnly(ts.toDate());
        final diff = now.difference(created).inDays;

        if (diff >= 0 && diff < 7) {
          buckets[6 - diff]++;
        }
      }
    } else if (_timeRange == _TimeRange.d30) {
      buckets = List.filled(5, 0);
      labels = const ['01–07', '08–14', '15–21', '22–28', '29–31'];

      for (final doc in filteredDocs) {
        final data = doc.data();
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final day = ts.toDate().day;
        int index = (day - 1) ~/ 7;
        if (index < 0) index = 0;
        if (index > 4) index = 4;

        buckets[index]++;
      }
    } else if (_timeRange == _TimeRange.d90) {
      final months = List.generate(3, (i) {
        return DateTime(now.year, now.month - 2 + i);
      });

      labels = months.map((m) {
        final localeTag = Localizations.localeOf(context).toLanguageTag();
        return DateFormat.MMMM(localeTag).format(m);
      }).toList();

      buckets = List.filled(3, 0);

      for (final doc in filteredDocs) {
        final data = doc.data();
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
    } else {
      final Map<int, int> yearMap = {};

      for (final doc in filteredDocs) {
        final data = doc.data();
        final ts = data[FirestoreReportFields.createdAt];
        if (ts is! Timestamp) continue;

        final year = ts.toDate().year;
        yearMap[year] = (yearMap[year] ?? 0) + 1;
      }

      final years = yearMap.keys.toList()..sort();

      labels = years.map((y) => y.toString()).toList();
      buckets = years.map((y) => yearMap[y]!).toList();
    }

    for (final doc in filteredDocs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString();

      switch (status) {
        case 'In Progress':
        active++;
          break;
        case 'Completed':
        completed++;
          break;
        default:
        assigned++;
      }

      final category = (data['category'] ?? 'Other').toString();
      categoryStats[category] = (categoryStats[category] ?? 0) + 1;
    }

    return _FirmStatisticsData(
      assigned: assigned,
      active: active,
      completed: completed,
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoadingFirm) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (!_hasFirm || _firmId == null) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          iconTheme: IconThemeData(
              color: isDark ? Colors.white : theme.colorScheme.onSurface),
          title: Text(
            AppLocalizations.of(context)!.firmStatistics,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "${AppLocalizations.of(context)!.youHaveNoFirmYet}\n${AppLocalizations.of(context)!.registerYourFirm}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.grey[400] : Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
            color: isDark ? Colors.white : theme.colorScheme.onSurface),
        title: Text(
          AppLocalizations.of(context)!.firmStatistics,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
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
            child: FutureBuilder<_FirmStatisticsData>(
              future: _future ?? Future.value(_FirmStatisticsData(
                assigned: 0,
                active: 0,
                completed: 0,
                chartBuckets: [],
                chartLabels: [],
                daysRange: _timeRange.days,
                categoryStats: {},
              )),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopupMenuButton<_TimeRange>(
      initialValue: _timeRange,
      onSelected: _onTimeRangeSelected,
      itemBuilder: (context) => [
        for (final v in _TimeRange.values)
          PopupMenuItem(value: v, child: Text(v.label(context))),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: _box(isDark),
        child: Row(
          children: [
            Text(
              _timeRange.label(context),
          style: TextStyle(
                fontSize: 14,
            fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSection(_FirmStatisticsData data) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _statRow(
          _statCard(l10n.assigned, '${data.assigned}', Icons.assignment,
              Colors.blue, "Assigned"),
          _statCard(l10n.active, '${data.active}', Icons.work_history, Colors.orange,
              "Active"),
        ),
        const SizedBox(height: 16),
        _statRow(
          _statCard(l10n.completed, '${data.completed}', Icons.check_circle,
              Colors.green, "Completed"),
          const SizedBox(),
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
            builder: (_) => const AssignedReportsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: _box(Theme.of(context).brightness == Brightness.dark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Icon(icon, size: 30, color: color),
            const SizedBox(height: 16),
          Text(
              value,
              style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[400]
                    : Colors.black54,
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _barChartCard(_FirmStatisticsData data) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final buckets = data.chartBuckets;
    final labels = data.chartLabels;
    final maxValue = buckets.isEmpty ? 0 : buckets.reduce(max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _box(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${AppLocalizations.of(context)!.reports} ${_timeRange.label(context)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
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
                      Text(
                        value.toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
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
                      Text(
                        labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.black54,
                        ),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (stats.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: _box(isDark),
        child: Text(
          AppLocalizations.of(context)!.noReportsInSelectedPeriod,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.black54),
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
      decoration: _box(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.categoriesBreakdown,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: isDark ? Colors.white : theme.colorScheme.onSurface,
            ),
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
              final percent = total == 0 ? 0 : (entries[i].value / total * 100);
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
                    Text(
                      '${entries[i].key} — ${entries[i].value} (${percent.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : theme.colorScheme.onSurface,
                      ),
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

  BoxDecoration _box(bool isDark) {
    return BoxDecoration(
      color: isDark ? Theme.of(context).cardColor : Colors.white,
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
