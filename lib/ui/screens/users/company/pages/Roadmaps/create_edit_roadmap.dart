import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';

import '../../../../../../data/repositories/roadmap_repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/roadmapwidgets/LearningMaterialsWidget.dart';
import '../../../../../widgets/roadmapwidgets/ManualQuizWidget.dart';
import '../../../../../widgets/roadmapwidgets/ProjectsListWidget.dart';
import '../../../../../widgets/roadmapwidgets/SkillsListWidget.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';
import 'Ai quiz screen.dart';

class Create_editRoadmap extends StatefulWidget {
  final Map<String, dynamic>? roadmapData;

  const Create_editRoadmap({Key? key, this.roadmapData}) : super(key: key);

  @override
  State<Create_editRoadmap> createState() => _Create_editRoadmapState();
}

class _Create_editRoadmapState extends State<Create_editRoadmap> {
  final roadmapRepo = RoadmapRepository();

  final TextEditingController _titleController     = TextEditingController();
  final TextEditingController _descController      = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController   = TextEditingController();
  final TextEditingController _priceController     = TextEditingController();

  final GlobalKey<SkillsListWidgetState>        skillsKey     = GlobalKey();
  final GlobalKey<LearningMaterialsWidgetState> materialsKey  = GlobalKey();
  final GlobalKey<ProjectsListWidgetState>      projectsKey   = GlobalKey();
  final GlobalKey<ManualQuizWidgetState>        manualQuizKey = GlobalKey();

  String? coverImagePath;
  String? _targetRole;
  Map<String, String> _errors = {};
  bool _isFree    = true;
  bool _isLoading = false;

  bool get isEdit => widget.roadmapData != null;

  // ✅ FIX 1: robust AI quiz detection — checks multiple signals
  bool _isAiQuiz(Map<String, dynamic> quiz) {
    final title = (quiz['title'] ?? '').toString().toLowerCase();
    // Signal A: title prefix (original logic)
    if (title.startsWith('ai generated') || title.contains('ai generated')) return true;
    // Signal B: explicit flag from API
    if (quiz['isAiGenerated'] == true) return true;
    if (quiz['isAi'] == true) return true;
    // Signal C: source field
    final source = (quiz['source'] ?? '').toString().toLowerCase();
    if (source == 'ai' || source == 'generated') return true;
    return false;
  }

  // ✅ FIX 2: compute total points from a quiz map (API response)
  int _extractQuizPoints(Map<String, dynamic> quiz) {
    // Priority 1: explicit points field on the quiz
    if (quiz['points'] != null) {
      return (quiz['points'] as num).toInt();
    }
    // Priority 2: totalPoints field
    if (quiz['totalPoints'] != null) {
      return (quiz['totalPoints'] as num).toInt();
    }
    // Priority 3: sum from questions
    final questions = quiz['questions'] ?? quiz['questionRequests'] ?? [];
    if (questions is List && questions.isNotEmpty) {
      int sum = 0;
      for (var q in questions) {
        sum += (q['points'] as num? ?? 0).toInt();
      }
      if (sum > 0) return sum;
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.roadmapData != null) {
      _titleController.text = widget.roadmapData!['title']       ?? '';
      _descController.text  = widget.roadmapData!['description'] ?? '';
      _targetRole           = widget.roadmapData!['targetRole'];
      coverImagePath        = widget.roadmapData!['coverImage'];

      if (widget.roadmapData!['startDate'] != null)
        _startDateController.text =
        widget.roadmapData!['startDate'].toString().split('T')[0];
      if (widget.roadmapData!['endDate'] != null)
        _endDateController.text =
        widget.roadmapData!['endDate'].toString().split('T')[0];

      _isFree = widget.roadmapData!['isFree'] ?? true;
      if (!_isFree && widget.roadmapData!['price'] != null)
        _priceController.text = widget.roadmapData!['price'].toString();

      WidgetsBinding.instance.addPostFrameCallback((_) => _initializeWidgetData());
    }
  }

