// ignore_for_file: avoid_print
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../../../data/repositories/Job repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';

class CreateEditJobScreen extends StatefulWidget {
  final Map<String, dynamic>? jobData;

  const CreateEditJobScreen({this.jobData, super.key});

  @override
  State<CreateEditJobScreen> createState() => _CreateEditJobScreenState();
}

class _CreateEditJobScreenState extends State<CreateEditJobScreen> {
  final jobRepo = JobRepository();

  final TextEditingController _titleController       = TextEditingController();
  final TextEditingController _descController        = TextEditingController();
  final TextEditingController _locationController    = TextEditingController();
  final TextEditingController _salaryMinController   = TextEditingController();
  final TextEditingController _salaryMaxController   = TextEditingController();
  final TextEditingController _deadlineController    = TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _skillController       = TextEditingController();

  String? _locationType;
  String? _experienceLevel;
  String? _jobType;

  final List<String> _locationTypes    = ["Remote", "On-site", "Hybrid"];
  final List<String> _experienceLevels = [
    "Early Level",
    "Mid Level",
    "Senior Level",
    "Senior Manager",
  ];
  final List<String> _jobTypes = [
    "Full-time",
    "Part-time",
    "Contract",
    "Internship",
    "Freelance",
  ];

  List<String> _requirements = [];
  List<String> _skills       = [];

  String? _logoPath;
  Map<String, String> _errors = {};
  bool _isLoading = false;

