// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../../../data/repositories/Eventuni repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';

class CreateEditEventUniScreen extends StatefulWidget {
  final Map<String, dynamic>? eventData; // null = create

  const CreateEditEventUniScreen({this.eventData, super.key});

  @override
  State<CreateEditEventUniScreen> createState() => _CreateEditEventUniScreenState();
}

class _CreateEditEventUniScreenState extends State<CreateEditEventUniScreen> {
  final eventRepo = EventUniRepository();

  // ── Controllers ──────────────────────────────────────────
  final TextEditingController _titleController          = TextEditingController();
  final TextEditingController _descController           = TextEditingController();
  final TextEditingController _locationController       = TextEditingController();
  final TextEditingController _startDateController      = TextEditingController();
  final TextEditingController _endDateController        = TextEditingController();
  final TextEditingController _startTimeController      = TextEditingController();
  final TextEditingController _endTimeController        = TextEditingController();
  final TextEditingController _capacityController       = TextEditingController();
  final TextEditingController _pointsAttendanceController     = TextEditingController();
  final TextEditingController _pointsParticipationController  = TextEditingController();

  // ── Dropdowns ─────────────────────────────────────────────
  String? _eventType;
  String? _eventMode;

  final List<String> _eventTypes = [
    "Company Tour", "Hiring Event", "Workshop",
    "Networking Event", "Tech Talk", "Bootcamp Preview",
  ];
  final List<String> _eventModes = ["Online", "Onsite", "Hybrid"];

  // ── Eligibility ───────────────────────────────────────────
  double _minPoints                 = 0;
  bool   _completedRoadmap          = false;
  bool   _completed50Percent        = false;
  bool   _highCommunication         = false;
  bool   _highTechnical             = false;
  bool   _top30Percent              = false;
  bool   _inviteOnly                = false;

  // ── Registration ──────────────────────────────────────────
  bool _allowWaitingList = false;
  bool _sendAutoEmail    = false;

  // ── State ─────────────────────────────────────────────────
  String? _coverImagePath;
  Map<String, String> _errors = {};
  bool _isLoading = false;

