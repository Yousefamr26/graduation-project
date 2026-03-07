import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/models/company/internship-model.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';
import 'Internship mock data.dart';


class CreateEditInternshipScreen extends StatefulWidget {
  final InternshipModel? internship;

  const CreateEditInternshipScreen({this.internship, super.key});

  @override
  State<CreateEditInternshipScreen> createState() => _CreateEditInternshipScreenState();
}

class _CreateEditInternshipScreenState extends State<CreateEditInternshipScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _companyNameController;
  late TextEditingController _locationController;
  late TextEditingController _maxTraineesController;
  late TextEditingController _deadlineController;
  late TextEditingController _requirementsController;

  String? _internshipType;
  String? _duration;

  final List<String> _internshipTypes = ["On-site 🏢", "Remote 🌐", "Hybrid 🔄"];
  final List<String> _durations = ["1 month", "2 months", "3 months", "6 months", "1 year"];

  String? _logoPath;
  bool _isPaid = false;
  List<String> _skills = [];
  final TextEditingController _skillController = TextEditingController();

  Map<String, String?> _errors = {};
  bool _isSubmitting = false;

  bool get isEditMode => widget.internship != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    if (isEditMode) {
      final internship = widget.internship!;
      _titleController = TextEditingController(text: internship.title);
      _descController = TextEditingController(text: internship.description);
      _companyNameController = TextEditingController(text: internship.companyName);
      _locationController = TextEditingController(text: internship.location);
      _maxTraineesController = TextEditingController(text: internship.maxTrainees?.toString() ?? '');
      _deadlineController = TextEditingController(text: internship.deadline);
      _requirementsController = TextEditingController(text: internship.requirements.join('\n'));
      _internshipType = internship.type;
      _duration = internship.duration;
      _logoPath = internship.logoPath;
      _isPaid = internship.isPaid;
      _skills = List<String>.from(internship.skills);
    } else {
      _titleController = TextEditingController();
      _descController = TextEditingController();
      _companyNameController = TextEditingController();
      _locationController = TextEditingController();
      _maxTraineesController = TextEditingController();
      _deadlineController = TextEditingController();
      _requirementsController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _companyNameController.dispose();
    _locationController.dispose();
    _maxTraineesController.dispose();
    _deadlineController.dispose();
    _requirementsController.dispose();
    _skillController.dispose();
    super.dispose();
  }

  bool _validateForm({required bool isDraft}) {
    setState(() => _errors = {});
    bool isValid = true;

    if (isDraft) return true;

    if (_titleController.text.trim().isEmpty) {
      _errors['title'] = 'Internship title is required';
      isValid = false;
    }
    if (_descController.text.trim().isEmpty) {
      _errors['description'] = 'Description is required';
      isValid = false;
    }
    if (_internshipType == null) {
      _errors['type'] = 'Internship type is required';
      isValid = false;
    }
    if ((_internshipType == "On-site 🏢" || _internshipType == "Hybrid 🔄") &&
        _locationController.text.trim().isEmpty) {
      _errors['location'] = 'Location is required for on-site/hybrid internships';
      isValid = false;
    }
    if (_duration == null) {
      _errors['duration'] = 'Duration is required';
      isValid = false;
    }
    if (_deadlineController.text.trim().isEmpty) {
      _errors['deadline'] = 'Application deadline is required';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return isValid;
  }

  Future<void> _handleSubmit({required bool isDraft}) async {
    if (_isSubmitting) return;
    if (!_validateForm(isDraft: isDraft)) return;

    setState(() => _isSubmitting = true);

    try {
      final internshipModel = _createInternshipModel(
        status: isEditMode ? widget.internship!.status : (isDraft ? "Draft" : "Published"),
        // ✅ FIX: ?? fallback لو الـ id كان null
        id: isEditMode
            ? (widget.internship!.id ?? InternshipMockData.generateMockId())
            : InternshipMockData.generateMockId(),
      );

      // ✅ MOCK: Create/Update في الـ static list
      if (isEditMode) {
        InternshipMockData.updateInternship(internshipModel.id, internshipModel);
      } else {
        InternshipMockData.addInternship(internshipModel);
      }

      // ❌ BACKEND:
      // if (isEditMode) {
      //   await _internshipRepo.updateInternship(internshipModel);
      // } else {
      //   await _internshipRepo.createInternship(internshipModel);
      // }

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        String message = isEditMode
            ? 'Changes saved successfully!'
            : isDraft
            ? 'Draft saved successfully!'
            : 'Internship published successfully!';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, internshipModel);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InternshipModel _createInternshipModel({required String status, required String id}) {
    final requirements = _requirementsController.text
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => line.trim())
        .toList();

    return InternshipModel(
      id: id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      companyName: _companyNameController.text.trim(),
      logoPath: _logoPath,
      type: _internshipType!,
      location: _locationController.text.trim(),
      isPaid: _isPaid,
      duration: _duration!,
      maxTrainees: _maxTraineesController.text.isEmpty
          ? null
          : int.tryParse(_maxTraineesController.text),
      skills: _skills,
      requirements: requirements,
      postedDate: isEditMode
          ? widget.internship!.postedDate
          : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      deadline: _deadlineController.text,
      applicantsCount: isEditMode ? widget.internship!.applicantsCount : 0,
      status: status,
      isFeatured: isEditMode ? widget.internship!.isFeatured : false,
    );
  }

  Future<void> _pickDate(TextEditingController controller, String field) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff1676C4),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
        _errors[field] = null;
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
              isEditMode ? "Edit Internship" : "Create New Internship",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            Text(
              isEditMode
                  ? "Update internship details"
                  : "Fill in the details to post a new internship opportunity",
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
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
              // Internship Information
              SectionWidget(
                title: "Internship Information",
                children: [
                  TextFieldWidget(
                    controller: _titleController,
                    label: "Internship Title",
                    hint: "e.g., Software Development Intern",
                  ),
                  if (_errors['title'] != null) ...[
                    const SizedBox(height: 4),
                    Text(_errors['title']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  TextFieldWidget(
                    controller: _companyNameController,
                    label: "Company Name (Optional)",
                    hint: "e.g., TechCorp Solutions",
                  ),
                  const SizedBox(height: 12),
                  UploadContainerWidget(
                    title: "Upload Company Logo",
                    selectedImagePath: _logoPath,
                    onImageChanged: (path) => setState(() => _logoPath = path),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomDropdown(
                          label: "Type",
                          items: _internshipTypes,
                          value: _internshipType,
                          onChanged: (v) => setState(() { _internshipType = v; _errors['type'] = null; }),
                          hint: "Select type",
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomDropdown(
                          label: "Duration",
                          items: _durations,
                          value: _duration,
                          onChanged: (v) => setState(() { _duration = v; _errors['duration'] = null; }),
                          hint: "Select duration",
                        ),
                      ),
                    ],
                  ),
                  if (_errors['type'] != null) ...[
                    const SizedBox(height: 4),
                    Text(_errors['type']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 12),
                  if (_internshipType == "On-site 🏢" || _internshipType == "Hybrid 🔄") ...[
                    TextFieldWidget(
                      controller: _locationController,
                      label: "Location",
                      hint: "e.g., Cairo, Egypt",
                    ),
                    if (_errors['location'] != null) ...[
                      const SizedBox(height: 4),
                      Text(_errors['location']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                    ],
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
                    label: "Maximum Trainees (Optional)",
                    hint: "Optional - Maximum number of trainees to accept",
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Internship Description
              SectionWidget(
                title: "Internship Description",
                children: [
                  TextAreaWidget(
                    controller: _descController,
                    label: "Description",
                    hint: "This will be shown in the internship details",
                    maxLines: 6,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "${_descController.text.length} characters • This will be shown in the internship details",
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ),
                  if (_errors['description'] != null) ...[
                    const SizedBox(height: 4),
                    Text(_errors['description']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                ],
              ),

              const SizedBox(height: 16),

              // Required Skills
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
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xff1676C4), width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addSkill,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff1676C4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                          Icon(Icons.stars, color: Colors.grey[400], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            'No skills added yet. Add required skills above.',
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Examples: Python, Java, JavaScript, React, Machine Learning, etc.',
                            style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _skills.asMap().entries.map((entry) {
                        return Chip(
                          label: Text(entry.value),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => _removeSkill(entry.key),
                          backgroundColor: const Color(0xff1676C4).withOpacity(0.1),
                          deleteIconColor: const Color(0xff1676C4),
                        );
                      }).toList(),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // Requirements
              SectionWidget(
                title: "Requirements",
                children: [
                  TextAreaWidget(
                    controller: _requirementsController,
                    label: "Requirements",
                    hint: "Enter each requirement on a separate line. Each line will appear as a bullet point.",
                    maxLines: 8,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Deadline
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

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _handleSubmit(isDraft: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1676C4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(isEditMode ? "Save Changes" : "Post Internship"),
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