  bool get isEdit => widget.jobData != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.jobData != null) {
      final job = widget.jobData!;

      // ── Debug: طباعة كل الـ fields الجاية من الـ API ──
      debugPrint("🔍 [JOB DATA KEYS]: ${job.keys.toList()}");
      debugPrint("🔍 [DEADLINE RAW]: ${job['deadline']}");
      debugPrint("🔍 [APPLICATION DEADLINE]: ${job['applicationDeadline']}");
      debugPrint("🔍 [CLOSING DATE]: ${job['closingDate']}");

      _titleController.text    = job['title'] ?? '';
      _descController.text     = job['description'] ?? '';
      _locationController.text = job['location'] == 'Remote' ? '' : (job['location'] ?? '');
      _logoPath                = job['companyLogo'];
      _locationType            = job['locationType'] ?? job['jobType'];
      _experienceLevel         = job['experienceLevel'];
      _jobType                 = job['employmentType'];

      final salaryRange = job['salaryRange']?.toString() ?? '';
      if (salaryRange.contains('-')) {
        final parts = salaryRange.split('-');
        _salaryMinController.text = parts[0].trim();
        _salaryMaxController.text = parts[1].trim();
      } else {
        _salaryMinController.text = job['salaryMin']?.toString() ?? '';
        _salaryMaxController.text = job['salaryMax']?.toString() ?? '';
      }

      // ── Deadline: جرب كل الأسماء الممكنة للـ field ──
      final rawDeadline = job['deadline'] ??
          job['applicationDeadline'] ??
          job['closingDate'] ??
          job['expiry'] ??
          job['expiryDate'] ??
          '';

      _deadlineController.text = rawDeadline.toString().isNotEmpty
          ? rawDeadline.toString().split('T')[0]
          : '';

      debugPrint("🔍 [DEADLINE FINAL]: ${_deadlineController.text}");

      _requirements = _parseListField(job['requirements']);
      _skills       = _parseListField(job['requiredSkills'] ?? job['skills']);
    }
  }

  List<String> _parseListField(dynamic value) {
    if (value == null) return [];
    if (value is List) return List<String>.from(value.map((e) => e.toString()));
    if (value is String && value.isNotEmpty) {
      return value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _deadlineController.dispose();
    _requirementController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    _errors.clear();

    if (_titleController.text.trim().isEmpty)
      _errors['title'] = 'Job title is required';
    if (_descController.text.trim().isEmpty)
      _errors['description'] = 'Description is required';
    if (_locationType == null)
      _errors['locationType'] = 'Location type is required';
    if ((_locationType == "On-site" || _locationType == "Hybrid") &&
        _locationController.text.trim().isEmpty)
      _errors['location'] = 'Location is required for onsite/hybrid jobs';
    if (_salaryMinController.text.trim().isEmpty)
      _errors['salaryMin'] = 'Minimum salary is required';
    if (_salaryMaxController.text.trim().isEmpty)
      _errors['salaryMax'] = 'Maximum salary is required';
    if (_experienceLevel == null)
      _errors['experienceLevel'] = 'Experience level is required';
    if (_jobType == null)
      _errors['jobType'] = 'Job type is required';
    if (_deadlineController.text.trim().isEmpty)
      _errors['deadline'] = 'Application deadline is required';

    setState(() {});
    return _errors.isEmpty;
  }

  Future<void> _saveJob({bool isDraft = false}) async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    try {
      final salaryRange =
          '${_salaryMinController.text.trim()} - ${_salaryMaxController.text.trim()}';

      final requiredSkillsStr = _skills.join(', ');

      File? logoFile;
      if (_logoPath != null && !_logoPath!.startsWith('http')) {
        logoFile = File(_logoPath!);
      }

      final String jobTypeToSend = _locationType!;
      final String locationToSend = _locationType == 'Remote'
          ? 'Remote'
          : _locationController.text.trim();

      Response? response;

      if (isEdit) {
        response = await jobRepo.updateJob(
          jobId:           widget.jobData!['id'].toString(),
          title:           _titleController.text.trim(),
          description:     _descController.text.trim(),
          requiredSkills:  requiredSkillsStr,
          experienceLevel: _experienceLevel!,
          jobType:         jobTypeToSend,
          location:        locationToSend,
          salaryRange:     salaryRange,
          deadline:        _deadlineController.text.trim(), // ✅ deadline
          companyLogo:     logoFile,
        );
      } else {
        response = await jobRepo.createJob(
          title:           _titleController.text.trim(),
          description:     _descController.text.trim(),
          requiredSkills:  requiredSkillsStr,
          experienceLevel: _experienceLevel!,
          jobType:         jobTypeToSend,
          location:        locationToSend,
          salaryRange:     salaryRange,
          deadline:        _deadlineController.text.trim(), // ✅ deadline
          companyLogo:     logoFile,
        );
      }

      debugPrint("📦 Response status: ${response?.statusCode}");
      debugPrint("📦 Response data:   ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit
                ? 'Job updated successfully!'
                : 'Job published successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed: ${response?.statusCode ?? 'No response'}\n${response?.data ?? ''}',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException: ${e.response?.statusCode}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Network error: ${e.response?.statusCode}\n${e.response?.data ?? e.message}',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint("❌ General Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unexpected error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
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
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() =>
      controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_requirementController.text.trim());
        _requirementController.clear();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Job" : "Create New Job",
          style: const TextStyle(color: Colors.white),
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
            if (_errors.isNotEmpty)
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
                      .map((e) => Text("• $e",
                      style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),

            // ── Job Information ──────────────────────────────
            SectionWidget(
              title: "Job Information",
              children: [
                TextFieldWidget(
                  controller: _titleController,
                  label: "Job Title",
                  hint: "e.g., Senior React Developer",
                ),
                if (_errors.containsKey('title'))
                  _errorText(_errors['title']!),
                const SizedBox(height: 12),
                TextAreaWidget(
                  controller: _descController,
                  label: "Job Description",
                  hint: "Write a clear description of the role...",
                ),
                if (_errors.containsKey('description'))
                  _errorText(_errors['description']!),
                const SizedBox(height: 12),
                UploadContainerWidget(
                  title: "Company Logo",
                  selectedImagePath: _logoPath,
                  onImageChanged: (path) =>
                      setState(() => _logoPath = path),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Location & Employment ────────────────────────
            SectionWidget(
              title: "Location & Employment",
              children: [
                CustomDropdown(
                  label: "Location Type",
                  items: _locationTypes,
                  value: _locationType,
                  hint: "Select Location Type",
                  onChanged: (v) => setState(() {
                    _locationType = v;
                    _errors.remove('locationType');
                  }),
                ),
                if (_errors.containsKey('locationType'))
                  _errorText(_errors['locationType']!),
                const SizedBox(height: 12),
                if (_locationType == "On-site" ||
                    _locationType == "Hybrid") ...[
                  TextFieldWidget(
                    controller: _locationController,
                    label: "Location",
                    hint: "e.g., Cairo, Egypt",
                  ),
                  if (_errors.containsKey('location'))
                    _errorText(_errors['location']!),
                  const SizedBox(height: 12),
                ],
                CustomDropdown(
                  label: "Job Type",
                  items: _jobTypes,
                  value: _jobType,
                  hint: "Select Job Type",
                  onChanged: (v) => setState(() {
                    _jobType = v;
                    _errors.remove('jobType');
                  }),
                ),
                if (_errors.containsKey('jobType'))
                  _errorText(_errors['jobType']!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Salary & Experience ──────────────────────────
            SectionWidget(
              title: "Salary & Experience",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFieldWidget(
                        controller: _salaryMinController,
                        label: "Min Salary",
                        hint: "e.g., 80000",
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFieldWidget(
                        controller: _salaryMaxController,
                        label: "Max Salary",
                        hint: "e.g., 120000",
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
                if (_errors.containsKey('salaryMin') ||
                    _errors.containsKey('salaryMax'))
                  _errorText(
                      _errors['salaryMin'] ?? _errors['salaryMax'] ?? ''),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: "Experience Level",
                  items: _experienceLevels,
                  value: _experienceLevel,
                  hint: "Select Experience Level",
                  onChanged: (v) => setState(() {
                    _experienceLevel = v;
                    _errors.remove('experienceLevel');
                  }),
                ),
                if (_errors.containsKey('experienceLevel'))
                  _errorText(_errors['experienceLevel']!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Requirements ─────────────────────────────────
            SectionWidget(
              title: "Requirements",
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _requirementController,
                        decoration: InputDecoration(
                          hintText: "Add a requirement",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: Color(0xff1676C4), width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _addRequirement(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _addRequirement,
                      icon: const Icon(Icons.add_circle,
                          color: Color(0xff1676C4)),
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_requirements.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _requirements
                        .asMap()
                        .entries
                        .map((entry) => Chip(
                      label: Text(entry.value),
                      deleteIcon:
                      const Icon(Icons.close, size: 18),
                      onDeleted: () => setState(() =>
                          _requirements.removeAt(entry.key)),
                      backgroundColor: const Color(0xff1676C4)
                          .withOpacity(0.1),
                      deleteIconColor: const Color(0xff1676C4),
                    ))
                        .toList(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Skills ───────────────────────────────────────
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
                    IconButton(
                      onPressed: _addSkill,
                      icon: const Icon(Icons.add_circle,
                          color: Color(0xff1676C4)),
                      iconSize: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_skills.isNotEmpty)
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
                      onDeleted: () => setState(
                              () => _skills.removeAt(entry.key)),
                      backgroundColor:
                      Colors.green.withOpacity(0.1),
                      deleteIconColor: Colors.green,
                    ))
                        .toList(),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Deadline ─────────────────────────────────────
            SectionWidget(
              title: "Application Deadline",
              children: [
                DateFieldWidget(
                  controller: _deadlineController,
                  label: "Deadline",
                  hint: "Select Date",
                  onTap: () => _pickDate(_deadlineController),
                ),
                if (_errors.containsKey('deadline'))
                  _errorText(_errors['deadline']!),
              ],
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ───────────────────────────────
            if (isEdit)
              ElevatedButton.icon(
                onPressed: _isLoading ? null : () => _saveJob(),
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1676C4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              Row(
                children: [

                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                      _isLoading ? null : () => _saveJob(),
                      icon: const Icon(Icons.publish),
                      label: const Text("Publish"),
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