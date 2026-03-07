import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/job-model.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';
import 'JobmockData.dart';

class CreateEditJobScreen extends StatefulWidget {
  final JobModel? job;

  const CreateEditJobScreen({this.job, super.key});

  @override
  State<CreateEditJobScreen> createState() => _CreateEditJobScreenState();
}

class _CreateEditJobScreenState extends State<CreateEditJobScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _companyNameController;
  late TextEditingController _locationController;
  late TextEditingController _salaryMinController;
  late TextEditingController _salaryMaxController;
  late TextEditingController _deadlineController;

  // Dropdown values
  String? _locationType;
  String? _experienceLevel;
  String? _employmentType;

  final List<String> _locationTypes = ["Remote", "Onsite", "Hybrid"];
  final List<String> _experienceLevels = [
    "Intern",
    "Junior (0-2 years)",
    "Mid-level (2-5 years)",
    "Senior (5+ years)",
    "Lead/Manager"
  ];
  final List<String> _employmentTypes = [
    "Full-time", "Part-time", "Contract", "Internship", "Freelance"
  ];

  // Logo
  String? _logoPath;

  // Requirements and Skills
  List<String> _requirements = [];
  List<String> _skills = [];
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _skillController = TextEditingController();

  // Validation
  Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  bool get isEditMode => widget.job != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (isEditMode) {
      final job = widget.job!;
      _titleController = TextEditingController(text: job.title);
      _descController = TextEditingController(text: job.description);
      _companyNameController = TextEditingController(text: job.companyName);
      _locationController = TextEditingController(text: job.location);
      _salaryMinController = TextEditingController(text: job.salaryMin);
      _salaryMaxController = TextEditingController(text: job.salaryMax);
      _deadlineController = TextEditingController(text: job.deadline);
      _locationType = job.locationType;
      _experienceLevel = job.experienceLevel;
      _employmentType = job.employmentType;
      _logoPath = job.logoPath;
      _requirements = List<String>.from(job.requirements);
      _skills = List<String>.from(job.skills);
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _companyNameController = TextEditingController();
      _locationController = TextEditingController();
      _salaryMinController = TextEditingController();
      _salaryMaxController = TextEditingController();
      _deadlineController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _deadlineController.dispose();
    _requirementController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  bool _validateForm({required bool isDraft}) {
    setState(() => _errors = {});
    bool isValid = true;

    if (isDraft) return true;

    if (_titleController.text.trim().isEmpty) { _errors['title'] = 'Job title is required'; isValid = false; }
    if (_descController.text.trim().isEmpty) { _errors['description'] = 'Description is required'; isValid = false; }
    if (_locationType == null) { _errors['locationType'] = 'Location type is required'; isValid = false; }
    if ((_locationType == "Onsite" || _locationType == "Hybrid") && _locationController.text.trim().isEmpty) {
      _errors['location'] = 'Location is required for onsite/hybrid jobs'; isValid = false;
    }
    if (_salaryMinController.text.trim().isEmpty) { _errors['salaryMin'] = 'Minimum salary is required'; isValid = false; }
    if (_salaryMaxController.text.trim().isEmpty) { _errors['salaryMax'] = 'Maximum salary is required'; isValid = false; }
    if (_experienceLevel == null) { _errors['experienceLevel'] = 'Experience level is required'; isValid = false; }
    if (_employmentType == null) { _errors['employmentType'] = 'Employment type is required'; isValid = false; }
    if (_deadlineController.text.trim().isEmpty) { _errors['deadline'] = 'Application deadline is required'; isValid = false; }

    if (!isValid) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
    return isValid;
  }

  Future<void> _handleSubmit({required bool isDraft, bool isEdit = false}) async {
    if (_isSubmitting) return;
    if (!_validateForm(isDraft: isDraft)) return;

    setState(() => _isSubmitting = true);

    try {
      // ✅ MOCK: simulate delay
      await Future.delayed(const Duration(milliseconds: 500));

      final jobModel = _createJobModel(
        status: isEdit ? widget.job!.status : (isDraft ? "Draft" : "Published"),
        id: isEdit ? widget.job!.id : JobMockData.generateMockId(),
      );

      // ✅ MOCK: Create/Update في الـ static list
      if (isEdit) {
        JobMockData.updateJob(jobModel.id, jobModel);
      } else {
        JobMockData.addJob(jobModel);
      }

      // ❌ BACKEND:
      // if (isEdit) {
      //   await _jobRepo.updateJob(jobModel);
      // } else {
      //   await _jobRepo.createJob(jobModel);
      // }

      if (mounted) {
        String message = isEdit
            ? 'Changes saved successfully!'
            : isDraft ? 'Draft saved successfully!' : 'Job published successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
        );

        Navigator.pop(context, jobModel); // ← بيرجع JobModel لـ JobsScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  JobModel _createJobModel({required String status, required String id}) {
    return JobModel(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      logoPath: _logoPath,
      companyName: _companyNameController.text.trim(),
      locationType: _locationType ?? 'Remote',
      location: _locationController.text.trim(),
      salaryMin: _salaryMinController.text.trim(),
      salaryMax: _salaryMaxController.text.trim(),
      experienceLevel: _experienceLevel ?? 'Junior (0-2 years)',
      requirements: _requirements,
      skills: _skills,
      employmentType: _employmentType ?? 'Full-time',
      postedDate: isEditMode ? widget.job!.postedDate : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      deadline: _deadlineController.text,
      applicantsCount: isEditMode ? widget.job!.applicantsCount : 0,
      status: status,
      isFeatured: isEditMode ? widget.job!.isFeatured : false,
    );
  }

  Future<void> _pickDate(TextEditingController controller, String field) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xff1676C4), onPrimary: Colors.white, onSurface: Colors.black),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _errors[field] = null;
      });
    }
  }

  void _addRequirement() {
    if (_requirementController.text.trim().isNotEmpty) {
      setState(() { _requirements.add(_requirementController.text.trim()); _requirementController.clear(); });
    }
  }

  void _removeRequirement(int index) => setState(() => _requirements.removeAt(index));

  void _addSkill() {
    if (_skillController.text.trim().isNotEmpty) {
      setState(() { _skills.add(_skillController.text.trim()); _skillController.clear(); });
    }
  }

  void _removeSkill(int index) => setState(() => _skills.removeAt(index));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? "Edit Job" : "Create New Job", style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1676C4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── Job Information ──────────────────────────────────
              SectionWidget(
                title: "Job Information",
                children: [
                  TextFieldWidget(controller: _titleController, label: "Job Title", hint: "e.g., Senior React Developer"),
                  if (_errors['title'] != null) ...[const SizedBox(height: 4), Text(_errors['title']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                  const SizedBox(height: 12),
                  TextFieldWidget(controller: _companyNameController, label: "Company Name (Optional)", hint: "e.g., TechCorp Solutions"),
                  const SizedBox(height: 12),
                  TextAreaWidget(controller: _descController, label: "Job Description", hint: "Write a clear description of the role..."),
                  if (_errors['description'] != null) ...[const SizedBox(height: 4), Text(_errors['description']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                  const SizedBox(height: 12),
                  UploadContainerWidget(
                    title: "Upload Company Logo",
                    selectedImagePath: _logoPath,
                    onImageChanged: (path) => setState(() => _logoPath = path),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Location & Employment ────────────────────────────
              SectionWidget(
                title: "Location & Employment",
                children: [
                  CustomDropdown(label: "Location Type", items: _locationTypes, value: _locationType, hint: "Select Location Type",
                    onChanged: (v) => setState(() { _locationType = v; _errors['locationType'] = null; }),
                  ),
                  if (_errors['locationType'] != null) ...[const SizedBox(height: 4), Text(_errors['locationType']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                  const SizedBox(height: 12),
                  if (_locationType == "Onsite" || _locationType == "Hybrid") ...[
                    TextFieldWidget(controller: _locationController, label: "Location", hint: "e.g., Cairo, Egypt"),
                    if (_errors['location'] != null) ...[const SizedBox(height: 4), Text(_errors['location']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                    const SizedBox(height: 12),
                  ],
                  CustomDropdown(label: "Employment Type", items: _employmentTypes, value: _employmentType, hint: "Select Employment Type",
                    onChanged: (v) => setState(() { _employmentType = v; _errors['employmentType'] = null; }),
                  ),
                  if (_errors['employmentType'] != null) ...[const SizedBox(height: 4), Text(_errors['employmentType']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                ],
              ),

              const SizedBox(height: 16),

              // ── Salary & Experience ──────────────────────────────
              SectionWidget(
                title: "Salary & Experience",
                children: [
                  Row(
                    children: [
                      Expanded(child: TextFieldWidget(controller: _salaryMinController, label: "Min Salary", hint: "\$80,000", keyboardType: TextInputType.text)),
                      const SizedBox(width: 10),
                      Expanded(child: TextFieldWidget(controller: _salaryMaxController, label: "Max Salary", hint: "\$120,000", keyboardType: TextInputType.text)),
                    ],
                  ),
                  if (_errors['salaryMin'] != null || _errors['salaryMax'] != null) ...[
                    const SizedBox(height: 4),
                    Text(_errors['salaryMin'] ?? _errors['salaryMax'] ?? '', style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  CustomDropdown(label: "Experience Level", items: _experienceLevels, value: _experienceLevel, hint: "Select Experience Level",
                    onChanged: (v) => setState(() { _experienceLevel = v; _errors['experienceLevel'] = null; }),
                  ),
                  if (_errors['experienceLevel'] != null) ...[const SizedBox(height: 4), Text(_errors['experienceLevel']!, style: const TextStyle(color: Colors.red, fontSize: 12))],
                ],
              ),

              const SizedBox(height: 16),

              // ── Requirements ─────────────────────────────────────
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: _addRequirement, icon: const Icon(Icons.add_circle, color: Color(0xff1676C4)), iconSize: 32),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_requirements.isNotEmpty)
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _requirements.asMap().entries.map((entry) => Chip(
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeRequirement(entry.key),
                        backgroundColor: const Color(0xff1676C4).withOpacity(0.1),
                        deleteIconColor: const Color(0xff1676C4),
                      )).toList(),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Skills ───────────────────────────────────────────
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xff1676C4), width: 2)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: _addSkill, icon: const Icon(Icons.add_circle, color: Color(0xff1676C4)), iconSize: 32),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_skills.isNotEmpty)
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _skills.asMap().entries.map((entry) => Chip(
                        label: Text(entry.value),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSkill(entry.key),
                        backgroundColor: Colors.green.withOpacity(0.1),
                        deleteIconColor: Colors.green,
                      )).toList(),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Deadline ─────────────────────────────────────────
              SectionWidget(
                title: "Application Deadline",
                children: [
                  DateFieldWidget(
                    controller: _deadlineController,
                    label: "Deadline",
                    hint: "Select Date",
                    errorText: _errors['deadline'],
                    onTap: () => _pickDate(_deadlineController, 'deadline'),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Action Buttons ───────────────────────────────────
              if (isEditMode)
                ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: false, isEdit: true),
                  icon: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                      : const Icon(Icons.save),
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
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: true),
                        icon: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Color(0xff1676C4))))
                            : const Icon(Icons.save_outlined),
                        label: const Text("Save Draft"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff1676C4),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xff1676C4), width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: false),
                        icon: _isSubmitting
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Icon(Icons.publish),
                        label: const Text("Publish"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1676C4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}