// edit_roadmap_complete.dart - مع DateRangePickerWidget
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../widgets/CustomDropdown.dart';
import '../../../../../widgets/ProjectsListWidget.dart';
import '../../../../../widgets/QuizListWidget.dart';
import '../../../../../widgets/SkillsListWidget.dart';
import '../../../../../widgets/VideosListWidget.dart' hide CustomDropdown;
import '../../../../../widgets/UploadMaterialWidget.dart';
import '../../../../../widgets/_buildSection.dart';
import '../../../../../widgets/_buildTextArea.dart';
import '../../../../../widgets/_buildTextField.dart';
import '../../../../../widgets/_buildTimelineSection.dart';
import '../../../../../widgets/_buildUploadContainer.dart';

class EditRoadmap extends StatefulWidget {
  final Map<String, dynamic>? roadmapData;
  const EditRoadmap({Key? key, this.roadmapData}) : super(key: key);

  @override
  State<EditRoadmap> createState() => _EditRoadmapState();
}

class _EditRoadmapState extends State<EditRoadmap> {
  late String? coverImagePath = widget.roadmapData?["coverImage"];
  late final bool isEditing = widget.roadmapData != null;

  final GlobalKey<SkillsListWidgetState> skillsKey = GlobalKey<SkillsListWidgetState>();
  final GlobalKey<VideosListWidgetState> videosKey = GlobalKey<VideosListWidgetState>();
  final GlobalKey<UploadMaterialWidgetState> materialsKey = GlobalKey<UploadMaterialWidgetState>();
  final GlobalKey<ProjectsListWidgetState> projectsKey = GlobalKey<ProjectsListWidgetState>();
  final GlobalKey<QuizListWidgetState> quizzesKey = GlobalKey<QuizListWidgetState>();
  final GlobalKey<DateRangePickerWidgetState> dateRangeKey = GlobalKey<DateRangePickerWidgetState>(); // ✅ Key للـ DateRangePicker

  late TextEditingController _titleController;
  late TextEditingController _descController;

  String? _targetRole;