  void _initializeWidgetData() {
    _initSkills();
    _initMaterials();
    _initProjects();
    _initQuizzes();
  }

  void _initSkills() {
    final s = skillsKey.currentState;
    if (s == null || widget.roadmapData == null) return;
    final skillsData = widget.roadmapData!['skills'] ??
        widget.roadmapData!['skillRequests'] ??
        widget.roadmapData!['requiredSkills'];
    if (skillsData == null) return;

    for (var skill in skillsData) {
      final points = skill['points'] ??
          skill['levelPoints'] ??
          _defaultPointsForLevel(skill['level'] ?? 'Beginner');

      s.skills.add({
        "id": skill['id'],
        "nameController": TextEditingController(
            text: skill['name'] ?? skill['skillName'] ?? ''),
        "level": skill['level'] ?? 'Beginner',
        "points": points,
        "pointsController": TextEditingController(text: points.toString()),
      });
    }
    s.setState(() {});
  }

  int _defaultPointsForLevel(String level) {
    switch (level) {
      case 'Beginner':     return 5;
      case 'Intermediate': return 10;
      case 'Advanced':     return 15;
      default:             return 5;
    }
  }

  List<Map<String, dynamic>> _processSkills() {
    final s = skillsKey.currentState;
    if (s == null) return [];
    return s.skills.map<Map<String, dynamic>>((skill) {
      final pointsText =
      (skill['pointsController'] as TextEditingController).text.trim();
      final points = int.tryParse(pointsText) ?? 0;
      return {
        if (skill['id'] != null) "id": skill['id'],
        "name":   (skill['nameController'] as TextEditingController).text.trim(),
        "level":  skill['level'] ?? 'Beginner',
        "points": points,
      };
    }).toList();
  }

  void _initMaterials() {
    final m = materialsKey.currentState;
    if (m == null || widget.roadmapData == null) return;
    final materialsData = widget.roadmapData!['learningMaterials'] ??
        widget.roadmapData!['learningMaterialRequests'];
    if (materialsData == null) return;
    for (var material in materialsData) {
      m.materials.add({
        "id":               material['id'],
        "title":            material['title'] ?? '',
        "type":             material['type']  ?? 'Video',
        "points":           material['points'] ?? 0,
        "pointsController": TextEditingController(
            text: (material['points'] ?? 0).toString()),
        "duration":  material['duration'] ?? 'Medium',
        "filePath":  material['filePath'],
      });
    }
    m.setState(() {});
  }

  void _initProjects() {
    final p = projectsKey.currentState;
    if (p == null || widget.roadmapData == null) return;
    final projectsData = widget.roadmapData!['projects'] ??
        widget.roadmapData!['projectRequests'];
    if (projectsData == null) return;
    for (var pr in projectsData) {
      final points = pr['points'] ?? 5;
      p.projects.add({
        "id":               pr['id'],
        "title":            pr['title']       ?? '',
        "description":      pr['description'] ?? '',
        "difficulty":       pr['difficulty']  ?? 'Easy',
        "points":           points,
        "titleController":  TextEditingController(text: pr['title']       ?? ''),
        "descController":   TextEditingController(text: pr['description'] ?? ''),
        "pointsController": TextEditingController(text: points.toString()),
      });
    }
    p.setState(() {});
  }

