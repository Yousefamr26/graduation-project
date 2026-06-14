import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../../../data/repositories/Candidate repository.dart';
import '../../../../../../data/repositories/interview_repository.dart';


class InterviewsScreen extends StatefulWidget {
  const InterviewsScreen({super.key});

  @override
  State<InterviewsScreen> createState() => _InterviewsScreenState();
}

class _InterviewsScreenState extends State<InterviewsScreen> {
  final candidateRepo = CandidateRepository();
  final interviewRepo  = InterviewRepository();

  final List<Map<String, dynamic>> candidates = [];
  List<Map<String, dynamic>> filteredCandidates = [];

  final Set<String> scheduledIds = {};

  String searchText     = "";
  String selectedFilter = "All";
  bool isLoading        = true;
  bool _isSubmitting    = false;

  @override
  void initState() {
    super.initState();
    _fetchCandidates();
  }

  Future<void> _fetchCandidates() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      final fetched = await candidateRepo.getAllCandidates();
      if (!mounted) return;
      setState(() {
        candidates.clear();
        candidates.addAll(fetched);
        applyFilters();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching candidates: $e");
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load candidates: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void applyFilters() {
    if (!mounted) return;
    setState(() {
      filteredCandidates = candidates.where((c) {
        final id     = _getId(c);
        final status = scheduledIds.contains(id) ? 'Scheduled' : 'Pending';

        if (selectedFilter == 'Scheduled' && status != 'Scheduled') return false;
        if (selectedFilter == 'Pending' && status != 'Pending') return false;

        if (searchText.isEmpty) return true;
        final s = searchText.toLowerCase();
        return _contains(c['fullName'], s) ||
            _contains(c['email'], s) ||
            _contains(c['roadmapName'], s);
      }).toList();
    });
  }

  bool _contains(dynamic value, String search) =>
      value != null && value.toString().toLowerCase().contains(search);

  String _getId(Map<String, dynamic> c) =>
      (c['userId'] ?? c['studentUserId'] ?? c['id'] ?? '').toString();

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void _openScheduleFlow(Map<String, dynamic> candidate) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff1676C4),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (selectedDate == null || !mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff1676C4),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (selectedTime == null || !mounted) return;

    await _showScheduleDetailsDialog(candidate, selectedDate, selectedTime);
  }