  bool get isEdit => widget.roadmapData != null;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.roadmapData?['title'] ?? '');
    _descController = TextEditingController(text: widget.roadmapData?['description'] ?? '');
    _targetRole = widget.roadmapData?['targetRole'];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit) {
        _initSkills();
        _initVideos();
        _initMaterials();
        _initProjects();
        _initQuizzes();
        _initDates(); // ✅ تهيئة التواريخ
      }
    });
  }

  // ✅ تهيئة التواريخ من الداتا الموجودة
  void _initDates() {
    final dateRange = dateRangeKey.currentState;
    final data = widget.roadmapData;

    if (dateRange != null && data != null) {
      // تحويل النصوص للتواريخ
      if (data['startDate'] != null && data['startDate'].toString().isNotEmpty) {
        try {
          dateRange.startDate = DateFormat('yyyy-MM-dd').parse(data['startDate']);
        } catch (e) {
          print('Error parsing start date: $e');
        }
      }

      if (data['endDate'] != null && data['endDate'].toString().isNotEmpty) {
        try {
          dateRange.endDate = DateFormat('yyyy-MM-dd').parse(data['endDate']);
        } catch (e) {
          print('Error parsing end date: $e');
        }
      }

      dateRange.setState(() {});
    }
  }

  void _initSkills() {
    final s = skillsKey.currentState;
    final data = widget.roadmapData;
    if (s != null && data != null && data['skills'] != null) {
      for (var skill in data['skills']) {
        s.skills.add({
          "nameController": TextEditingController(text: skill['name'] ?? ''),
          "level": skill['level'] ?? 'Beginner',
          "pointsController": TextEditingController(text: (skill['points'] ?? 0).toString()),
          "points": skill['points'] ?? 0,
        });
      }
      s.setState(() {});
    }
  }

  void _initVideos() {
    final v = videosKey.currentState;
    final data = widget.roadmapData;
    if (v != null && data != null && data['videos'] != null) {
      for (var video in data['videos']) {
        v.videos.add({
          "title": video['title'] ?? '',
          "file": video['file'],
          "points": video['points'] ?? 0,
          "duration": video['duration'] ?? '1 min',
        });
      }
      v.setState(() {});
    }
  }

  void _initMaterials() {
    final m = materialsKey.currentState;
    final data = widget.roadmapData;
    if (m != null && data != null && data['materials'] != null) {
      for (var material in data['materials']) {
        m.materials.add({
          "name": material['name'] ?? '',
          "file": material['file'],
          "points": material['points'] ?? 0,
        });
      }
      m.setState(() {});
    }
  }

  void _initProjects() {
    final p = projectsKey.currentState;
    final data = widget.roadmapData;
    if (p != null && data != null && data['projects'] != null) {
      for (var pr in data['projects']) {
        p.projects.add({
          "title": pr['title'] ?? '',
          "description": pr['description'] ?? '',
          "difficulty": pr['difficulty'] ?? 'Easy',
          "points": pr['points'] ?? 0,
        });
      }
      p.setState(() {});
    }
  }

  void _initQuizzes() {
    final q = quizzesKey.currentState;
    final data = widget.roadmapData;

    if (q != null && data != null && data['quizzes'] != null) {
      for (var quiz in data['quizzes']) {
        List<Map<String, dynamic>> questions = [];
        if (quiz['questions'] != null) {
          questions = (quiz['questions'] as List).map((question) {
            return {
              "id": question['id'] ?? DateTime.now().millisecondsSinceEpoch,
              "text": question['text'] ?? '',
              "type": question['type'] ?? 'MultipleChoice',
              "points": question['points'] ?? 5,
              "correctAnswer": question['correctAnswer'] ?? '',
              "options": question['options'] != null
                  ? List<String>.from(question['options'])
                  : ["", "", "", ""],
            };
          }).toList();
        }

        int totalPoints = questions.fold(0, (sum, q) => sum + (q['points'] as int? ?? 0));

        q.quizzes.add({
          "id": quiz['id'] ?? DateTime.now().millisecondsSinceEpoch,
          "titleController": TextEditingController(text: quiz['title'] ?? ''),
          "type": quiz['type'] ?? 'Multiple Choice',
          "pointsController": TextEditingController(text: totalPoints.toString()),
          "points": totalPoints,
          "questionsFile": quiz['questionsFile'] ?? '',
          "questions": questions,
        });
      }
      q.setState(() {});
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _processSkills() {
    return (skillsKey.currentState?.skills ?? []).map((skill) {
      return {
        "name": (skill['nameController'] as TextEditingController).text,
        "level": skill['level'] ?? 'Beginner',
        "points": int.tryParse((skill['pointsController'] as TextEditingController).text) ?? 0,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _processQuizzes() {
    return (quizzesKey.currentState?.quizzes ?? []).map((quiz) {
      List<dynamic> questions = List.from(quiz['questions'] ?? []);
      int totalPoints = questions.fold(0, (sum, question) {
        return sum + (question['points'] as int? ?? 0);
      });

      return {
        "id": quiz['id'],
        "title": (quiz['titleController'] as TextEditingController).text,
        "type": quiz['type'] ?? 'Multiple Choice',
        "points": totalPoints,
        "questionsFile": quiz['questionsFile'] ?? '',
        "questions": questions.map((question) {
          return {
            "id": question['id'],
            "text": question['text'] ?? '',
            "type": question['type'] ?? 'MultipleChoice',
            "points": question['points'] ?? 5,
            "correctAnswer": question['correctAnswer'] ?? '',
            if (question['options'] != null)
              "options": List<String>.from(question['options']),
          };
        }).toList(),
      };
    }).toList();
  }

  // ✅ جلب التواريخ من الويدجت وتحويلها لنصوص
  String? _getStartDate() {
    final dateRange = dateRangeKey.currentState;
    if (dateRange?.startDate != null) {
      return DateFormat('yyyy-MM-dd').format(dateRange!.startDate!);
    }
    return null;
  }

  String? _getEndDate() {
    final dateRange = dateRangeKey.currentState;
    if (dateRange?.endDate != null) {
      return DateFormat('yyyy-MM-dd').format(dateRange!.endDate!);
    }
    return null;
  }

  Map<String, dynamic> _createRoadmapMap({required String status}) {
    return {
      "id": widget.roadmapData?["id"],
      "title": _titleController.text,
      "description": _descController.text,
      "target": [_targetRole ?? 'Student'],
      "targetRole": _targetRole,
      "date": widget.roadmapData?["date"] ?? DateFormat('MMM dd, yyyy').format(DateTime.now()),
      "startDate": _getStartDate(), // ✅ استخدام الدالة الجديدة
      "endDate": _getEndDate(), // ✅ استخدام الدالة الجديدة
      "coverImage": coverImagePath,
      "status": status,
      "enrolled": widget.roadmapData?["enrolled"] ?? 0,
      "completion": widget.roadmapData?["completion"] ?? 0,
      "skills": _processSkills(),
      "videos": videosKey.currentState?.videos ?? [],
      "materials": materialsKey.currentState?.materials ?? [],
      "projects": projectsKey.currentState?.projects ?? [],
      "quizzes": _processQuizzes(),
    };
  }

  void _saveRoadmap(String status) {
    final roadmapData = _createRoadmapMap(status: status);

    print("=" * 50);
    print("📝 Saving Roadmap with status: $status");
    print("Start Date: ${roadmapData['startDate']}");
    print("End Date: ${roadmapData['endDate']}");
    print("Quizzes count: ${roadmapData['quizzes']?.length ?? 0}");
    print("=" * 50);

    Navigator.pop(context, roadmapData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Color(0xff1893ff),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
              border: Border(bottom: BorderSide(color: Colors.white, width: 2)),
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              toolbarHeight: 130,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? "Edit Roadmap" : "Create Roadmap",
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Design a comprehensive learning path",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SectionWidget(
                    title: "Basic Information",
                    children: [
                      TextFieldWidget(
                        controller: _titleController,
                        label: "Roadmap Title",
                        hint: "e.g., Flutter Developer Roadmap",
                        onChanged: (_) {},
                      ),
                      SizedBox(height: 12),
                      TextAreaWidget(
                        controller: _descController,
                        label: "Description",
                        hint: "Write a brief overview...",
                        onChanged: (_) {},
                      ),
                      SizedBox(height: 12),
                      CustomDropdown(
                        label: "Target Role",
                        items: ["Student", "Graduate", "Both"],
                        value: _targetRole,
                        onChanged: (v) => setState(() => _targetRole = v),
                      ),
                      SizedBox(height: 16),
                      UploadContainerWidget(
                        title: "Upload Cover Image",
                        selectedImagePath: coverImagePath,
                        onImageChanged: (path) {
                          setState(() {
                            coverImagePath = path;
                          });
                        },
                      ),
                    ],
                  ),

                  SectionWidget(
                    title: "Required Skills",
                    children: [SkillsListWidget(key: skillsKey)],
                  ),

                  SectionWidget(
                    title: "Videos",
                    children: [VideosListWidget(key: videosKey)],
                  ),

                  SectionWidget(
                    title: "Materials",
                    children: [UploadMaterialWidget(key: materialsKey)],
                  ),

                  SectionWidget(
                    title: "Projects",
                    children: [ProjectsListWidget(key: projectsKey)],
                  ),

                  SectionWidget(
                    title: "Quizzes",
                    children: [QuizListWidget(key: quizzesKey)],
                  ),

                  // ✅ استخدام الويدجت الجديد بدل TimelineSectionWidget القديم
                  SectionWidget(
                    title: "Timeline",
                    children: [
                      DateRangePickerWidget(key: dateRangeKey),
                    ],
                  ),

                  SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _saveRoadmap("Draft"),
                          icon: Icon(Icons.save_outlined),
                          label: Text("Save Draft"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Color(0xff1893ff),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Color(0xff1893ff), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _saveRoadmap("Published"),
                          icon: Icon(Icons.publish),
                          label: Text("Publish"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff1893ff),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}