// ignore_for_file: avoid_print
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import '../../../../../../data/repositories/Workshop repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';

class CreateEditWorkshopScreen extends StatefulWidget {
  final Map<String, dynamic>? workshopData;

  const CreateEditWorkshopScreen({super.key, this.workshopData});

  @override
  State<CreateEditWorkshopScreen> createState() =>
      _CreateEditWorkshopScreenState();
}

class _CreateEditWorkshopScreenState extends State<CreateEditWorkshopScreen> {
  final workshopRepo = WorkshopRepository();

  // ── Controllers ──────────────────────────────────────────────────────────
  final TextEditingController _titleController     = TextEditingController();
  final TextEditingController _descController      = TextEditingController();
  final TextEditingController _locationController  = TextEditingController();
  final TextEditingController _capacityController  = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController   = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController   = TextEditingController();

  // ── Dropdowns ─────────────────────────────────────────────────────────────
  String? _workshopType;
  String? _hostType;
  int?    _universityId;

  // ── Toggles ───────────────────────────────────────────────────────────────
  bool   _requireCV       = false;
  bool   _requireRoadmap  = false;
  double _minimumProgress = 0;

  // ── Lists ─────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _materials  = [];
  List<Map<String, dynamic>> _activities = [];

  // ── State ─────────────────────────────────────────────────────────────────
  String?             _bannerPath;
  Map<String, String> _errors    = {};
  bool                _isLoading = false;

  bool get isEdit => widget.workshopData != null;

  final List<Map<String, dynamic>> _universities = [
    {"id": 1, "name": "Cairo University"},
    {"id": 2, "name": "Ain Shams University"},
    {"id": 3, "name": "Alexandria University"},
    {"id": 4, "name": "Mansoura University"},
    {"id": 5, "name": "Helwan University"},
  ];

  // ── Material types ────────────────────────────────────────────────────────
  static const List<String> _materialTypes = [
    "PDF",
    "Video",
    "Document",
    "Presentation",
  ];