  Future<void> _showScheduleDetailsDialog(
      Map<String, dynamic> candidate,
      DateTime selectedDate,
      TimeOfDay selectedTime,
      ) async {
    final interviewerCtrl = TextEditingController();
    final notesCtrl       = TextEditingController();
    String interviewType  = 'Online';
    final formKey         = GlobalKey<FormState>();

    final studentName = (candidate['fullName'] ?? 'Unknown').toString();
    final roadmapId = int.tryParse((candidate['roadmapId'] ?? 0).toString()) ?? 0;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: Colors.white,
          title: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff1676C4), Color(0xff0d7de8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.event_available, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Schedule Interview',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xff1676C4).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xff1676C4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: const Color(0xff1676C4),
                          radius: 20,
                          child: Text(
                            studentName[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                candidate['email']?.toString() ?? '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20, color: Colors.green),
                        const SizedBox(width: 10),
                        Text(
                          "${DateFormat('dd MMM yyyy').format(selectedDate)}  •  ${selectedTime.format(context)}",
                          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.green, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Interview Type", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Online', 'On-site', 'Phone'].map((type) {
                      final isSelected = interviewType == type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setDialogState(() => interviewType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xff1676C4) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? const Color(0xff1676C4) : Colors.grey[300]!),
                            ),
                            child: Center(
                              child: Text(
                                type,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : Colors.grey[700],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text("Interviewer Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: interviewerCtrl,
                    decoration: InputDecoration(
                      hintText: "Enter interviewer name",
                      prefixIcon: const Icon(Icons.person_outline, color: Color(0xff1676C4)),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Interviewer name is required" : null,
                  ),
                  const SizedBox(height: 16),
                  Text("Additional Notes (optional)", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Any extra notes...",
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        side: BorderSide(color: Colors.grey[400]!, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(context);
                        await _submitSchedule(
                          candidate:       candidate,
                          studentName:     studentName,
                          roadmapId:       roadmapId,
                          selectedDate:    selectedDate,
                          selectedTime:    selectedTime,
                          interviewType:   interviewType,
                          interviewerName: interviewerCtrl.text.trim(),
                          additionalNotes: notesCtrl.text,
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 20),
                      label: const Text("Confirm", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1676C4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                        shadowColor: const Color(0xff1676C4).withOpacity(0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          actionsPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Future<void> _submitSchedule({
    required Map<String, dynamic> candidate,
    required String studentName,
    required int roadmapId,
    required DateTime selectedDate,
    required TimeOfDay selectedTime,
    required String interviewType,
    required String interviewerName,
    String? additionalNotes,
  }) async {
    if (!mounted) return;
    setState(() => _isSubmitting = true);

    try {
      final scheduledDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      final studentUserId = _getId(candidate);

      final response = await interviewRepo.createInterview(
        studentUserId:   studentUserId,
        studentName:     studentName,
        roadmapId:       roadmapId,
        scheduledDate:   scheduledDateTime,
        interviewType:   interviewType,
        interviewerName: interviewerName,
        additionalNotes: additionalNotes,
      );

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (!mounted) return;
        setState(() {
          scheduledIds.add(studentUserId);
          applyFilters();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Interview scheduled for $studentName!',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "فشل الحفظ: ${response?.statusCode ?? 'لا يوجد response'}\n${response?.data ?? ''}",
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ في الشبكة: ${e.response?.statusCode}\n${e.response?.data ?? e.message}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("خطأ غير متوقع: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(),
              _buildSearchAndFilter(),
              _buildCandidatesList(),
            ],
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1676C4)),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Scheduling interview...',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff1676C4)),
                        ),
                        const SizedBox(height: 6),
                        Text('Please wait', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xff1676C4),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            toolbarHeight: 80,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Interview Scheduling",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Text("Manage candidate interviews",
                    style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w300)),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _fetchCandidates,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: const Icon(Icons.search, color: Color(0xff1676C4)),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.grey)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                  applyFilters();
                });
              },
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                items: ["All", "Scheduled", "Pending"]
                    .map((f) => DropdownMenuItem(
                  value: f,
                  child: Text(f, style: const TextStyle(fontSize: 14)),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedFilter = value!;
                    applyFilters();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCandidatesList() {
    return Expanded(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : filteredCandidates.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
                searchText.isEmpty ? "No candidates yet" : "No candidates found",
                style: TextStyle(fontSize: 18, color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text(
                searchText.isEmpty ? "Candidates will appear here" : "Try a different search",
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _fetchCandidates,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: filteredCandidates.length,
          itemBuilder: (context, index) => _buildCandidateCard(filteredCandidates[index]),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate) {
    final id          = _getId(candidate);
    final isScheduled = scheduledIds.contains(id);
    final name        = (candidate['fullName'] ?? 'Unknown').toString();
    final email       = candidate['email']?.toString() ?? '';
    final roadmap     = (candidate['roadmapName'] ?? 'N/A').toString();
    final degreeLevel = (candidate['userType'] ?? candidate['degreeLevel'] ?? '').toString();
    final skillMatch  = candidate['skillMatchPercentage'] ?? candidate['skillMatch'] ?? 0;
    final points      = candidate['totalPoints'] ?? candidate['points'] ?? 0;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xff1676C4),
                  radius: 24,
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      if (email.isNotEmpty)
                        Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 12), overflow: TextOverflow.ellipsis),
                      if (degreeLevel.isNotEmpty)
                        Text(degreeLevel, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isScheduled ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isScheduled ? 'Scheduled' : 'Pending',
                    style: TextStyle(
                      color: isScheduled ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildInfoChip(Icons.map_outlined, roadmap, const Color(0xff1676C4))),
                const SizedBox(width: 8),
                _buildInfoChip(
                  Icons.bar_chart,
                  '$skillMatch%',
                  int.tryParse(skillMatch.toString()) != null && int.parse(skillMatch.toString()) >= 80
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.stars, '$points pts', Colors.amber[700]!),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : () => _openScheduleFlow(candidate),
                icon: Icon(
                  isScheduled ? Icons.edit_calendar_outlined : Icons.calendar_month_outlined,
                  size: 18,
                ),
                label: Text(
                  isScheduled ? 'Reschedule' : 'Schedule Interview',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isScheduled ? Colors.grey[200] : const Color(0xff1676C4),
                  foregroundColor: isScheduled ? Colors.grey[700] : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: isScheduled ? 0 : 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}