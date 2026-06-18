import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';

class TrainingReports extends StatefulWidget {
  const TrainingReports({super.key});
  @override
  State<TrainingReports> createState() => _TrainingReportsState();
}

class _TrainingReportsState extends State<TrainingReports> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  Map<String, dynamic> _analytics = {};
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/Analytics/dashboard', userType: 'training_center');
      setState(() => _analytics = (res is Map ? res as Map<String,dynamic> : res?['data'] ?? {}) );
    } catch (_) {} finally { setState(() => _loading = false); }
  }

  String _val(String key, [String fallback = '0']) {
    final v = _analytics[key];
    if (v == null) return fallback;
    if (v is Map) return v['value']?.toString() ?? fallback;
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final courses = (_analytics['courses'] ?? _analytics['coursePerformance'] ?? []) as List;
    final monthly = (_analytics['monthlyEnrollments'] ?? _analytics['enrollmentsByMonth'] ?? []) as List;
    final statusBreakdown = (_analytics['statusBreakdown'] ?? {}) as Map;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary, elevation: 0, automaticallyImplyLeading: false,
        title: const Text('Reports & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [TextButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined, color: Colors.white, size: 18),
          label: const Text('Export', style: TextStyle(color: Colors.white, fontSize: 13)))],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
            // Summary
            Row(children: [
              _summaryCard(_val('totalTrainees', '0'), 'Total Trainees', Icons.people_rounded, const Color(0xffDDEEFF), kPrimary),
              const SizedBox(width: 12),
              _summaryCard('${_val('completionRate', '0')}%', 'Completion', Icons.check_circle_rounded, const Color(0xffD1FAE5), const Color(0xff16A34A)),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _summaryCard(_val('certificatesIssued', '0'), 'Certificates', Icons.workspace_premium_rounded, const Color(0xffFEF3C7), const Color(0xffD97706)),
              const SizedBox(width: 12),
              _summaryCard(_val('averageRating', '0'), 'Avg Rating', Icons.star_rounded, const Color(0xffFEE2E2), const Color(0xffDC2626)),
            ]),
            const SizedBox(height: 16),

            // Monthly chart
            if (monthly.isNotEmpty) ...[
              _card('Monthly Enrollments', child: Column(children: [
                const SizedBox(height: 8),
                SizedBox(height: 130, child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: monthly.take(8).map((m) {
                    final val = ((m['count'] ?? m['value'] ?? m['enrollments'] ?? 0) as num).toDouble();
                    final maxVal = monthly.fold<double>(1, (p, e) => ((e['count'] ?? e['value'] ?? e['enrollments'] ?? 0) as num).toDouble() > p ? ((e['count'] ?? e['value'] ?? e['enrollments'] ?? 0) as num).toDouble() : p);
                    final ratio = maxVal > 0 ? val / maxVal : 0.0;
                    final label = m['month']?.toString() ?? m['label']?.toString() ?? '';
                    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Text('${val.toInt()}', style: const TextStyle(fontSize: 9, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(width: 28, height: (110 * ratio).clamp(4.0, 110.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kPrimary, Color(0xff0d5fa3)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
                      const SizedBox(height: 4),
                      Text(label.length > 3 ? label.substring(0, 3) : label, style: const TextStyle(fontSize: 9, color: Colors.grey)),
                    ]);
                  }).toList())),
              ])),
              const SizedBox(height: 16),
            ],

            // Course performance table
            if (courses.isNotEmpty) ...[
              _card('Course Performance', child: Column(children: [
                Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: const [
                  Expanded(flex: 3, child: Text('Course', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                  Expanded(flex: 2, child: Text('Enrolled', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                  Expanded(flex: 2, child: Text('Completed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                  Expanded(flex: 1, child: Text('Rating', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey), textAlign: TextAlign.center)),
                ])),
                const Divider(height: 1),
                ...courses.take(8).map((c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    Expanded(flex: 3, child: Text(c['title']?.toString() ?? c['name']?.toString() ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500), maxLines: 2)),
                    Expanded(flex: 2, child: Text('${c['enrolledCount'] ?? c['students'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kPrimary))),
                    Expanded(flex: 2, child: Text('${c['completedCount'] ?? c['completed'] ?? 0}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xff22C55E)))),
                    Expanded(flex: 1, child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.star, size: 12, color: Color(0xffF59E0B)),
                      Text('${c['rating'] ?? c['averageRating'] ?? ''}', style: const TextStyle(fontSize: 11)),
                    ])),
                  ]),
                )),
              ])),
              const SizedBox(height: 16),
            ],

            // Status breakdown
            _card('Enrollment Status', child: Column(children: [
              const SizedBox(height: 8),
              _statusBar('Active', (statusBreakdown['activeRate'] ?? statusBreakdown['active'] ?? 0.55).toDouble(), const Color(0xff1676C4)),
              const SizedBox(height: 10),
              _statusBar('Completed', (statusBreakdown['completedRate'] ?? statusBreakdown['completed'] ?? 0.30).toDouble(), const Color(0xff22C55E)),
              const SizedBox(height: 10),
              _statusBar('Pending', (statusBreakdown['pendingRate'] ?? statusBreakdown['pending'] ?? 0.15).toDouble(), const Color(0xffF59E0B)),
            ])),
            const SizedBox(height: 20),

            Row(children: [
              Expanded(child: ElevatedButton.icon(onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Export PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimary, padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
              const SizedBox(width: 12),
              Expanded(child: OutlinedButton.icon(onPressed: () {},
                icon: const Icon(Icons.table_chart_outlined, color: kPrimary),
                label: const Text('Export Excel', style: TextStyle(color: kPrimary)),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: kPrimary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            ]),
          ]))),
    );
  }

  Widget _summaryCard(String value, String label, IconData icon, Color bg, Color fg) =>
    Expanded(child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: fg, size: 22)),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ])),
      ]),
    ));

  Widget _card(String title, {required Widget child}) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 4), child,
    ]));

  Widget _statusBar(String label, double value, Color color) {
    final pct = value <= 1.0 ? value : value / 100;
    return Row(children: [
      SizedBox(width: 80, child: Text(label, style: const TextStyle(fontSize: 12))),
      Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(
        value: pct, minHeight: 14, backgroundColor: Colors.grey[200],
        valueColor: AlwaysStoppedAnimation<Color>(color)))),
      const SizedBox(width: 8),
      Text('${(pct * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    ]);
  }
}