  void _initQuizzes() {
    final q = manualQuizKey.currentState;
    if (q == null || widget.roadmapData == null) return;
    final quizzesData = widget.roadmapData!['quizzes'] ??
        widget.roadmapData!['quizRequests'];
    debugPrint("🔎 [QUIZ RAW DATA]: $quizzesData");
    if (quizzesData == null) return;

    for (var quiz in quizzesData) {
      // ✅ FIX 3: use robust helpers instead of inline logic
      final bool   isAi        = _isAiQuiz(quiz as Map<String, dynamic>);
      final int    savedPoints = _extractQuizPoints(quiz);
      final String title       = quiz['title']?.toString() ?? '';

      debugPrint("📝 [INIT QUIZ] '$title' | isAi: $isAi | points: $savedPoints");

      q.quizzes.add({
        "id":               quiz['id'],
        "titleController":  TextEditingController(text: title),
        "questions":        quiz['questions'] ?? quiz['questionRequests'] ?? [],
        "isAi":             isAi,
        "savedPoints":      savedPoints,   // ✅ always populated now
        "pointsController": TextEditingController(text: savedPoints.toString()),
      });
    }
    q.setState(() {});
  }

  // ── Process helpers ──────────────────────────────────────────

  List<Map<String, dynamic>> _processMaterials() {
    final m = materialsKey.currentState;
    if (m == null) return [];
    return m.materials.map<Map<String, dynamic>>((mat) => {
      if (mat['id'] != null) "id": mat['id'],
      "title":       mat['title'],
      "type":        mat['type'],
      "points":      int.tryParse(
          (mat['pointsController'] as TextEditingController).text) ?? 0,
      "duration":    mat['duration'] ?? 'Medium',
      "file":        mat['file'],
      "titlePdf":    mat['title'],
      "durationPdf": mat['duration'] ?? 'Medium',
    }).toList();
  }

