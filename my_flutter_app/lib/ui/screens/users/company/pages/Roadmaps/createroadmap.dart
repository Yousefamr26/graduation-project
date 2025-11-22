import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';


class CreateNewRoadmap extends StatefulWidget {
  const CreateNewRoadmap({super.key});

  @override
  State<CreateNewRoadmap> createState() => _CreateNewRoadmapState();
}

class _CreateNewRoadmapState extends State<CreateNewRoadmap> {
  File? _selectedImage;
  TextEditingController _startDateController = TextEditingController();
  TextEditingController _endDateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // AppBar ثابت
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
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Create New Roadmap",
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

          // باقي الصفحة scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Basic Info
                  _buildSection(
                    title: "Basic Information",
                    children: [
                      _buildTextField(
                          label: "Roadmap Title",
                          hint: "e.g., Flutter Developer Roadmap"),
                      SizedBox(height: 12),
                      _buildTextArea(
                          label: "Description",
                          hint: "Write a brief overview of the roadmap..."),
                      SizedBox(height: 12),
                      _buildDropdown(
                          label: "Target Role", items: ["Student", "Graduate", "Both"]),
                      SizedBox(height: 16),
                      _buildUploadContainer(title: "Upload Cover Image"),
                    ],
                  ),

                  // Skills
                  _buildSection(title: "Required Skills", children: [
                    SkillsListWidget(),
                  ]),
                  _buildSection(
                    title: "Videos (Learning Materials)",
                    children: [
                      VideosListWidget(),
                    ],
                  ),

                  _buildSection(
                    title: "Projects",
                    children: [
                      ProjectsListWidget(),
                    ],
                  ),
                  _buildSection(
                    title: "Quizzes",
                    children: [
                      QuizListWidget(),
                    ],
                  ),


                  // Timeline
                  _buildTimelineSection(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Save Draft
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            print("Save Draft pressed");
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: BorderSide(color: Color(0xff1893ff), width: 2),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Save Draft",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xff1893ff),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      // Publish
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            print("Publish pressed");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff1893ff),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Publish",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
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

