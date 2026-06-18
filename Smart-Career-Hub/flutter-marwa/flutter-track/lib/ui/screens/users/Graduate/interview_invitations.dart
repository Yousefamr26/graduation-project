import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';

class InterviewInvitations extends StatefulWidget {
  const InterviewInvitations({super.key});
  @override
  State<InterviewInvitations> createState() => _InterviewInvitationsState();
}

class _InterviewInvitationsState extends State<InterviewInvitations> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  List<dynamic> _upcoming = [], _past = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiService.get('/Interviews/me/upcoming', userType: 'graduate').catchError((_) => []),
        ApiService.get('/interviews/me/past?page=1&pageSize=20', userType: 'graduate').catchError((_) => []),
      ]);
      setState(() {
        _upcoming = (results[0] is List ? results[0] : results[0]?['data'] ?? []) as List;
        _past = (results[1] is List ? results[1] : results[1]?['data'] ?? []) as List;
      });
    } catch (_) {} finally { setState(() => _loading = false); }
  }

  Future<void> _respond(dynamic id, bool accept) async {
    try {
      await ApiService.patch('/interviews/me/$id/${accept ? 'accept' : 'decline'}', userType: 'graduate');
      _snack(accept ? '✅ Interview accepted!' : '❌ Interview declined');
      _load();
    } catch (e) { _snack('Error: ${e.toString().replaceAll('Exception: ','')}'); }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(m), backgroundColor: kPrimary, behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('Interview Invitations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Stats bar
            Row(children: [
              _statChip('${_upcoming.length}', 'Upcoming', const Color(0xffDDEEFF), kPrimary),
              const SizedBox(width: 10),
              _statChip('${_past.where((p) => (p['status'] ?? '') == 'Accepted').length}', 'Accepted', const Color(0xffD1FAE5), const Color(0xff065F46)),
              const SizedBox(width: 10),
              _statChip('${_past.length}', 'Past', const Color(0xffF3F4F6), Colors.grey),
            ]),
            const SizedBox(height: 20),

            if (_upcoming.isNotEmpty) ...[
              const Text('Upcoming Interviews (${0})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ..._upcoming.map((i) => _interviewCard(i as Map, isUpcoming: true)),
              const SizedBox(height: 8),
            ] else ...[
              _emptySection('No upcoming interviews', Icons.videocam_outlined),
              const SizedBox(height: 20),
            ],

            if (_past.isNotEmpty) ...[
              const Text('Past Interviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              ..._past.map((i) => _interviewCard(i as Map, isUpcoming: false)),
            ],

            // Interview tips
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [kPrimary, Color(0xff0d5fa3)]),
              borderRadius: BorderRadius.circular(16)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Interview Preparation Tips', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 10),
                _TipRow('Research the company before the interview'),
                _TipRow('Prepare answers for common questions'),
                _TipRow('Practice coding problems if technical'),
                _TipRow('Dress professionally for on-site'),
                _TipRow('What skills should I master?'),
              ])),
          ]))),
    );
  }

  Widget _statChip(String count, String label, Color bg, Color fg) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(count, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: fg)),
      Text(label, style: TextStyle(fontSize: 11, color: fg.withOpacity(0.7))),
    ]),
  ));

  Widget _emptySection(String msg, IconData icon) => Center(child: Column(children: [
    Icon(icon, size: 52, color: Colors.grey[300]),
    const SizedBox(height: 8), Text(msg, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
  ]));

  Widget _interviewCard(Map inv, {required bool isUpcoming}) {
    final id = inv['id'] ?? inv['interviewId'];
    final status = inv['status'] ?? (isUpcoming ? 'Pending' : 'Completed');
    final statusColors = {
      'Accepted': [const Color(0xffD1FAE5), const Color(0xff065F46)],
      'Online': [const Color(0xffD1FAE5), const Color(0xff065F46)],
      'Pending': [const Color(0xffFEF3C7), const Color(0xff92400E)],
      'Rejected': [const Color(0xffFEE2E2), const Color(0xff991B1B)],
      'Completed': [const Color(0xffF3F4F6), Colors.grey],
    };
    final sc = statusColors[status] ?? [const Color(0xffF3F4F6), Colors.grey];
    final type = inv['interviewType'] ?? inv['type'] ?? 'Online';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)]),
      child: Column(children: [
        Container(height: 90, decoration: BoxDecoration(
          gradient: LinearGradient(colors: [kPrimary.withOpacity(0.85), const Color(0xff0d5fa3)]),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [
            CircleAvatar(radius: 22, backgroundColor: Colors.white.withOpacity(0.2),
              child: Text((inv['companyName'] ?? inv['company'] ?? 'C').toString()[0],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(inv['companyName']?.toString() ?? inv['company']?.toString() ?? 'Company',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text(inv['jobTitle']?.toString() ?? inv['positionTitle']?.toString() ?? 'Position',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: sc[0], borderRadius: BorderRadius.circular(20)),
              child: Text(status, style: TextStyle(color: sc[1], fontSize: 11, fontWeight: FontWeight.w700))),
          ]))),
        Padding(padding: const EdgeInsets.all(14), child: Column(children: [
          _row(Icons.calendar_today_outlined, (inv['scheduledDate'] ?? inv['date'] ?? '').toString().split('T').first),
          _row(Icons.schedule_outlined, '${inv['startTime'] ?? inv['time'] ?? ''} - ${inv['endTime'] ?? ''}'),
          _row(Icons.videocam_outlined, type),
          if ((inv['interviewerName'] ?? inv['interviewer'] ?? '').toString().isNotEmpty)
            _row(Icons.person_outline, 'Interviewer: ${inv['interviewerName'] ?? inv['interviewer']}'),
          if (isUpcoming && status == 'Pending') ...[
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: ElevatedButton.icon(
                onPressed: () => _respond(id, true),
                icon: const Icon(Icons.check_rounded, size: 16), label: const Text('Accept'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xff22C55E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11)))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => _respond(id, false),
                icon: const Icon(Icons.close_rounded, size: 16, color: Colors.red), label: const Text('Decline', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 11)))),
            ]),
          ],
          if (isUpcoming && status == 'Accepted') ...[
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.videocam_rounded, size: 16), label: const Text('Join Meeting'),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(vertical: 11)))),
          ],
        ])),
      ]),
    );
  }

  Widget _row(IconData icon, String text) => text.isEmpty ? const SizedBox() : Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 15, color: Colors.grey), const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
    ]));
}

class _TipRow extends StatelessWidget {
  final String text;
  const _TipRow(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(children: [
      const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 11),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 12))),
    ]));
}