  // ── Difficulty levels ─────────────────────────────────────────────────────
  static const List<String> _difficultyLevels = ["Easy", "Medium", "Hard"];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.workshopData != null) {
      final d = widget.workshopData!;
      _titleController.text    = d['title']       ?? '';
      _descController.text     = d['description'] ?? '';
      _locationController.text = d['location']    ?? '';
      _capacityController.text =
          d['maxCapacity']?.toString() ?? d['capacity']?.toString() ?? '';
      _workshopType   = d['workshopType'];
      _hostType       = d['hostType'];
      _universityId   = d['universityId'];
      _bannerPath     = d['banner'] ?? d['coverImagePath'];
      _requireCV      = d['requireCV'] ?? d['requireCv'] ?? false;
      _requireRoadmap = d['requireRoadmapCompletion'] ?? d['requireRoadmap'] ?? false;
      _minimumProgress = (d['minimumProgress'] ?? 0).toDouble();

      if (d['startDate'] != null)
        _startDateController.text = d['startDate'].toString().split('T')[0];
      if (d['endDate'] != null)
        _endDateController.text = d['endDate'].toString().split('T')[0];
      _startTimeController.text = d['startTime'] ?? '';
      _endTimeController.text   = d['endTime']   ?? '';

      // ── Materials ──────────────────────────────────────────────────────
      final mats = d['materials'] ?? [];
      for (var m in mats) {
        _materials.add({
          "id":                m['id'],
          "titleController":   TextEditingController(text: m['title'] ?? ''),
          "pointsController":  TextEditingController(text: (m['points'] ?? 1).toString()),
          "pageCountController": TextEditingController(text: (m['pageCount'] ?? 1).toString()),
          "durationController":  TextEditingController(text: (m['duration'] ?? 0).toString()),
          "type":      m['type'] ?? m['materialType'],
          "fileName":  m['fileName'] ?? m['filePath'],
          "points":    m['points'] ?? 1,
          "pageCount": m['pageCount'] ?? 1,
          "duration":  m['duration'] ?? 0,
          "file":      null,
        });
      }

      // ── Activities ─────────────────────────────────────────────────────
      final acts = d['activities'] ?? [];
      for (var a in acts) {
        _activities.add({
          "id":               a['id'],
          "titleController":  TextEditingController(text: a['title'] ?? ''),
          "nameController":   TextEditingController(text: a['name'] ?? ''),
          "descController":   TextEditingController(text: a['description'] ?? ''),
          "pointsController": TextEditingController(text: (a['points'] ?? 0).toString()),
          "difficulty": a['difficulty'],
          "points":     a['points'] ?? 0,
        });
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    for (var m in _materials) {
      (m['titleController']    as TextEditingController?)?.dispose();
      (m['pointsController']   as TextEditingController?)?.dispose();
      (m['pageCountController'] as TextEditingController?)?.dispose();
      (m['durationController']  as TextEditingController?)?.dispose();
    }
    for (var a in _activities) {
      (a['titleController']  as TextEditingController?)?.dispose();
      (a['nameController']   as TextEditingController?)?.dispose();
      (a['descController']   as TextEditingController?)?.dispose();
      (a['pointsController'] as TextEditingController?)?.dispose();
    }
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validateForm() {
    _errors.clear();

    if (_titleController.text.trim().isEmpty)
      _errors['title'] = 'Workshop title is required';
    if (_descController.text.trim().isEmpty)
      _errors['description'] = 'Description is required';
    if (_locationController.text.trim().isEmpty)
      _errors['location'] = 'Location is required';
    if (_workshopType == null)
      _errors['workshopType'] = 'Workshop type is required';
    if (_hostType == null)
      _errors['hostType'] = 'Host type is required';

    final cap = int.tryParse(_capacityController.text);
    if (cap == null || cap <= 0)
      _errors['capacity'] = 'Valid capacity is required';

    if (_startDateController.text.isEmpty) {
      _errors['startDate'] = 'Start date is required';
    } else {
      try {
        final start = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
        final today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (start.isBefore(today))
          _errors['startDate'] = 'Start date must be today or in the future';
      } catch (_) {
        _errors['startDate'] = 'Invalid start date format';
      }
    }

    if (_endDateController.text.isEmpty)
      _errors['endDate'] = 'End date is required';

    // ── Validate materials ─────────────────────────────────────────────
    for (int i = 0; i < _materials.length; i++) {
      if (_materials[i]['type'] == null)
        _errors['materialType_$i'] = 'Material ${i + 1}: Type is required';

      final pts = int.tryParse(
        (_materials[i]['pointsController'] as TextEditingController).text,
      ) ?? 0;
      if (pts <= 0)
        _errors['materialPoints_$i'] = 'Material ${i + 1}: Points must be greater than 0';

      // PDF-specific validation
      if (_materials[i]['type'] == 'PDF') {
        final pc = int.tryParse(
          (_materials[i]['pageCountController'] as TextEditingController).text,
        ) ?? 0;
        if (pc <= 0)
          _errors['materialPageCount_$i'] = 'Material ${i + 1}: Page count must be greater than 0';
      }
    }

    // ── Validate activities ────────────────────────────────────────────
    for (int i = 0; i < _activities.length; i++) {
      final nameCtrl = _activities[i]['nameController'] as TextEditingController;
      if (nameCtrl.text.trim().isEmpty)
        _errors['activityName_$i'] = 'Activity ${i + 1}: Name is required';
      if (_activities[i]['difficulty'] == null)
        _errors['activityDifficulty_$i'] =
        'Activity ${i + 1}: Difficulty is required';
    }

    setState(() {});
    return _errors.isEmpty;
  }

  // ── Process lists ─────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _processMaterials() => _materials.map((m) {
    final materialType = m['type'] ?? "PDF";
    final title = (m['titleController'] as TextEditingController).text.trim();
    final points = int.tryParse((m['pointsController'] as TextEditingController).text) ?? 1;
    final pageCount = int.tryParse((m['pageCountController'] as TextEditingController).text) ?? 1;
    final duration = int.tryParse((m['durationController'] as TextEditingController).text) ?? 0;

    return {
      if (m['id'] != null) "id": m['id'],
      "title":     title,
      "points":    points,
      "type":      materialType,
      "titlePdf":  title,       // mirrors title for PDF
      "pageCount": pageCount,   // used when type == PDF
      "duration":  duration,    // used when type == Video
      "file":      m['file'],
    };
  }).toList();

  List<Map<String, dynamic>> _processActivities() => _activities.map((a) => {
    if (a['id'] != null) "id": a['id'],
    "title":       (a['titleController'] as TextEditingController).text.trim(),
    "name":        (a['nameController']  as TextEditingController).text.trim(),
    "description": (a['descController']  as TextEditingController).text.trim(),
    "points":      int.tryParse((a['pointsController'] as TextEditingController).text) ?? 0,
    "difficulty":  a['difficulty'] ?? "Easy",
  }).toList();

  // ── Picker field builder ──────────────────────────────────────────────────
  Widget _buildPickerField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            suffixIcon: Icon(icon, color: const Color(0xff1893ff)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _saveWorkshop({required bool isPublished}) async {
    if (!_validateForm()) return;
    setState(() => _isLoading = true);

    try {
      File? bannerFile;
      if (_bannerPath != null && !_bannerPath!.startsWith('http')) {
        bannerFile = File(_bannerPath!);
      }

      final materials  = _processMaterials();
      final activities = _processActivities();
      final capacity   = int.tryParse(_capacityController.text) ?? 0;

      DateTime? startDate;
      DateTime? endDate;
      if (_startDateController.text.isNotEmpty) {
        startDate = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      }
      if (_endDateController.text.isNotEmpty) {
        endDate = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
      }

      Response? response;

      if (isEdit) {
        response = await workshopRepo.updateWorkshop(
          workshopId:               widget.workshopData!['id'].toString(),
          title:                    _titleController.text.trim(),
          description:              _descController.text.trim(),
          hostType:                 _hostType!,
          workshopType:             _workshopType!,
          location:                 _locationController.text.trim(),
          maxCapacity:              capacity,
          requireCV:                _requireCV,
          requireRoadmapCompletion: _requireRoadmap,
          isPublished:              isPublished,
          startDate:                startDate,
          endDate:                  endDate,
          startTime:                _startTimeController.text,
          endTime:                  _endTimeController.text,
          universityId:             _universityId,
          banner:                   bannerFile,
          materials:                materials,
          activities:               activities,
        );
      } else {
        response = await workshopRepo.createWorkshop(
          title:                    _titleController.text.trim(),
          description:              _descController.text.trim(),
          hostType:                 _hostType!,
          workshopType:             _workshopType!,
          location:                 _locationController.text.trim(),
          maxCapacity:              capacity,
          requireCV:                _requireCV,
          requireRoadmapCompletion: _requireRoadmap,
          isPublished:              isPublished,
          startDate:                startDate,
          endDate:                  endDate,
          startTime:                _startTimeController.text,
          endTime:                  _endTimeController.text,
          universityId:             _universityId,
          banner:                   bannerFile,
          materials:                materials,
          activities:               activities,
        );
      }

      debugPrint("📦 Response status: ${response?.statusCode}");
      debugPrint("📦 Response data:   ${response?.data}");

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isEdit
              ? 'Workshop updated successfully!'
              : 'Workshop ${isPublished ? 'published' : 'saved as draft'} successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;

        String errorMsg = '';
        if (response?.data is Map) {
          final errors = response?.data['errors'];
          if (errors is Map) {
            errorMsg = errors.entries
                .map((e) => '${e.key}: ${(e.value as List).join(', ')}')
                .join('\n');
          } else {
            errorMsg = response?.data['message'] ??
                response?.data['title'] ??
                '';
          }
        } else {
          errorMsg = response?.data?.toString() ?? '';
        }

        debugPrint("❌ [SAVE FAILED] Status: ${response?.statusCode}");
        debugPrint("❌ [SAVE FAILED] Message: $errorMsg");

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed: ${response?.statusCode}\n$errorMsg'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 8),
        ));
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException: ${e.response?.statusCode}");
      debugPrint("❌ DioException Data: ${e.response?.data}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Network error: ${e.response?.statusCode}\n${e.response?.data ?? e.message}'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ));
    } catch (e) {
      debugPrint("❌ General Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Unexpected error: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Date picker ───────────────────────────────────────────────────────────
  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
    );
    if (picked != null) {
      setState(() => ctrl.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  // ── Time picker ───────────────────────────────────────────────────────────
  Future<void> _pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xff1893ff), onPrimary: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => ctrl.text = picked.format(context));
  }

  // ── Material helpers ──────────────────────────────────────────────────────
  void _addMaterial() {
    setState(() => _materials.add({
      "titleController":     TextEditingController(),
      "pointsController":    TextEditingController(text: '1'),   // ✅ default > 0
      "pageCountController": TextEditingController(text: '1'),
      "durationController":  TextEditingController(text: '0'),
      "type":      null,
      "fileName":  null,
      "points":    1,
      "pageCount": 1,
      "duration":  0,
      "file":      null,
    }));
  }

  void _removeMaterial(int i) {
    setState(() {
      (_materials[i]['titleController']     as TextEditingController?)?.dispose();
      (_materials[i]['pointsController']    as TextEditingController?)?.dispose();
      (_materials[i]['pageCountController'] as TextEditingController?)?.dispose();
      (_materials[i]['durationController']  as TextEditingController?)?.dispose();
      _materials.removeAt(i);
    });
  }

  // ── Activity helpers ──────────────────────────────────────────────────────
  void _addActivity() {
    setState(() => _activities.add({
      "titleController":  TextEditingController(),
      "nameController":   TextEditingController(),
      "descController":   TextEditingController(),
      "pointsController": TextEditingController(text: '0'),
      "difficulty": null,
      "points":     0,
    }));
  }

  void _removeActivity(int i) {
    setState(() {
      (_activities[i]['titleController']  as TextEditingController?)?.dispose();
      (_activities[i]['nameController']   as TextEditingController?)?.dispose();
      (_activities[i]['descController']   as TextEditingController?)?.dispose();
      (_activities[i]['pointsController'] as TextEditingController?)?.dispose();
      _activities.removeAt(i);
    });
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit ? "Edit Workshop" : "Create Workshop",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff1893ff),
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
            // ── Errors ────────────────────────────────────────────
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
                      .map((e) => Text("• $e",
                      style: const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),

            // ── Basic Information ──────────────────────────────────
            SectionWidget(
              title: "Basic Information",
              children: [
                TextFieldWidget(
                    controller: _titleController,
                    label: "Workshop Title",
                    hint: "e.g., AI Career Bootcamp"),
                if (_errors.containsKey('title'))
                  _err(_errors['title']!),
                const SizedBox(height: 12),
                TextAreaWidget(
                    controller: _descController,
                    label: "Description",
                    hint: "Describe the goals and activities..."),
                if (_errors.containsKey('description'))
                  _err(_errors['description']!),
                const SizedBox(height: 12),
                UploadContainerWidget(
                  title: "Workshop Banner",
                  selectedImagePath: _bannerPath,
                  onImageChanged: (path) =>
                      setState(() => _bannerPath = path),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Host & Location ────────────────────────────────────
            SectionWidget(
              title: "Host & Location",
              children: [
                CustomDropdown(
                  label: "Host Type",
                  items: const ["Company", "University"],
                  value: _hostType,
                  hint: "Select Host Type",
                  onChanged: (v) => setState(() {
                    _hostType = v;
                    _errors.remove('hostType');
                  }),
                ),
                if (_errors.containsKey('hostType'))
                  _err(_errors['hostType']!),
                const SizedBox(height: 12),
                if (_hostType == "University") ...[
                  CustomDropdown(
                    label: "University Partner",
                    items: _universities
                        .map((u) => u['name'] as String)
                        .toList(),
                    value: _universityId != null
                        ? _universities.firstWhere(
                            (u) => u['id'] == _universityId,
                        orElse: () => {"name": ""})['name']
                        : null,
                    hint: "Select University",
                    onChanged: (v) {
                      final uni = _universities.firstWhere(
                              (u) => u['name'] == v,
                          orElse: () => {"id": null});
                      setState(() => _universityId = uni['id']);
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                TextFieldWidget(
                  controller: _locationController,
                  label: "Location",
                  hint: "Online / Campus Hall...",
                ),
                if (_errors.containsKey('location'))
                  _err(_errors['location']!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Capacity & Type ────────────────────────────────────
            SectionWidget(
              title: "Capacity & Type",
              children: [
                TextFieldWidget(
                  controller: _capacityController,
                  label: "Max Capacity",
                  hint: "e.g., 100",
                  keyboardType: TextInputType.number,
                ),
                if (_errors.containsKey('capacity'))
                  _err(_errors['capacity']!),
                const SizedBox(height: 12),
                CustomDropdown(
                  label: "Workshop Type",
                  items: const ["Online", "Onsite", "Hybrid"],
                  value: _workshopType,
                  hint: "Select Workshop Type",
                  onChanged: (v) => setState(() {
                    _workshopType = v;
                    _errors.remove('workshopType');
                  }),
                ),
                if (_errors.containsKey('workshopType'))
                  _err(_errors['workshopType']!),
              ],
            ),

            const SizedBox(height: 16),

            // ── Date & Time ────────────────────────────────────────
            SectionWidget(
              title: "Date & Time",
              children: [
                Row(children: [
                  Expanded(
                      child: _buildPickerField(
                        label: "Start Date",
                        hint: "YYYY-MM-DD",
                        controller: _startDateController,
                        icon: Icons.calendar_today,
                        onTap: () => _pickDate(_startDateController),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildPickerField(
                        label: "End Date",
                        hint: "YYYY-MM-DD",
                        controller: _endDateController,
                        icon: Icons.calendar_today,
                        onTap: () => _pickDate(_endDateController),
                      )),
                ]),
                if (_errors.containsKey('startDate'))
                  _err(_errors['startDate']!),
                if (_errors.containsKey('endDate'))
                  _err(_errors['endDate']!),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                      child: _buildPickerField(
                        label: "Start Time",
                        hint: "e.g. 10:00 AM",
                        controller: _startTimeController,
                        icon: Icons.access_time,
                        onTap: () => _pickTime(_startTimeController),
                      )),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _buildPickerField(
                        label: "End Time",
                        hint: "e.g. 12:00 PM",
                        controller: _endTimeController,
                        icon: Icons.access_time,
                        onTap: () => _pickTime(_endTimeController),
                      )),
                ]),
              ],
            ),

            const SizedBox(height: 16),

            // ── Materials ──────────────────────────────────────────
            SectionWidget(
              title: "Materials Provided",
              children: [
                ..._materials.asMap().entries.map((entry) {
                  final i = entry.key;
                  final m = entry.value;
                  final currentType = m['type'] as String?;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50]),
                    child: Column(children: [
                      // ── Header ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Material ${i + 1}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          IconButton(
                              onPressed: () => _removeMaterial(i),
                              icon: const Icon(Icons.delete,
                                  color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Type dropdown ─────────────────────────
                      CustomDropdown(
                        label: "Material Type",
                        items: _materialTypes,
                        value: currentType,
                        hint: "Select Type",
                        onChanged: (v) => setState(() {
                          m['type'] = v;
                          _errors.remove('materialType_$i');
                        }),
                      ),
                      if (_errors.containsKey('materialType_$i'))
                        _err(_errors['materialType_$i']!),
                      const SizedBox(height: 8),

                      // ── Title ─────────────────────────────────
                      TextField(
                        controller:
                        m['titleController'] as TextEditingController,
                        decoration: InputDecoration(
                            labelText: "Material Title",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 8),

                      // ── PDF: Page Count ────────────────────────
                      if (currentType == 'PDF') ...[
                        TextField(
                          controller: m['pageCountController'] as TextEditingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Page Count",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (val) => setState(() {
                            m["pageCount"] = int.tryParse(val) ?? 1;
                            _errors.remove('materialPageCount_$i');
                          }),
                        ),
                        if (_errors.containsKey('materialPageCount_$i'))
                          _err(_errors['materialPageCount_$i']!),
                        const SizedBox(height: 8),
                      ],

                      // ── Video: Duration ────────────────────────
                      if (currentType == 'Video') ...[
                        TextField(
                          controller: m['durationController'] as TextEditingController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Duration (minutes)",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (val) => setState(
                                () => m["duration"] = int.tryParse(val) ?? 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // ── File upload + Points ──────────────────
                      Row(children: [
                        Expanded(
                          flex: 3,
                          child: GestureDetector(
                            onTap: () async {
                              final result = await FilePicker.platform
                                  .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: [
                                  'pdf',
                                  'doc',
                                  'docx',
                                  'ppt',
                                  'pptx',
                                  'mp4',
                                ],
                              );
                              if (result != null &&
                                  result.files.single.path != null) {
                                final file =
                                File(result.files.single.path!);
                                final fileName =
                                    result.files.single.name;
                                setState(() {
                                  m["file"]     = file;
                                  m["fileName"] = fileName;
                                });
                              }
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius:
                                  BorderRadius.circular(12),
                                  border: Border.all(
                                      color: const Color(0xff1893ff))),
                              child: Center(
                                child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.upload_file,
                                          color: Color(0xff1893ff),
                                          size: 20),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          m["fileName"] ?? "Upload File",
                                          overflow:
                                          TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: m["fileName"] == null
                                                ? const Color(0xff1893ff)
                                                : Colors.green,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 80,
                          child: TextField(
                            controller: m['pointsController']
                            as TextEditingController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                                labelText: "Points",
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(12))),
                            onChanged: (val) => setState(() {
                              m["points"] = int.tryParse(val) ?? 1;
                              _errors.remove('materialPoints_$i');
                            }),
                          ),
                        ),
                      ]),
                      if (_errors.containsKey('materialPoints_$i'))
                        _err(_errors['materialPoints_$i']!),
                    ]),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _addMaterial,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add Material",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1893ff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Activities ─────────────────────────────────────────
            SectionWidget(
              title: "Activities Inside Workshop",
              children: [
                ..._activities.asMap().entries.map((entry) {
                  final i = entry.key;
                  final a = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[50]),
                    child: Column(children: [
                      // ── Header ───────────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Activity ${i + 1}",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          IconButton(
                              onPressed: () => _removeActivity(i),
                              icon: const Icon(Icons.delete,
                                  color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ── Title ─────────────────────────────────
                      TextField(
                        controller:
                        a['titleController'] as TextEditingController,
                        decoration: InputDecoration(
                            labelText: "Activity Title",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 8),

                      // ── Name (required by API) ────────────────
                      TextField(
                        controller:
                        a['nameController'] as TextEditingController,
                        decoration: InputDecoration(
                            labelText: "Activity Name",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12))),
                        onChanged: (_) =>
                            setState(() => _errors.remove('activityName_$i')),
                      ),
                      if (_errors.containsKey('activityName_$i'))
                        _err(_errors['activityName_$i']!),
                      const SizedBox(height: 8),

                      // ── Description ───────────────────────────
                      TextField(
                        controller:
                        a['descController'] as TextEditingController,
                        maxLines: 3,
                        decoration: InputDecoration(
                            labelText: "Description",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12))),
                      ),
                      const SizedBox(height: 8),

                      // ── Difficulty dropdown ───────────────────
                      CustomDropdown(
                        label: "Difficulty",
                        items: _difficultyLevels,
                        value: a['difficulty'],
                        hint: "Select Difficulty",
                        onChanged: (v) => setState(() {
                          a['difficulty'] = v;
                          _errors.remove('activityDifficulty_$i');
                        }),
                      ),
                      if (_errors.containsKey('activityDifficulty_$i'))
                        _err(_errors['activityDifficulty_$i']!),
                      const SizedBox(height: 8),

                      // ── Points ────────────────────────────────
                      TextField(
                        controller: a['pointsController']
                        as TextEditingController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                            labelText: "Points",
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(12))),
                        onChanged: (val) => setState(
                                () => a["points"] = int.tryParse(val) ?? 0),
                      ),
                    ]),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton.icon(
                    onPressed: _addActivity,
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text("Add Activity",
                        style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1893ff),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Registration Requirements ──────────────────────────
            SectionWidget(
              title: "Registration Requirements",
              children: [
                SwitchListTile(
                  title: const Text("Require CV Upload?"),
                  value: _requireCV,
                  onChanged: (v) => setState(() => _requireCV = v),
                  activeColor: const Color(0xff1893ff),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                const Divider(),
                SwitchListTile(
                  title: const Text("Require Roadmap Completion?"),
                  value: _requireRoadmap,
                  onChanged: (v) => setState(() => _requireRoadmap = v),
                  activeColor: const Color(0xff1893ff),
                  activeTrackColor: const Color(0xffa3c9ff),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Action Buttons ─────────────────────────────────────
            if (isEdit)
              ElevatedButton.icon(
                onPressed: _isLoading
                    ? null
                    : () => _saveWorkshop(isPublished: true),
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1893ff),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              )
            else
              Row(children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading
                        ? null
                        : () => _saveWorkshop(isPublished: true),
                    icon: const Icon(Icons.publish),
                    label: const Text("Publish"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1893ff),
                      foregroundColor: Colors.white,
                      padding:
                      const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
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
      child: Text(msg,
          style: const TextStyle(color: Colors.red, fontSize: 12)));
}