  // ===== Helper Widgets =====

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w500, color: Color(0xff1893ff))),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return _buildSection(title: "Timeline & Calendar", children: [
      _buildDateField(controller: _startDateController, label: "Start Date"),
      SizedBox(height: 12),
      _buildDateField(controller: _endDateController, label: "End Date"),
    ]);
  }

  Widget _buildDateField({required TextEditingController controller, required String label}) {
    return GestureDetector(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (pickedDate != null) {
          setState(() {
            controller.text =
            "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
          });
        }
      },
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: Icon(Icons.calendar_today, color: Color(0xff1893ff)),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextArea({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
        SizedBox(height: 6),
        TextField(
          maxLines: 4,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({required String label, required List<String> items}) {
    String? selected;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 6),
            DropdownButtonHideUnderline(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400, width: 1),
                ),
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Colors.blue,
                  hint: Text(
                    "Select target role",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  value: selected,
                  items: items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selected = value;
                    });
                  },
                  selectedItemBuilder: (context) {
                    return items.map((item) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          item,
                          style: TextStyle(
                            color: Color(0xff1893ff),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  icon: Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUploadContainer({required String title}) {
    return GestureDetector(
      onTap: () async {
        final picker = ImagePicker();
        final XFile? image = await picker.pickImage(source: ImageSource.gallery);

        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: _selectedImage == null
              ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload, size: 40, color: Colors.blue),
              SizedBox(height: 8),
              Text(title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _selectedImage!,
                  height: 110,
                  width: 110,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedImage = null;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 5),
                    Text(
                      "Delete",
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                          fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===== SkillsListWidget =====
class SkillsListWidget extends StatefulWidget {
  SkillsListWidget({Key? key}) : super(key: key);

  @override
  SkillsListWidgetState createState() => SkillsListWidgetState();
}

class SkillsListWidgetState extends State<SkillsListWidget> {
  // فاضية من الأول
  List<Map<String, dynamic>> skills = [];

  void addEmptySkill() {
    setState(() {
      skills.add({
        "nameController": TextEditingController(),
        "level": "Beginner",
        "pointsController": TextEditingController(text: "5"),
        "points": 5,
      });
    });
  }

  void removeSkill(int index) {
    setState(() {
      skills[index]["nameController"].dispose();
      skills[index]["pointsController"].dispose();
      skills.removeAt(index);
    });
  }

  int _calculatePoints(String level) {
    switch (level) {
      case "Beginner":
        return 5;
      case "Intermediate":
        return 10;
      case "Advanced":
        return 20;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // يظهر بس العناصر الموجودة
        ...skills.map((skill) {
          int index = skills.indexOf(skill);
          return Container(
            key: ValueKey(skill),
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Skill Details",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeSkill(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                TextField(
                  controller: skill["nameController"],
                  decoration: InputDecoration(
                    labelText: "Skill Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: skill["level"],
                        items: ["Beginner", "Intermediate", "Advanced"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            skill["level"] = val!;
                            skill["points"] = _calculatePoints(val);
                            skill["pointsController"].text =
                                skill["points"].toString();
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Skill Level",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: skill["pointsController"],
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          skill["points"] = int.tryParse(val) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        SizedBox(height: 10),
        // زر Add Skill دايمًا ظاهر
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptySkill,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Skill",
                style: TextStyle(
                    fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var skill in skills) {
      skill["nameController"].dispose();
      skill["pointsController"].dispose();
    }
    super.dispose();
  }
}





class VideosListWidget extends StatefulWidget {
  VideosListWidget({Key? key}) : super(key: key);

  @override
  VideosListWidgetState createState() => VideosListWidgetState();
}

class VideosListWidgetState extends State<VideosListWidget> {
  List<Map<String, dynamic>> videos = [];

  void addEmptyVideo() {
    setState(() {
      videos.add({"title": "", "file": null, "points": 0});
    });
  }

  void removeVideo(int index) {
    setState(() {
      videos.removeAt(index);
    });
  }

  Future<void> pickVideo(int index) async {
    final picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        videos[index]["file"] = File(video.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...videos.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> video = entry.value;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header: Video Details + Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Video Details",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeVideo(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Video Title
                TextField(
                  controller: TextEditingController(text: video["title"]),
                  decoration: InputDecoration(
                    labelText: "Video Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => video["title"] = val,
                ),
                SizedBox(height: 10),

                // Row: Upload Video + Points
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickVideo(index),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Center(
                            child: video["file"] == null
                                ? Text("Upload Video", style: TextStyle(color: Colors.blue))
                                : Text("Video Selected", style: TextStyle(color: Colors.green)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Editable Points
                    Container(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: video["points"].toString()),
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          setState(() {
                            video["points"] = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptyVideo,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Video",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectsListWidget extends StatefulWidget {
  ProjectsListWidget({Key? key}) : super(key: key);

  @override
  ProjectsListWidgetState createState() => ProjectsListWidgetState();
}

class ProjectsListWidgetState extends State<ProjectsListWidget> {
  List<Map<String, dynamic>> projects = [];

  void addEmptyProject() {
    setState(() {
      projects.add({
        "title": "",
        "description": "",
        "difficulty": "Easy",
        "points": 5,
      });
    });
  }

  void removeProject(int index) {
    setState(() {
      projects.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...projects.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> project = entry.value;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header: Project Details + Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Project Details",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeProject(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Project Title
                TextField(
                  controller: TextEditingController(text: project["title"]),
                  decoration: InputDecoration(
                    labelText: "Project Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => project["title"] = val,
                ),
                SizedBox(height: 10),

                // Project Description
                TextField(
                  controller: TextEditingController(text: project["description"]),
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => project["description"] = val,
                ),
                SizedBox(height: 10),

                // Row: Difficulty + Points
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: project["difficulty"],
                        items: ["Easy", "Medium", "Hard"]
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() {
                          project["difficulty"] = val!;
                        }),
                        decoration: InputDecoration(
                          labelText: "Difficulty",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 60,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: project["points"].toString()),
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          setState(() {
                            project["points"] = int.tryParse(val) ?? 0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptyProject,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Project",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
            ),
          ),
        ),
      ],
    );
  }
}
class QuizListWidget extends StatefulWidget {
  QuizListWidget({Key? key}) : super(key: key);

  @override
  QuizListWidgetState createState() => QuizListWidgetState();
}

class QuizListWidgetState extends State<QuizListWidget> {
  List<Map<String, dynamic>> quizzes = [];

  void addEmptyQuiz() {
    setState(() {
      quizzes.add({
        "titleController": TextEditingController(),
        "type": "Multiple Choice",
        "pointsController": TextEditingController(text: "0"),
        "points": 0,
        "questionsFile": null, // File for uploaded questions
      });
    });
  }

  void removeQuiz(int index) {
    setState(() {
      quizzes[index]["titleController"].dispose();
      quizzes[index]["pointsController"].dispose();
      quizzes.removeAt(index);
    });
  }

  Future<void> pickQuestionsFile(int index) async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery); // ممكن تعدليها PDF أو أي صيغة
    if (file != null) {
      setState(() {
        quizzes[index]["questionsFile"] = File(file.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...quizzes.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> quiz = entry.value;

          return Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              children: [
                // Header: Quiz Details + Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Quiz Details", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeQuiz(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Quiz Title
                TextField(
                  controller: quiz["titleController"],
                  decoration: InputDecoration(
                    labelText: "Quiz Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                SizedBox(height: 10),

                // Row: Quiz Type + Points + Upload Questions
            // Row 1: Quiz Type
            DropdownButtonFormField<String>(
              value: quiz["type"],
              items: ["Multiple Choice", "True/False", "Short Answer"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() {
                  quiz["type"] = val!;
                });
              },
              decoration: InputDecoration(
                labelText: "Quiz Type",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            SizedBox(height: 10),

// Row 2: Points + Upload Questions
                // Row 1: Quiz Type


// Row 2: Upload Questions + Points
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickQuestionsFile(index),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Center(
                            child: quiz["questionsFile"] == null
                                ? Text("Upload Questions", style: TextStyle(color: Colors.blue))
                                : Text("File Selected", style: TextStyle(color: Colors.green)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: 70,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: quiz["pointsController"],
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          quiz["points"] = int.tryParse(val) ?? 0;
                        },
                      ),
                    ),
                  ],
                ),

              ],
            ),
          );
        }).toList(),

        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptyQuiz,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Quiz", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var quiz in quizzes) {
      quiz["titleController"].dispose();
      quiz["pointsController"].dispose();
    }
    super.dispose();
  }
}
