import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../../../data/repositories/Internship repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';

class CreateEditInternshipScreen extends StatefulWidget {
  final Map<String, dynamic>? internship;

  const CreateEditInternshipScreen({this.internship, super.key});

  @override
  State<CreateEditInternshipScreen> createState() =>
      _CreateEditInternshipScreenState();
}

class _CreateEditInternshipScreenState
    extends State<CreateEditInternshipScreen> {
  final _internshipRepo = InternshipRepository();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxTraineesController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  String? _internshipType;
  String? _duration;

  final List<String> _internshipTypes = [
    "On-site 🏢",
    "Remote 🌐",
    "Hybrid 🔄"
  ];
  final List<String> _durations = [
    "1 month",
    "2 months",
    "3 months",
    "6 months",
    "12 months"
  ];

  bool _isPaid = false;
  List<String> _skills = [];
  Map<String, String?> _errors = {};
  bool _isLoading = false;

  bool get isEdit => widget.internship != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.internship != null) {
      final d = widget.internship!;
      _titleController.text = d['title'] ?? '';
      _descController.text = d['description'] ?? '';
      _locationController.text = d['location'] ?? '';
      _maxTraineesController.text =
          (d['maxTrainees'] ?? d['maxtrainees'] ?? '').toString();
      _isPaid = d['isPaid'] ?? false;
      _internshipType = d['type'];
      _duration = d['duration'];

      final deadline =
      (d['applicationDeadline'] ?? d['deadline'] ?? '').toString();
      if (deadline.isNotEmpty) {
        _deadlineController.text = deadline.split('T')[0];
      }

      final rawSkills = d['requiredSkills'] ?? d['skills'] ?? [];
      if (rawSkills is List) {
        _skills = rawSkills.map((e) => e.toString()).toList();
      }

      final rawReqs = d['requirements'] ?? [];
      if (rawReqs is List) {
        _requirementsController.text =
            rawReqs.map((e) => e.toString()).join('\n');
      } else {
        _requirementsController.text = rawReqs.toString();
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _maxTraineesController.dispose();
    _deadlineController.dispose();
    _requirementsController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  // ── Validation ───────────────────────────────────────────

  bool _validateForm() {
    _errors.clear();

    if (_titleController.text.trim().isEmpty)
      _errors['title'] = 'Internship title is required';
    if (_descController.text.trim().isEmpty)
      _errors['description'] = 'Description is required';
    if (_internshipType == null) _errors['type'] = 'Type is required';
    if (_duration == null) _errors['duration'] = 'Duration is required';
    if (_deadlineController.text.trim().isEmpty)
      _errors['deadline'] = 'Application deadline is required';
    if ((_internshipType == "On-site 🏢" || _internshipType == "Hybrid 🔄") &&
        _locationController.text.trim().isEmpty) {
      _errors['location'] =
      'Location is required for on-site/hybrid internships';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  // ── Save ─────────────────────────────────────────────────

  Future<void> _save(bool isPublished) async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final deadline =
      DateFormat('yyyy-MM-dd').parse(_deadlineController.text.trim());

      final requirements = _requirementsController.text
          .split('\n')
          .where((l) => l.trim().isNotEmpty)
          .map((l) => l.trim())
          .toList();

      final maxTrainees =
          int.tryParse(_maxTraineesController.text.trim()) ?? 0;

      final durationInMonths =
      _parseDurationToMonths(_duration ?? '1 month');

      Response? response;

      if (isEdit) {
        response = await _internshipRepo.updateInternship(
          internshipId: widget.internship!['id'],
          title: _titleController.text.trim(),
          type: _internshipType!,
          isPaid: _isPaid,
          maxTrainees: maxTrainees,
          durationInMonths: durationInMonths,
          applicationDeadline: deadline,
          location: _locationController.text.trim(),
          description: _descController.text.trim(),
          requiredSkills: _skills,
          requirements: requirements,
          // ✅ لا يوجد status — الـ API مش بيقبله
        );
      } else {
        response = await _internshipRepo.createInternship(
          title: _titleController.text.trim(),
          type: _internshipType!,
          isPaid: _isPaid,
          maxTrainees: maxTrainees,
          durationInMonths: durationInMonths,
          applicationDeadline: deadline,
          location: _locationController.text.trim(),
          description: _descController.text.trim(),
          requiredSkills: _skills,
          requirements: requirements,
          // ✅ لا يوجد status — الـ API مش بيقبله
        );
      }

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'تم التحديث بنجاح!'
                : isPublished
                ? 'تم النشر بنجاح!'
                : 'تم الحفظ كمسودة!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'فشل الحفظ: ${response?.statusCode}\n${response?.data ?? ''}'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'خطأ في الشبكة: ${e.response?.statusCode}\n${e.response?.data ?? e.message}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ غير متوقع: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _parseDurationToMonths(String duration) {
    final match = RegExp(r'(\d+)').firstMatch(duration);
    if (match != null) return int.tryParse(match.group(1)!) ?? 1;
    return 1;
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xff1676C4),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _deadlineController.text = DateFormat('yyyy-MM-dd').format(picked);
        _errors['deadline'] = null;
      });
    }
  }

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillController.text.trim());
        _skillController.clear();
      });
    }
  }

  void _removeSkill(int index) => setState(() => _skills.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? "Edit Internship" : "Create Internship",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              isEdit
                  ? "Update internship details"
                  : "Fill in the details to post a new internship",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.w300),
            ),
          ],
        ),
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
            // ── Error summary ────────────────────────
            if (_errors.values.any((e) => e != null))
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _errors.values
                      .where((e) => e != null)
                      .map((e) => Text("• $e",
                      style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),

            // ── Internship Information ───────────────
            SectionWidget(
              title: "Internship Information",
              children: [
                TextFieldWidget(
                  controller: _titleController,
                  label: "Internship Title",
                  hint: "e.g., Software Development Intern",
                ),
                if (_errors['title'] != null)
                  _errorText(_errors['title']!),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: "Type",
                        items: _internshipTypes,
                        value: _internshipType,
                        onChanged: (v) => setState(() {
                          _internshipType = v;
                          _errors['type'] = null;
                        }),
                        hint: "Select type",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomDropdown(
                        label: "Duration",
                        items: _durations,
                        value: _duration,
                        onChanged: (v) => setState(() {
                          _duration = v;
                          _errors['duration'] = null;
                        }),
                        hint: "Select duration",
                      ),
                    ),
                  ],
                ),
                if (_errors['type'] != null)
                  _errorText(_errors['type']!),
                if (_errors['duration'] != null)
                  _errorText(_errors['duration']!),
                const SizedBox(height: 12),
                if (_internshipType == "On-site 🏢" ||
                    _internshipType == "Hybrid 🔄") ...[
                  TextFieldWidget(
                    controller: _locationController,
                    label: "Location",
                    hint: "e.g., Cairo, Egypt",
                  ),
                  if (_errors['location'] != null)
                    _errorText(_errors['location']!),
                  const SizedBox(height: 12),
                ],
                SwitchListTile(
                  title: const Text("This internship is paid"),
                  value: _isPaid,
                  onChanged: (v) => setState(() => _isPaid = v),
                  activeColor: const Color(0xff1676C4),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                TextFieldWidget(
                  controller: _maxTraineesController,
                  label: "Maximum Trainees",
                  hint: "Optional",
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Description ──────────────────────────
            SectionWidget(
              title: "Internship Description",
              children: [
                TextAreaWidget(
                  controller: _descController,
                  label: "Description",
                  hint: "What will trainees do?",
                  maxLines: 6,
                ),
                if (_errors['description'] != null)
                  _errorText(_errors['description']!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Skills ───────────────────────────────
            SectionWidget(
              title: "Required Skills",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _skillController,
                        decoration: InputDecoration(
                          hintText: "Add a skill",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xff1676C4), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _addSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addSkill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1676C4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_skills.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.stars,
                            color: Colors.grey[400], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'No skills added yet.',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _skills
                        .asMap()
                        .entries
                        .map((entry) => Chip(
                      label: Text(entry.value),
                      deleteIcon:
                      const Icon(Icons.close, size: 18),
                      onDeleted: () =>
                          _removeSkill(entry.key),
                      backgroundColor:
                      const Color(0xff1676C4).withOpacity(0.1),
                      deleteIconColor: const Color(0xff1676C4),
                    ))
                        .toList(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Requirements ─────────────────────────
            SectionWidget(
              title: "Requirements",
              children: [
                TextAreaWidget(
                  controller: _requirementsController,
                  label: "Requirements",
                  hint: "Enter each requirement on a separate line.",
                  maxLines: 8,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Deadline ─────────────────────────────
            SectionWidget(
              title: "Application Deadline",
              children: [
                DateFieldWidget(
                  controller: _deadlineController,
                  label: "Deadline",
                  hint: "Select Date",
                  errorText: _errors['deadline'],
                  onTap: _pickDate,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ───────────────────────
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _save(true),
                    icon: Icon(isEdit
                        ? Icons.save_outlined
                        : Icons.publish_outlined),
                    label: Text(isEdit ? "Save Changes" : "Publish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1676C4),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _errorText(String message) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Text(message,
        style: const TextStyle(color: Colors.red, fontSize: 12)),
  );
}