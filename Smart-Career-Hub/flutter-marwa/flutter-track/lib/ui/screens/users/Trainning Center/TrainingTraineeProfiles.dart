import 'package:flutter/material.dart';
import '../../../../data/services/api_service.dart';
import '../../../../core/Constants/apiConstants.dart';

class TrainingTraineeProfiles extends StatefulWidget {
  const TrainingTraineeProfiles({super.key});
  @override
  State<TrainingTraineeProfiles> createState() => _TrainingTraineeProfilesState();
}

class _TrainingTraineeProfilesState extends State<TrainingTraineeProfiles> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  List<Map<String, dynamic>> _candidates = [];
  bool _loading = true;
  String _search = '', _filter = 'All';

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/Candidates', userType: 'training_center');
      final raw = (res is List ? res : res?['data'] ?? res?['items'] ?? []) as List;

      // Group candidates by userId – each user may appear once per enrolled roadmap
      final Map<String, Map<String, dynamic>> grouped = {};
      for (final item in raw) {
        final map = Map<String, dynamic>.from(item as Map);
        final uid = map['userId']?.toString() ?? '';
        if (uid.isEmpty) continue;

        if (!grouped.containsKey(uid)) {
          grouped[uid] = {
            'userId': uid,
            'fullName': map['fullName'] ?? '',
            'email': map['email'] ?? '',
            'userType': map['userType'] ?? '',
            'profileImage': map['profileImage'] ?? '',
            'totalPoints': map['totalPoints'] ?? 0,
            'roadmaps': <Map<String, dynamic>>[],
          };
        }

        // Accumulate roadmaps & take highest totalPoints
        (grouped[uid]!['roadmaps'] as List).add({
          'roadmapId': map['roadmapId'],
          'roadmapName': map['roadmapName'] ?? '',
          'totalPoints': map['totalPoints'] ?? 0,
        });

        // Keep the highest points value
        final existing = grouped[uid]!['totalPoints'] as int;
        final incoming = (map['totalPoints'] ?? 0) as int;
        if (incoming > existing) {
          grouped[uid]!['totalPoints'] = incoming;
        }

        // Keep profileImage if available
        if ((map['profileImage'] ?? '').toString().isNotEmpty) {
          grouped[uid]!['profileImage'] = map['profileImage'];
        }
      }

      setState(() => _candidates = grouped.values.toList());
    } catch (_) {} finally { setState(() => _loading = false); }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'Student': return const Color(0xff22C55E);
      case 'Graduate': return kPrimary;
      default: return const Color(0xffF59E0B);
    }
  }

  List<Map<String, dynamic>> get _filtered => _candidates.where((t) {
    final name = (t['fullName'] ?? '').toString().toLowerCase();
    final email = (t['email'] ?? '').toString().toLowerCase();
    final userType = t['userType'] ?? '';
    final roadmaps = (t['roadmaps'] as List?) ?? [];
    final roadmapNames = roadmaps.map((r) => (r['roadmapName'] ?? '').toString().toLowerCase()).join(' ');

    final matchFilter = _filter == 'All' || userType == _filter;
    final matchSearch = _search.isEmpty
        || name.contains(_search.toLowerCase())
        || email.contains(_search.toLowerCase())
        || roadmapNames.contains(_search.toLowerCase());

    return matchFilter && matchSearch;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary, elevation: 0, automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Trainee Profiles', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text('${_candidates.length} candidates', style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ],
        ),
      ),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          TextField(
            onChanged: (v) => setState(() => _search = v),
            decoration: InputDecoration(
              hintText: 'Search by name, email, or roadmap...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 12)),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
            children: ['All', 'Student', 'Graduate'].map((s) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(onTap: () => setState(() => _filter = s), child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  color: _filter == s ? kPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _filter == s ? kPrimary : Colors.grey[300]!)),
                child: Text(s, style: TextStyle(
                  color: _filter == s ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600, fontSize: 13)),
              )),
            )).toList(),
          )),
        ])),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _filtered.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.people_outline, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(_candidates.isEmpty ? 'No candidates yet' : 'No results found',
                  style: TextStyle(color: Colors.grey[500])),
                TextButton(onPressed: _load, child: const Text('Refresh')),
              ]))
            : RefreshIndicator(onRefresh: _load, child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _filtered.length,
                itemBuilder: (_, i) => _candidateCard(_filtered[i]),
              ))),
      ]),
    );
  }

  Widget _candidateCard(Map<String, dynamic> c) {
    final name = c['fullName'] ?? 'Candidate';
    final email = c['email'] ?? '';
    final userType = c['userType'] ?? '';
    final totalPoints = c['totalPoints'] ?? 0;
    final profileImage = c['profileImage']?.toString() ?? '';
    final roadmaps = (c['roadmaps'] as List?) ?? [];

    final fullImageUrl = profileImage.isNotEmpty
        ? ApiConstants.getImageUrl(profileImage)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Header: avatar + name + type badge ──
        Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: kPrimary.withOpacity(0.1),
            backgroundImage: fullImageUrl.isNotEmpty ? NetworkImage(fullImageUrl) : null,
            child: fullImageUrl.isEmpty
              ? Text(name.toString()[0].toUpperCase(),
                  style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 20))
              : null,
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            if (email.isNotEmpty) Row(children: [
              const Icon(Icons.email_outlined, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Expanded(child: Text(email.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _typeColor(userType).withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
            child: Text(userType, style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: _typeColor(userType))),
          ),
        ]),

        const SizedBox(height: 12),

        // ── Points badge ──
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xffFEF3C7),
              borderRadius: BorderRadius.circular(12)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.star_rounded, color: Color(0xffD97706), size: 14),
              const SizedBox(width: 4),
              Text('$totalPoints Points',
                style: const TextStyle(color: Color(0xffD97706), fontSize: 11, fontWeight: FontWeight.bold)),
            ]),
          ),
          const Spacer(),
          Text('${roadmaps.length} roadmap${roadmaps.length != 1 ? 's' : ''}',
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        ]),

        const SizedBox(height: 12),
        const Divider(height: 1, color: Color(0xFFF1F5F9)),
        const SizedBox(height: 12),

        // ── Enrolled roadmaps list ──
        const Text('Enrolled Roadmaps',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        ...roadmaps.map((r) {
          final roadmapName = r['roadmapName'] ?? 'Roadmap';
          final rPoints = r['totalPoints'] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.route_rounded, size: 14, color: kPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(roadmapName.toString(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: rPoints > 0
                    ? const Color(0xffDCFCE7)
                    : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10)),
                child: Text('$rPoints pts',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: rPoints > 0 ? const Color(0xff16A34A) : Colors.grey)),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}