  List<Map<String, dynamic>> _processProjects() {
    final p = projectsKey.currentState;
    if (p == null) return [];
    return p.projects.map<Map<String, dynamic>>((proj) {
      String title =
      (proj['titleController'] as TextEditingController).text.trim();
      if (title.length < 3) title = "Project: $title";
      return {
        if (proj['id'] != null) "id": proj['id'],
        "title":       title,
        "description": (proj['descController'] as TextEditingController).text.trim(),
        "difficulty":  proj['difficulty'] ?? 'Easy',
        "points":      int.tryParse(
            (proj['pointsController'] as TextEditingController).text) ?? 0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _processQuizzes() {
    final q = manualQuizKey.currentState;
    if (q == null) return [];
    return q.quizzes.map<Map<String, dynamic>>((quiz) {
      final questions = quiz['questions'] as List? ?? [];
      final isAi      = quiz['isAi'] == true;

      // ✅ FIX 4: read savedPoints from pointsController (user may have edited it)
      //    then fall back to the stored savedPoints int, then fall back to questions sum.
      int totalPoints;

      final controllerText =
          (quiz['pointsController'] as TextEditingController?)?.text.trim() ?? '';
      final controllerValue = int.tryParse(controllerText) ?? 0;

      if (isAi) {
        // For AI quizzes: prefer the controller value (editable), then savedPoints.
        final savedPoints = (quiz['savedPoints'] as num? ?? 0).toInt();
        totalPoints = controllerValue > 0
            ? controllerValue
            : (savedPoints > 0 ? savedPoints : 50); // fallback 50 as before
      } else {
        // For manual quizzes: always sum from questions (source of truth).
        totalPoints = questions.fold<int>(
          0,
              (sum, q) => sum + ((q['points'] as num? ?? 0).toInt()),
        );
        // If questions have no points set, use controller value.
        if (totalPoints == 0 && controllerValue > 0) {
          totalPoints = controllerValue;
        }
      }

      debugPrint(
          "📤 [PROCESS QUIZ] '${(quiz['titleController'] as TextEditingController).text}' "
              "| isAi: $isAi | points: $totalPoints | questions: ${questions.length}");

      return {
        if (quiz['id'] != null) "id": quiz['id'],
        "title":     (quiz['titleController'] as TextEditingController).text.trim(),
        "points":    totalPoints,
        "questions": questions,
      };
    }).toList();
  }

  // ── Validation ───────────────────────────────────────────────

  bool _validateForm() {
    _errors.clear();

    if (_titleController.text.trim().isEmpty)
      _errors['title'] = "Title is required";
    if (_descController.text.trim().isEmpty)
      _errors['desc'] = "Description is required";
    if (_targetRole == null)
      _errors['role'] = "Please select target role";

    if (_startDateController.text.isEmpty) {
      _errors['start'] = "Start date required";
    } else {
      final start = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final now   = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (start.isBefore(today))
        _errors['start'] = "Start date must be today or in the future";
    }

    if (_endDateController.text.isEmpty)
      _errors['end'] = "End date required";

    if (!_isFree && _priceController.text.trim().isEmpty)
      _errors['price'] = "Price is required for paid roadmaps";

    setState(() {});
    return _errors.isEmpty;
  }

  // ── Save ─────────────────────────────────────────────────────

  Future<void> _saveRoadmap(bool isPublished) async {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    try {
      final skills    = _processSkills();
      final materials = _processMaterials();
      final projects  = _processProjects();
      final quizzes   = _processQuizzes();

      final DateTime start =
      DateFormat('yyyy-MM-dd').parse(_startDateController.text);
      final DateTime end =
      DateFormat('yyyy-MM-dd').parse(_endDateController.text);

      Response? response;

      if (isEdit) {
        // ── UPDATE ──────────────────────────────────────────────
        response = await roadmapRepo.updateRoadmap(
          roadmapId:         widget.roadmapData!['id'].toString(),
          title:             _titleController.text.trim(),
          description:       _descController.text.trim(),
          targetRole:        _targetRole!,
          startDate:         start,
          endDate:           end,
          isPublished:       isPublished,
          coverImage:        (coverImagePath != null &&
              !coverImagePath!.startsWith('http'))
              ? File(coverImagePath!)
              : null,
          skills:            skills,
          learningMaterials: materials,
          projects:          projects,
          quizzes:           quizzes,
          price: _isFree ? null : double.tryParse(_priceController.text),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("تم التحديث بنجاح!"),
                backgroundColor: Colors.green),
          );
          Navigator.pop(context, true);
        } else {
          _showErrorSnackbar(response);
        }
      } else {
        // ── CREATE ──────────────────────────────────────────────
        response = await roadmapRepo.createRoadmap(
          title:             _titleController.text.trim(),
          description:       _descController.text.trim(),
          targetRole:        _targetRole!,
          startDate:         start,
          endDate:           end,
          isPublished:       isPublished,
          coverImage:        coverImagePath != null ? File(coverImagePath!) : null,
          skills:            skills,
          learningMaterials: materials,
          projects:          projects,
          quizzes:           quizzes,
          price: _isFree ? null : double.tryParse(_priceController.text),
        );

        if (response != null &&
            (response.statusCode == 200 || response.statusCode == 201)) {
          if (!mounted) return;

          final responseData = response.data;
          int? roadmapId;
          if (responseData is Map) {
            roadmapId = responseData['id'] ??
                responseData['roadmapId'] ??
                responseData['data']?['id'];
          }

          debugPrint("✅ [CREATE] Roadmap created with ID: $roadmapId");

          if (roadmapId != null) {
            await Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => AiQuizScreen(
                  roadmapId:   roadmapId!,
                  isPublished: isPublished,
                ),
              ),
            );
          } else {
            debugPrint(
                "⚠️ [CREATE] No roadmapId in response — skipping AI quiz");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("تم الحفظ بنجاح!"),
                  backgroundColor: Colors.green),
            );
            Navigator.pop(context, true);
          }
        } else {
          _showErrorSnackbar(response);
        }
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException: ${e.response?.statusCode}");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "خطأ في الشبكة: ${e.response?.statusCode}\n${e.response?.data ?? e.message}"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (e) {
      debugPrint("❌ General Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("خطأ غير متوقع: $e"),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(Response? response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            "فشل الحفظ: ${response?.statusCode ?? 'لا يوجد response'}\n${response?.data ?? ''}"),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate:   DateTime.now(),
      lastDate:    DateTime(2100),
    );
    if (picked != null) {
      setState(
              () => controller.text = DateFormat('yyyy-MM-dd').format(picked));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Roadmap" : "Create Roadmap",
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xff1676C4),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
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
                      style:
                      const TextStyle(color: Colors.red)))
                      .toList(),
                ),
              ),

            SectionWidget(
              title: "Basic Details",
              children: [
                TextFieldWidget(
                    controller: _titleController,
                    label: "Title",
                    hint: "Roadmap name"),
                if (_errors.containsKey('title'))
                  _buildErrorText(_errors['title']!),
                const SizedBox(height: 15),
                TextAreaWidget(
                    controller: _descController,
                    label: "Description",
                    hint: "Detailed info"),
                if (_errors.containsKey('desc'))
                  _buildErrorText(_errors['desc']!),
                const SizedBox(height: 15),
                CustomDropdown(
                  label: "Target Role",
                  items: const ["Student", "Graduate", "Both"],
                  value: _targetRole,
                  onChanged: (val) =>
                      setState(() => _targetRole = val),
                ),
                if (_errors.containsKey('role'))
                  _buildErrorText(_errors['role']!),
                const SizedBox(height: 15),
                UploadContainerWidget(
                  title: "Cover Image",
                  selectedImagePath: coverImagePath,
                  onImageChanged: (path) =>
                      setState(() => coverImagePath = path),
                ),
              ],
            ),

            SectionWidget(
                title: "Skills",
                children: [SkillsListWidget(key: skillsKey)]),
            SectionWidget(
                title: "Materials",
                children: [LearningMaterialsWidget(key: materialsKey)]),
            SectionWidget(
                title: "Projects",
                children: [ProjectsListWidget(key: projectsKey)]),
            SectionWidget(
                title: "Quizzes",
                children: [ManualQuizWidget(key: manualQuizKey)]),

            SectionWidget(
              title: "Timeline & Price",
              children: [
                Row(children: [
                  Checkbox(
                    value: _isFree,
                    onChanged: (v) =>
                        setState(() => _isFree = v!),
                    activeColor: const Color(0xff1676C4),
                  ),
                  const Text("Free Roadmap"),
                ]),
                if (!_isFree) ...[
                  TextFieldWidget(
                    controller: _priceController,
                    label: "Price",
                    hint: "0.00",
                    keyboardType: TextInputType.number,
                  ),
                  if (_errors.containsKey('price'))
                    _buildErrorText(_errors['price']!),
                ],
                const SizedBox(height: 15),
                Row(children: [
                  Expanded(
                    child: DateFieldWidget(
                      controller: _startDateController,
                      label: "Start Date",
                      hint: "YYYY-MM-DD",
                      onTap: () => _pickDate(_startDateController),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DateFieldWidget(
                      controller: _endDateController,
                      label: "End Date",
                      hint: "YYYY-MM-DD",
                      onTap: () => _pickDate(_endDateController),
                    ),
                  ),
                ]),
                if (_errors.containsKey('start'))
                  _buildErrorText(_errors['start']!),
                if (_errors.containsKey('end'))
                  _buildErrorText(_errors['end']!),
              ],
            ),

            if (!isEdit)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xff1676C4).withOpacity(0.07),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xff1676C4).withOpacity(0.2)),
                ),
                child: const Row(children: [
                  Icon(Icons.auto_awesome,
                      color: Color(0xff1676C4), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "After saving, you'll be able to generate an AI quiz for this roadmap.",
                      style: TextStyle(
                          fontSize: 12, color: Color(0xff1676C4)),
                    ),
                  ),
                ]),
              ),

            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                  _isLoading ? null : () => _saveRoadmap(false),
                  child: const Text("Draft"),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                  _isLoading ? null : () => _saveRoadmap(true),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1676C4)),
                  child: const Text("Publish",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ]),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorText(String message) => Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Text(message,
        style: const TextStyle(color: Colors.red, fontSize: 12)),
  );
}