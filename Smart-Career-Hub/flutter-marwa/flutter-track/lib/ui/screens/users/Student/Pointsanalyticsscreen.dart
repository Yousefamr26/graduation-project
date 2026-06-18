import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/services/api_service.dart';

class PointsAnalyticsScreen extends StatefulWidget {
  final bool showBackButton;
  const PointsAnalyticsScreen({super.key, this.showBackButton = true});
  @override
  State<PointsAnalyticsScreen> createState() => _PointsAnalyticsScreenState();
}

class _PointsAnalyticsScreenState extends State<PointsAnalyticsScreen> {
  static const Color kPrimary = Color(0xff1676C4);
  static const Color kBg = Color(0xffF0F9FF);

  Map<String, dynamic> _summary = {};
  List<dynamic> _leaderboard = [], _recentPoints = [];
  bool _loading = true;
  String? _userType;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('student_token') != null) {
      _userType = 'student';
    } else if (prefs.getString('graduate_token') != null) _userType = 'graduate';
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/Profile/summary', userType: _userType);
      setState(() {
        _summary = (res is Map ? res as Map<String,dynamic> : res?['data'] ?? {}) ;
        _leaderboard = (_summary['leaderboard'] ?? _summary['topStudents'] ?? []) as List;
        _recentPoints = (_summary['recentPoints'] ?? _summary['pointsHistory'] ?? []) as List;
      });
    } catch (_) {} finally { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final total = _summary['totalPoints'] ?? _summary['points'] ?? 0;
    final rank = _summary['rank'] ?? _summary['currentRank'] ?? '--';
    final level = _summary['level'] ?? _summary['currentLevel'] ?? 'Gold';
    final nextLevel = _summary['pointsToNextLevel'] ?? _summary['nextLevelPoints'] ?? 0;
    final currentForLevel = _summary['currentLevelPoints'] ?? 0;
    final skills = _summary['skillPoints'] ?? _summary['skillBasedPoints'] ?? {};
    final achievements = (_summary['achievements'] ?? []) as List;

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kPrimary, elevation: 0,
        leading: widget.showBackButton ? IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)) : null,
        title: const Text('Points & Analytics', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _loading ? const Center(child: CircularProgressIndicator(color: kPrimary))
        : RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(child: Column(children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [kPrimary, Color(0xff0d5fa3)])),
              child: Column(children: [
                const Text('Points & Analytics', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const Text('Track your progress and achievements', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 20),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _statItem('$total', 'Total Points', Icons.emoji_events_rounded),
                  _divider(),
                  _statItem('$currentForLevel/$nextLevel', 'Progress to Next', Icons.trending_up_rounded),
                  _divider(),
                  _statContainer('$level', Icons.military_tech_rounded),
                  _divider(),
                  _statItem('#$rank', 'Leaderboard', Icons.leaderboard_rounded),
                ]),
              ]),
            ),
            Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              // Skill-based points
              if (skills is Map && skills.isNotEmpty) _card('Skill-based Points', child: Column(children: [
                ...(skills).entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(children: [
                    Expanded(child: Text(e.key.toString(), style: const TextStyle(fontSize: 13))),
                    const SizedBox(width: 8),
                    Expanded(flex: 2, child: ClipRRect(borderRadius: BorderRadius.circular(6), child: LinearProgressIndicator(
                      value: (e.value as num).toDouble() / (total > 0 ? (total as num).toDouble() : 1),
                      minHeight: 8, backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation(kPrimary)))),
                    const SizedBox(width: 8),
                    Text('${e.value} pts', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ]),
                )),
              ])),

              // Achievements
              if (achievements.isNotEmpty) ...[
                const SizedBox(height: 12),
                _card('Achievements', child: GridView.count(
                  crossAxisCount: 3, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.85,
                  children: achievements.take(6).map((a) => Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12)),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xffF59E0B), size: 28),
                      const SizedBox(height: 6),
                      Text(a['name']?.toString() ?? a['title']?.toString() ?? 'Badge',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center, maxLines: 2),
                    ]),
                  )).toList(),
                )),
              ],

              // Recent points
              if (_recentPoints.isNotEmpty) ...[
                const SizedBox(height: 12),
                _card('Latest Earned Points', child: Column(children: [
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: const [
                    Expanded(child: Text('Source', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                    Text('Date', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    SizedBox(width: 40),
                    Text('Points', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ])),
                  const Divider(height: 1),
                  ..._recentPoints.take(6).map((p) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Expanded(child: Text(p['source']?.toString() ?? p['description']?.toString() ?? '', style: const TextStyle(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      Text(p['date']?.toString() ?? p['earnedAt']?.toString() ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(width: 8),
                      Text('+${p['points'] ?? p['amount'] ?? 0}', style: const TextStyle(fontSize: 12, color: Color(0xff22C55E), fontWeight: FontWeight.bold)),
                    ]),
                  )),
                ])),
              ],

              // Leaderboard
              const SizedBox(height: 12),
              _card('Leaderboard', child: _leaderboard.isEmpty
                ? Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('No leaderboard data', style: TextStyle(color: Colors.grey[500]))))
                : Column(children: [
                    Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: const [
                      SizedBox(width: 32, child: Text('Rank', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                      Expanded(child: Text('Student', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey))),
                      Text('Points', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ])),
                    const Divider(height: 1),
                    ..._leaderboard.take(10).toList().asMap().entries.map((entry) {
                      final i = entry.key; final l = entry.value as Map;
                      final isMe = l['isCurrentUser'] == true;
                      return Container(
                        color: isMe ? kPrimary.withOpacity(0.06) : null,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(children: [
                          SizedBox(width: 32, child: i < 3
                            ? Icon([Icons.looks_one_rounded, Icons.looks_two_rounded, Icons.looks_3_rounded][i], color: [const Color(0xffF59E0B), Colors.grey, const Color(0xffCD7F32)][i], size: 22)
                            : Text('#${i+1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          CircleAvatar(radius: 16, backgroundColor: kPrimary.withOpacity(0.1),
                            child: Text((l['name'] ?? l['studentName'] ?? '?').toString()[0], style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold, fontSize: 13))),
                          const SizedBox(width: 8),
                          Expanded(child: Text(l['name']?.toString() ?? l['studentName']?.toString() ?? 'Student',
                            style: TextStyle(fontSize: 13, fontWeight: isMe ? FontWeight.bold : FontWeight.normal, color: isMe ? kPrimary : Colors.black87))),
                          Text('${l['points'] ?? l['totalPoints'] ?? 0}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isMe ? kPrimary : Colors.black87)),
                        ]),
                      );
                    }),
                  ])),
            ])),
            SizedBox(height: widget.showBackButton ? 20 : 100),
          ]))),
    );
  }

  Widget _statItem(String val, String label, IconData icon) => Column(children: [
    Icon(icon, color: Colors.white70, size: 22),
    const SizedBox(height: 6),
    Text(val, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
  ]);

  Widget _statContainer(String val, IconData icon) => Column(children: [
    Icon(icon, color: const Color(0xffFCD34D), size: 24),
    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xffFCD34D).withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
      child: Text(val, style: const TextStyle(color: Color(0xffFCD34D), fontWeight: FontWeight.bold, fontSize: 13))),
    const Text('Level', style: TextStyle(color: Colors.white60, fontSize: 9)),
  ]);

  Widget _divider() => Container(height: 40, width: 1, color: Colors.white24);

  Widget _card(String title, {required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 12), child,
    ]));
}
