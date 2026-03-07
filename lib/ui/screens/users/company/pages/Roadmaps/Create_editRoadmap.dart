import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../data/repositories/roadmap_repository.dart';
import '../../../../../widgets/common/CustomDropdown.dart';
import '../../../../../widgets/roadmapwidgets/LearningMaterialsWidget .dart';
import '../../../../../widgets/roadmapwidgets/ProjectsListWidget.dart';
import '../../../../../widgets/roadmapwidgets/QuizListWidget.dart';
import '../../../../../widgets/roadmapwidgets/SkillsListWidget.dart';
import '../../../../../widgets/common/_buildDateField.dart';
import '../../../../../widgets/common/_buildSection.dart';
import '../../../../../widgets/common/_buildTextArea.dart';
import '../../../../../widgets/common/_buildTextField.dart';
import '../../../../../widgets/common/_buildUploadContainer.dart';
import 'Mock data.dart';

class Create_editRoadmap extends StatefulWidget {
  final Map<String, dynamic>? roadmapData;

  const Create_editRoadmap({Key? key, this.roadmapData}) : super(key: key);

  @override
  State<Create_editRoadmap> createState() => _Create_editRoadmapState();
}

class _Create_editRoadmapState extends State<Create_editRoadmap> {

  final RoadmapRepository _roadmapRepo = RoadmapRepository();

  // Controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Keys
  final GlobalKey<SkillsListWidgetState> skillsKey = GlobalKey();
  final GlobalKey<LearningMaterialsWidgetState> materialsKey = GlobalKey();
  final GlobalKey<ProjectsListWidgetState> projectsKey = GlobalKey();
  final GlobalKey<QuizListWidgetState> quizzesKey = GlobalKey();

  // State variables
  String? coverImagePath;
  String? _targetRole;
  Map<String, String> _errors = {};
  bool _isLoading = false;
  bool _isFree = true;

  bool get isEdit => widget.roadmapData != null;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    if (widget.roadmapData != null) {
      _titleController.text = widget.roadmapData!['title'] ?? '';
      _descController.text = widget.roadmapData!['description'] ?? '';
      _targetRole = widget.roadmapData!['targetRole'];
      coverImagePath = widget.roadmapData!['coverImage'];

      if (widget.roadmapData!['startDate'] != null) {
        _startDateController.text = widget.roadmapData!['startDate'];
      }
      if (widget.roadmapData!['endDate'] != null) {
        _endDateController.text = widget.roadmapData!['endDate'];
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeWidgetData();
      });