  bool get isEdit => widget.eventData != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.eventData != null) {
      final d = widget.eventData!;
      _titleController.text     = d['title'] ?? '';
      _descController.text      = d['description'] ?? '';
      _locationController.text  = d['location'] ?? '';
      _startDateController.text = d['startDate']?.toString().split('T')[0] ?? '';
      _endDateController.text   = d['endDate']?.toString().split('T')[0] ?? '';
      _startTimeController.text = d['startTime'] ?? '';
      _endTimeController.text   = d['endTime'] ?? '';
      _capacityController.text  = d['maxCapacity']?.toString() ?? d['capacity']?.toString() ?? '';
      _pointsAttendanceController.text    = d['pointsForAttendance']?.toString() ?? d['pointsAttendance']?.toString() ?? '0';
      _pointsParticipationController.text = d['pointsForFullParticipation']?.toString() ?? d['pointsParticipation']?.toString() ?? '0';
      _eventType        = d['eventType'] ?? d['type'];
      _eventMode        = d['mode'];
      _coverImagePath   = d['banner'] ?? d['coverImagePath'];
      _minPoints        = (d['minimumRequiredPoints'] ?? d['minPoints'] ?? 0).toDouble();
      _completedRoadmap = d['completedRoadmap'] ?? false;
      _completed50Percent = d['completed50PercentCourses'] ?? false;
      _highCommunication  = d['highCommunicationSkills'] ?? false;
      _highTechnical      = d['highTechnicalSkills'] ?? false;
      _top30Percent       = d['top30PercentProgress'] ?? false;
      _inviteOnly         = d['inviteOnlyEligibleStudents'] ?? d['inviteOnly'] ?? false;
      _allowWaitingList   = d['allowWaitingList'] ?? false;
      _sendAutoEmail      = d['sendAutoEmailToEligibleStudents'] ?? d['sendAutoEmail'] ?? false;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _capacityController.dispose();
    _pointsAttendanceController.dispose();
    _pointsParticipationController.dispose();
    super.dispose();
  }

  // ── Validation ───────────────────────────────────────────
  bool _validateForm() {
    _errors.clear();
    if (_titleController.text.trim().isEmpty)     _errors['title'] = 'Event title is required';
    if (_descController.text.trim().isEmpty)      _errors['description'] = 'Description is required';
    if (_eventType == null)                       _errors['eventType'] = 'Event type is required';
    if (_eventMode == null)                       _errors['eventMode'] = 'Event mode is required';
    if ((_eventMode == "Onsite" || _eventMode == "Hybrid") && _locationController.text.trim().isEmpty)
      _errors['location'] = 'Location is required for onsite/hybrid events';
    if (_startDateController.text.trim().isEmpty) _errors['startDate'] = 'Start date is required';
    if (_endDateController.text.trim().isEmpty)   _errors['endDate'] = 'End date is required';
    if (_startTimeController.text.trim().isEmpty) _errors['startTime'] = 'Start time is required';
    if (_endTimeController.text.trim().isEmpty)   _errors['endTime'] = 'End time is required';
    final cap = int.tryParse(_capacityController.text);
    if (cap == null || cap <= 0)                  _errors['capacity'] = 'Valid capacity is required';

    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      try {
        final start = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
        final end   = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
        if (end.isBefore(start)) _errors['endDate'] = 'End date must be after start date';
      } catch (_) { _errors['startDate'] = 'Invalid date format'; }
    }

    setState(() {});
    return _errors.isEmpty;
  }

  // ── Save ─────────────────────────────────────────────────
  Future<void> _saveEvent({required bool isPublished}) async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);

    try {
      final startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final endDate   = DateFormat('yyyy-MM-dd').parse(_endDateController.text);

      String _formatTimeForApi(String timeStr) {
        try {
          final tod = TimeOfDay(
            hour: int.parse(timeStr.split(':')[0]),
            minute: int.parse(timeStr.split(':')[1].split(' ')[0]),
          );
          return '${tod.hour.toString().padLeft(2, '0')}:${tod.minute.toString().padLeft(2, '0')}:00';
        } catch (_) { return '00:00:00'; }
      }

      File? bannerFile;
      if (_coverImagePath != null && !_coverImagePath!.startsWith('http')) {
        bannerFile = File(_coverImagePath!);
      }

      Response? response;

      if (isEdit) {
        response = await eventRepo.updateEvent(
          eventId:                    widget.eventData!['id'].toString(),
          title:                      _titleController.text.trim(),
          description:                _descController.text.trim(),
          eventType:                  _eventType!,
          mode:                       _eventMode!,
          startDate:                  startDate,
          endDate:                    endDate,
          startTime:                  _formatTimeForApi(_startTimeController.text),
          endTime:                    _formatTimeForApi(_endTimeController.text),
          maxCapacity:                int.tryParse(_capacityController.text) ?? 0,
          isPublished:                isPublished,
          allowWaitingList:           _allowWaitingList,
          sendAutoEmail:              _sendAutoEmail,
          pointsForAttendance:        int.tryParse(_pointsAttendanceController.text) ?? 0,
          pointsForFullParticipation: int.tryParse(_pointsParticipationController.text) ?? 0,
          minPoints:                  _minPoints,
          completedRoadmap:           _completedRoadmap,
          completed50PercentCourses:  _completed50Percent,
          highCommunicationSkills:    _highCommunication,
          highTechnicalSkills:        _highTechnical,
          top30PercentProgress:       _top30Percent,
          inviteOnlyEligibleStudents: _inviteOnly,
          location:                   _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
          banner:                     bannerFile,
        );
      } else {
        response = await eventRepo.createEvent(
          title:                      _titleController.text.trim(),
          description:                _descController.text.trim(),
          eventType:                  _eventType!,
          mode:                       _eventMode!,
          startDate:                  startDate,
          endDate:                    endDate,
          startTime:                  _formatTimeForApi(_startTimeController.text),
          endTime:                    _formatTimeForApi(_endTimeController.text),
          maxCapacity:                int.tryParse(_capacityController.text) ?? 0,
          isPublished:                isPublished,
          allowWaitingList:           _allowWaitingList,
          sendAutoEmail:              _sendAutoEmail,
          pointsForAttendance:        int.tryParse(_pointsAttendanceController.text) ?? 0,
          pointsForFullParticipation: int.tryParse(_pointsParticipationController.text) ?? 0,
          minPoints:                  _minPoints,
          completedRoadmap:           _completedRoadmap,
          completed50PercentCourses:  _completed50Percent,
          highCommunicationSkills:    _highCommunication,
          highTechnicalSkills:        _highTechnical,
          top30PercentProgress:       _top30Percent,
          inviteOnlyEligibleStudents: _inviteOnly,
          location:                   _locationController.text.trim().isNotEmpty ? _locationController.text.trim() : null,
          banner:                     bannerFile,
        );
      }

      debugPrint("📦 Response status: ${response?.statusCode}");

      if (response != null && (response.statusCode == 200 || response.statusCode == 201)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit ? 'Event updated successfully!' : 'Event published successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: ${response?.statusCode}\n${response?.data ?? ''}'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 5),
        ));
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Network error: ${e.response?.statusCode}\n${e.response?.data ?? e.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(TextEditingController ctrl, String field) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xff1676C4), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { ctrl.text = DateFormat('yyyy-MM-dd').format(picked); _errors.remove(field); });
  }

  Future<void> _pickTime(TextEditingController ctrl, String field) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xff1676C4), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() { ctrl.text = picked.format(context); _errors.remove(field); });
  }

  // ── Build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Event" : "Create New Event",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1676C4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Errors ─────────────────────────────────────────
            if (_errors.isNotEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _errors.values
                      .map((e) => Text("• $e", style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),

            // ── Event Information ──────────────────────────────
            SectionWidget(
              title: "Event Information",
              children: [
                TextFieldWidget(controller: _titleController, label: "Event Title", hint: "e.g., Vodafone Tech Tour"),
                if (_errors.containsKey('title')) _err(_errors['title']!),
                const SizedBox(height: 12),
                TextAreaWidget(controller: _descController, label: "Description", hint: "Write a clear description of the event..."),
                if (_errors.containsKey('description')) _err(_errors['description']!),
                const SizedBox(height: 12),
                UploadContainerWidget(
                  title: "Event Cover Image",
                  selectedImagePath: _coverImagePath,
                  onImageChanged: (path) => setState(() => _coverImagePath = path),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Type & Mode ────────────────────────────────────
            SectionWidget(
              title: "Event Type & Mode",
              children: [
                CustomDropdown(label: "Event Type", items: _eventTypes, value: _eventType, hint: "Select Event Type",
                    onChanged: (v) => setState(() { _eventType = v; _errors.remove('eventType'); })),
                if (_errors.containsKey('eventType')) _err(_errors['eventType']!),
                const SizedBox(height: 12),
                CustomDropdown(label: "Mode", items: _eventModes, value: _eventMode, hint: "Select Mode",
                    onChanged: (v) => setState(() { _eventMode = v; _errors.remove('eventMode'); })),
                if (_errors.containsKey('eventMode')) _err(_errors['eventMode']!),
                const SizedBox(height: 12),
                if (_eventMode == "Onsite" || _eventMode == "Hybrid") ...[
                  TextFieldWidget(controller: _locationController, label: "Location", hint: "Campus Hall / Building…"),
                  if (_errors.containsKey('location')) _err(_errors['location']!),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // ── Date & Time ────────────────────────────────────
            SectionWidget(
              title: "Date & Time",
              children: [
                Row(children: [
                  Expanded(child: DateFieldWidget(controller: _startDateController, label: "Start Date", hint: "Select Date",
                      errorText: _errors['startDate'], onTap: () => _pickDate(_startDateController, 'startDate'))),
                  const SizedBox(width: 10),
                  Expanded(child: DateFieldWidget(controller: _endDateController, label: "End Date", hint: "Select Date",
                      errorText: _errors['endDate'], onTap: () => _pickDate(_endDateController, 'endDate'))),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextFieldWidget(controller: _startTimeController, label: "Start Time", hint: "Select time",
                      suffixIcon: const Icon(Icons.access_time, color: Color(0xff1676C4)),
                      onTap: () => _pickTime(_startTimeController, 'startTime'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextFieldWidget(controller: _endTimeController, label: "End Time", hint: "Select time",
                      suffixIcon: const Icon(Icons.access_time, color: Color(0xff1676C4)),
                      onTap: () => _pickTime(_endTimeController, 'endTime'))),
                ]),
                if (_errors.containsKey('startTime') || _errors.containsKey('endTime'))
                  _err(_errors['startTime'] ?? _errors['endTime'] ?? ''),
              ],
            ),

            const SizedBox(height: 16),

            // ── Eligibility Settings ───────────────────────────
            SectionWidget(
              title: "Eligibility Settings",
              children: [
                Row(children: [
                  const Expanded(child: Text("Minimum Required Points:", style: TextStyle(fontWeight: FontWeight.w600))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xff1676C4), borderRadius: BorderRadius.circular(8)),
                    child: Text("${_minPoints.round()} pts",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ]),
                Slider(
                  min: 0, max: 10000, divisions: 100, value: _minPoints,
                  label: "${_minPoints.round()} pts",
                  activeColor: const Color(0xff1676C4),
                  inactiveColor: Colors.grey.shade300,
                  onChanged: (v) => setState(() => _minPoints = v),
                ),
                const SizedBox(height: 8),
                const Text("Additional Filters:", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _filterChip("Completed Roadmap",         _completedRoadmap,    (v) => setState(() => _completedRoadmap = v)),
                  _filterChip("≥50% Courses",             _completed50Percent,  (v) => setState(() => _completed50Percent = v)),
                  _filterChip("High Communication Skills", _highCommunication,   (v) => setState(() => _highCommunication = v)),
                  _filterChip("High Technical Skills",     _highTechnical,       (v) => setState(() => _highTechnical = v)),
                  _filterChip("Top 30% Progress",         _top30Percent,        (v) => setState(() => _top30Percent = v)),
                ]),
                const Divider(height: 24),
                SwitchListTile(
                  title: const Text("Invite Only Eligible Students"),
                  value: _inviteOnly,
                  onChanged: (v) => setState(() => _inviteOnly = v),
                  activeColor: const Color(0xff1676C4),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Capacity & Registration ────────────────────────
            SectionWidget(
              title: "Capacity & Registration",
              children: [
                TextFieldWidget(controller: _capacityController, label: "Max Attendees", hint: "e.g., 100", keyboardType: TextInputType.number),
                if (_errors.containsKey('capacity')) _err(_errors['capacity']!),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text("Allow Waiting List"),
                  value: _allowWaitingList,
                  onChanged: (v) => setState(() => _allowWaitingList = v),
                  activeColor: const Color(0xff1676C4),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Send Auto Email to Eligible Students"),
                  value: _sendAutoEmail,
                  onChanged: (v) => setState(() => _sendAutoEmail = v),
                  activeColor: const Color(0xff1676C4),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Event Rewards ──────────────────────────────────
            SectionWidget(
              title: "Event Rewards",
              children: [
                TextFieldWidget(controller: _pointsAttendanceController,    label: "Points for Attendance",        hint: "e.g., 50",  keyboardType: TextInputType.number),
                const SizedBox(height: 12),
                TextFieldWidget(controller: _pointsParticipationController, label: "Points for Full Participation", hint: "e.g., 100", keyboardType: TextInputType.number),
              ],
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────
            if (isEdit)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _saveEvent(isPublished: true),
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _saveEvent(isPublished: true),
                    icon: const Icon(Icons.publish),
                    label: const Text("Publish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1676C4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ]),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _err(String msg) => Padding(
      padding: const EdgeInsets.only(top: 4, left: 4),
      child: Text(msg, style: const TextStyle(color: Colors.red, fontSize: 12)));

  Widget _filterChip(String label, bool selected, Function(bool) onChanged) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onChanged,
      selectedColor: const Color(0xff1676C4).withOpacity(0.2),
      checkmarkColor: const Color(0xff1676C4),
    );
  }
}