      _isFree = widget.roadmapData!['isFree'] ?? true;
      if (!_isFree && widget.roadmapData!['price'] != null) {
        _priceController.text = widget.roadmapData!['price'].toString();
      }
    }
  }

  void _initializeWidgetData() {
    _initSkills();
    _initMaterials();
    _initProjects();
    _initQuizzes();
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

  void _initSkills() {
    final s = skillsKey.currentState;
    final data = widget.roadmapData;
    if (s == null || data == null) return;

    List<dynamic>? skillsData = data['skills'];
    if (skillsData == null || skillsData.isEmpty) return;

    try {
      final dynamic skillState = s;
      for (var skill in skillsData) {
        String name = skill['name']?.toString() ?? skill['skillName']?.toString() ?? '';
        if (name.isEmpty) continue;

        String level = skill['level']?.toString() ?? 'Beginner';
        int points = skill['points'] as int? ?? skill['levelPoints'] as int? ?? 0;
        dynamic skillId = skill['id'];

        skillState.skills.add({
          "id": skillId,
          "nameController": TextEditingController(text: name),
          "level": level,
          "points": points,
          "pointsController": TextEditingController(text: points.toString()),
        });
      }
      skillState.setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing skills: $e');
    }
  }

  void _initMaterials() {
    final m = materialsKey.currentState;
    final data = widget.roadmapData;
    if (m == null || data == null) return;

    List<dynamic>? materialsData = data['learningMaterials'] ?? data['materials'];
    if (materialsData == null || materialsData.isEmpty) return;

    try {
      final dynamic materialState = m;
      for (var material in materialsData) {
        String? materialId = material['id']?.toString();
        String title = material['title']?.toString() ?? material['titleVideos']?.toString() ?? '';
        String type = material['type']?.toString() ?? 'Video';
        String duration = material['duration']?.toString() ?? 'Medium';
        int points = material['points'] as int? ?? 0;
        String? filePath = material['filePath']?.toString() ?? material['FilePath']?.toString();

        materialState.materials.add({
          "id": materialId,
          "title": title,
          "file": null,
          "filePath": filePath,
          "existingFilePath": filePath,
          "isExistingFile": filePath != null && filePath.isNotEmpty,
          "points": points,
          "pointsController": TextEditingController(text: points.toString()),
          "duration": duration,
          "type": type,
        });
      }
      materialState.setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing materials: $e');
    }
  }

  void _initProjects() {
    final p = projectsKey.currentState;
    final data = widget.roadmapData;
    if (p == null || data == null || data['projects'] == null) return;

    try {
      final dynamic projectState = p;
      for (var pr in data['projects']) {
        projectState.projects.add({
          "id": pr['id'],
          "title": pr['title'] ?? '',
          "description": pr['description'] ?? '',
          "difficulty": pr['difficulty'] ?? 'Easy',
          "points": pr['points'] ?? 0,
        });
      }
      projectState.setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing projects: $e');
    }
  }

  void _initQuizzes() {
    final q = quizzesKey.currentState;
    final data = widget.roadmapData;
    if (q == null || data == null || data['quizzes'] == null) return;

    try {
      final dynamic quizState = q;
      for (var quiz in data['quizzes']) {
        List<Map<String, dynamic>> questions = [];
        if (quiz['questions'] != null) {
          questions = (quiz['questions'] as List).map((question) {
            return {
              "id": question['id'] ?? DateTime.now().millisecondsSinceEpoch,
              "text": question['text'] ?? '',
              "type": question['type'] ?? 'MCQ',
              "points": question['points'] ?? 5,
              "correctAnswer": question['correctAnswer'] ?? '',
              "options": question['options'] != null
                  ? List<String>.from(question['options'])
                  : ["", "", "", ""],
            };
          }).toList();
        }
        int totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));

        quizState.quizzes.add({
          "id": quiz['id'] ?? DateTime.now().millisecondsSinceEpoch,
          "titleController": TextEditingController(text: quiz['title'] ?? ''),
          "type": quiz['type'] ?? 'MCQ',
          "pointsController": TextEditingController(text: totalPoints.toString()),
          "points": totalPoints,
          "questionsFile": quiz['questionsFile'] ?? '',
          "questions": questions,
        });
      }
      quizState.setState(() {});
    } catch (e) {
      debugPrint('❌ Error initializing quizzes: $e');
    }
  }

  // ─── Process Methods ────────────────────────────────────

  List<Map<String, dynamic>> _processSkills() {
    final skillsState = skillsKey.currentState;
    if (skillsState == null) return [];
    try {
      final skills = (skillsState as dynamic).skills as List? ?? [];
      List<Map<String, dynamic>> result = [];
      for (var skill in skills) {
        String name = (skill['nameController'] as TextEditingController?)?.text.trim() ?? '';
        if (name.isEmpty) continue;
        int points = int.tryParse((skill['pointsController'] as TextEditingController?)?.text.trim() ?? '0') ?? 0;
        result.add({
          if (skill['id'] != null) "id": skill['id'].toString(),
          "name": name,
          "level": skill['level']?.toString() ?? 'Beginner',
          "points": points,
        });
      }
      return result;
    } catch (e) {
      debugPrint('❌ Error processing skills: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _processLearningMaterials() {
    final materialsState = materialsKey.currentState;
    if (materialsState == null) return [];
    try {
      final materials = (materialsState as dynamic).materials as List? ?? [];
      return materials.map<Map<String, dynamic>>((material) {
        int points = int.tryParse((material['pointsController'] as TextEditingController?)?.text.trim() ?? '0') ?? 0;
        File? file = _getFileFromPath(material['file']);
        String? filePath = file?.path ?? material['filePath']?.toString() ?? material['existingFilePath']?.toString() ?? '';

        return {
          if (material['id'] != null) "id": material['id'].toString(),
          "title": material['title'] ?? '',
          "type": material['type'] ?? 'Video',
          "duration": material['duration'] ?? 'Medium',
          "points": points,
          "filePath": filePath,
          if (file != null) "file": file,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error processing materials: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _processProjects() {
    final projectsState = projectsKey.currentState;
    if (projectsState == null) return [];
    try {
      final projects = (projectsState as dynamic).projects as List? ?? [];
      return projects.map<Map<String, dynamic>>((project) => {
        if (project['id'] != null) "id": project['id'],
        "title": project['title'] ?? '',
        "description": project['description'] ?? '',
        "difficulty": project['difficulty'] ?? 'Easy',
        "points": project['points'] ?? 0,
      }).toList();
    } catch (e) {
      debugPrint('❌ Error processing projects: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> _processQuizzes() {
    final quizzesState = quizzesKey.currentState;
    if (quizzesState == null) return [];
    try {
      final quizzes = (quizzesState as dynamic).quizzes as List? ?? [];
      return quizzes.map<Map<String, dynamic>>((quiz) {
        List<Map<String, dynamic>> questions = List.from(quiz['questions'] ?? []);
        int totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));

        List<Map<String, dynamic>> processedQuestions = questions.map((question) {
          String optionsJson = '[]';
          if (question['options'] is List) {
            List<String> opts = (question['options'] as List)
                .map((o) => o.toString().trim())
                .where((o) => o.isNotEmpty)
                .toList();
            if (opts.isNotEmpty) {
              optionsJson = '[${opts.map((o) => '"${o.replaceAll('"', '\\"')}"').join(',')}]';
            }
          }
          return {
            if (question['id'] != null) "id": question['id'],
            "text": question['text'] ?? '',
            "type": question['type'] ?? 'MCQ',
            "options": question['options'] ?? [],
            "optionsJson": optionsJson,
            "correctAnswer": question['correctAnswer']?.toString() ?? '',
            "points": question['points'] ?? 5,
          };
        }).toList();

        return {
          if (quiz['id'] != null) "id": quiz['id'],
          "title": (quiz['titleController'] as TextEditingController).text,
          "type": quiz['type'] ?? 'MCQ',
          "points": totalPoints,
          "questions": processedQuestions,
        };
      }).toList();
    } catch (e) {
      debugPrint('❌ Error processing quizzes: $e');
      return [];
    }
  }

  File? _getFileFromPath(dynamic value) {
    if (value == null) return null;
    if (value is File) return value;
    if (value is String && value.isNotEmpty && !value.startsWith('http')) return File(value);
    return null;
  }

  // ─── Validation ─────────────────────────────────────────

  bool _validateForm() {
    setState(() => _errors.clear());
    bool isValid = true;

    if (_titleController.text.trim().isEmpty) { _errors['title'] = 'Title is required'; isValid = false; }
    if (_descController.text.trim().isEmpty) { _errors['description'] = 'Description is required'; isValid = false; }
    if (_targetRole == null) { _errors['targetRole'] = 'Please select a target role'; isValid = false; }
    if (_startDateController.text.isEmpty) { _errors['startDate'] = 'Start date is required'; isValid = false; }
    if (_endDateController.text.isEmpty) { _errors['endDate'] = 'End date is required'; isValid = false; }

    if (_startDateController.text.isNotEmpty && _endDateController.text.isNotEmpty) {
      try {
        DateTime start = DateFormat('yyyy-MM-dd').parse(_startDateController.text);
        DateTime end = DateFormat('yyyy-MM-dd').parse(_endDateController.text);
        if (end.isBefore(start)) { _errors['endDate'] = 'End date must be after start date'; isValid = false; }
      } catch (_) { _errors['endDate'] = 'Invalid date format'; isValid = false; }
    }

    if (!_isFree) {
      if (_priceController.text.trim().isEmpty) {
        _errors['price'] = 'Price is required when not free'; isValid = false;
      } else {
        double? price = double.tryParse(_priceController.text.trim());
        if (price == null || price < 0) { _errors['price'] = 'Please enter a valid price'; isValid = false; }
      }
    }

    if (!isValid) _showSnackBar('Please fill all required fields', Colors.red);
    setState(() {});
    return isValid;
  }

  bool _validateLists(
      List skills,
      List learningMaterials,
      List projects,
      List quizzes,
      ) {
    List<String> missing = [];
    if (skills.isEmpty) missing.add('• At least one Skill is required');
    if (learningMaterials.isEmpty) missing.add('• At least one Learning Material is required');
    if (projects.isEmpty) missing.add('• At least one Project is required');
    if (quizzes.isEmpty) {
      missing.add('• At least one Quiz is required');
    } else {
      for (int i = 0; i < quizzes.length; i++) {
        if ((quizzes[i]['questions'] as List?)?.isEmpty ?? true) {
          missing.add('• Quiz "${quizzes[i]['title'] ?? 'Quiz ${i + 1}'}" must have at least one question');
        }
      }
    }
    if (missing.isNotEmpty) { _showValidationDialog(missing); return false; }
    return true;
  }

  void _showValidationDialog(List<String> missingItems) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xff1676C4), Color(0xff0d7de8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Required Items Missing', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Please add the following required items:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xff1676C4))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xff1676C4).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xff1676C4).withOpacity(0.3), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: missingItems.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xff1676C4), shape: BoxShape.circle),
                      child: const Icon(Icons.error_outline, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.replaceFirst('• ', ''),
                        style: const TextStyle(color: Color(0xff1676C4), fontSize: 14, height: 1.5, fontWeight: FontWeight.w500))),
                  ]),
                )).toList(),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: const Text('Got it!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff1676C4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, duration: const Duration(seconds: 3)),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  // ─── Save Roadmap ────────────────────────────────────────

  Future<void> _saveRoadmap(bool isPublished) async {
    if (!_validateForm()) return;

    final skills = _processSkills();
    final learningMaterials = _processLearningMaterials();
    final projects = _processProjects();
    final quizzes = _processQuizzes();

    if (!_validateLists(skills, learningMaterials, projects, quizzes)) return;

    _showLoadingDialog();

    try {
      // ✅ Simulate small delay (mock backend call)
      await Future.delayed(const Duration(milliseconds: 500));

      double? price;
      if (!_isFree && _priceController.text.trim().isNotEmpty) {
        price = double.tryParse(_priceController.text.trim());
      }

      final String status = isPublished ? "Published" : "Draft";

      // ─── BUILD the roadmap map ───────────────────────────
      final Map<String, dynamic> roadmapMap = {
        "title":            _titleController.text.trim(),
        "description":      _descController.text.trim(),
        "targetRole":       _targetRole!,
        "target":           [_targetRole!],
        "startDate":        _startDateController.text,
        "endDate":          _endDateController.text,
        "isPublished":      isPublished,
        "status":           status,
        "coverImage":       coverImagePath,
        "isFree":           _isFree,
        "price":            _isFree ? null : price,
        "skills":           skills,
        "learningMaterials": learningMaterials,
        "materials":        learningMaterials,
        "videos":           learningMaterials,
        "projects":         projects,
        "quizzes":          quizzes,
      };

      if (isEdit && widget.roadmapData?['id'] != null) {
        // ─── ✅ MOCK: Update ─────────────────────────────────
        final String roadmapId = widget.roadmapData!['id'].toString();
        roadmapMap['id'] = roadmapId;

        RoadmapMockData.updateRoadmap(roadmapId, roadmapMap);
        debugPrint('✅ Mock: Roadmap UPDATED — id=$roadmapId');

        // ❌ BACKEND: استبدل السطرين فوق بـ:
        // await _roadmapRepo.updateRoadmap(
        //   roadmapId: roadmapId,
        //   title: _titleController.text.trim(),
        //   description: _descController.text.trim(),
        //   targetRole: _targetRole!,
        //   startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
        //   endDate: DateFormat('yyyy-MM-dd').parse(_endDateController.text),
        //   isPublished: isPublished,
        //   coverImage: _getFileFromPath(coverImagePath),
        //   skills: skills, learningMaterials: learningMaterials,
        //   projects: projects, quizzes: quizzes,
        //   isFree: _isFree, price: price,
        // );

      } else {
        // ─── ✅ MOCK: Create ─────────────────────────────────
        roadmapMap['id']         = RoadmapMockData.generateMockId();
        roadmapMap['date']       = DateTime.now().toIso8601String();
        roadmapMap['enrolled']   = 0;
        roadmapMap['completion'] = 0;

        RoadmapMockData.addRoadmap(roadmapMap);
        debugPrint('✅ Mock: Roadmap CREATED — id=${roadmapMap['id']}');

        // ❌ BACKEND: استبدل السطرين فوق بـ:
        // await _roadmapRepo.createRoadmap(
        //   title: _titleController.text.trim(),
        //   description: _descController.text.trim(),
        //   targetRole: _targetRole!,
        //   startDate: DateFormat('yyyy-MM-dd').parse(_startDateController.text),
        //   endDate: DateFormat('yyyy-MM-dd').parse(_endDateController.text),
        //   isPublished: isPublished,
        //   coverImage: _getFileFromPath(coverImagePath),
        //   skills: skills, learningMaterials: learningMaterials,
        //   projects: projects, quizzes: quizzes,
        //   isFree: _isFree, price: price,
        // );
      }

      Navigator.pop(context); // close loading

      _showSnackBar(
        isEdit
            ? 'Roadmap updated successfully!'
            : 'Roadmap ${isPublished ? "published" : "saved as draft"} successfully!',
        Colors.green,
      );

      Navigator.pop(context, true); // ← بيخلي MyRoadmapsScreen يعمل refresh

    } catch (e, stackTrace) {
      Navigator.pop(context); // close loading
      debugPrint('❌ Error saving roadmap: $e\n$stackTrace');
      _showSnackBar('Failed to save roadmap. Please try again.', Colors.red);
    }
  }

  Future<void> _pickDate(TextEditingController controller, String field) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
        _errors.remove(field);
      });
    }
  }

  // ─── UI ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Roadmap" : "Create Roadmap",
            style: const TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: const Color(0xff1676C4),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Basic Information ──────────────────────────────
                  SectionWidget(
                    title: "Basic Information",
                    children: [
                      TextFieldWidget(
                        controller: _titleController,
                        label: "Roadmap Title",
                        hint: "e.g., Flutter Developer Roadmap",
                        onChanged: (_) => setState(() => _errors.remove('title')),
                      ),
                      if (_errors['title'] != null)
                        Padding(padding: const EdgeInsets.only(top: 4),
                            child: Text(_errors['title']!, style: const TextStyle(color: Colors.red, fontSize: 12))),

                      const SizedBox(height: 12),
                      TextAreaWidget(
                        controller: _descController,
                        label: "Description",
                        hint: "Write a brief overview...",
                        onChanged: (_) => setState(() => _errors.remove('description')),
                      ),
                      if (_errors['description'] != null)
                        Padding(padding: const EdgeInsets.only(top: 4),
                            child: Text(_errors['description']!, style: const TextStyle(color: Colors.red, fontSize: 12))),

                      const SizedBox(height: 12),
                      CustomDropdown(
                        label: "Target Role",
                        items: const ["Student", "Graduate", "Both"],
                        value: _targetRole,
                        onChanged: (v) => setState(() { _targetRole = v; _errors.remove('targetRole'); }),
                      ),
                      if (_errors['targetRole'] != null)
                        Padding(padding: const EdgeInsets.only(top: 4),
                            child: Text(_errors['targetRole']!, style: const TextStyle(color: Colors.red, fontSize: 12))),

                      const SizedBox(height: 16),
                      UploadContainerWidget(
                        title: "Upload Cover Image",
                        selectedImagePath: coverImagePath,
                        onImageChanged: (path) => setState(() => coverImagePath = path),
                      ),
                    ],
                  ),

                  // ── Skills ────────────────────────────────────────
                  SectionWidget(title: "Required Skills *", children: [SkillsListWidget(key: skillsKey)]),

                  // ── Learning Materials ────────────────────────────
                  SectionWidget(title: "Learning Materials *", children: [LearningMaterialsWidget(key: materialsKey)]),

                  // ── Projects ──────────────────────────────────────
                  SectionWidget(title: "Projects *", children: [ProjectsListWidget(key: projectsKey)]),

                  // ── Quizzes ───────────────────────────────────────
                  SectionWidget(title: "Quizzes *", children: [QuizListWidget(key: quizzesKey)]),

                  // ── Pricing ───────────────────────────────────────
                  SectionWidget(
                    title: "Pricing",
                    children: [
                      Row(children: [
                        Checkbox(
                          value: _isFree,
                          onChanged: (value) => setState(() {
                            _isFree = value!;
                            if (_isFree) { _priceController.clear(); _errors.remove('price'); }
                          }),
                          activeColor: const Color(0xff1676C4),
                        ),
                        const Text('Free Roadmap', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      ]),
                      if (!_isFree) ...[
                        const SizedBox(height: 12),
                        TextFieldWidget(
                          controller: _priceController,
                          label: "Price (USD)",
                          hint: "e.g., 29.99",
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          prefixIcon: const Icon(Icons.attach_money, color: Color(0xff1676C4)),
                          onChanged: (_) => setState(() => _errors.remove('price')),
                        ),
                        if (_errors['price'] != null)
                          Padding(padding: const EdgeInsets.only(top: 4),
                              child: Text(_errors['price']!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                      ],
                    ],
                  ),

                  // ── Timeline ──────────────────────────────────────
                  const SizedBox(height: 20),
                  SectionWidget(
                    title: "Timeline",
                    children: [
                      Row(children: [
                        Expanded(child: DateFieldWidget(
                          controller: _startDateController, label: "Start Date", hint: "Select Date",
                          errorText: _errors['startDate'], onTap: () => _pickDate(_startDateController, 'startDate'),
                        )),
                        const SizedBox(width: 10),
                        Expanded(child: DateFieldWidget(
                          controller: _endDateController, label: "End Date", hint: "Select Date",
                          errorText: _errors['endDate'], onTap: () => _pickDate(_endDateController, 'endDate'),
                        )),
                      ]),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Action Buttons ────────────────────────────────
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _saveRoadmap(false),
                        icon: const Icon(Icons.save_outlined),
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
                        onPressed: () => _saveRoadmap(true),
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

                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}