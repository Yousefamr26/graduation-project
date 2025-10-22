import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_flutter_app/core/theme/appColors.dart';

// 📌 Class للـ Skill مع النقاط
class Skill {
  final String name;
  final int points;

  Skill({required this.name, required this.points});
}

class CreateNewRoadmap extends StatefulWidget {
  const CreateNewRoadmap({super.key});

  @override
  State<CreateNewRoadmap> createState() => _CreateNewRoadmapState();
}

class _CreateNewRoadmapState extends State<CreateNewRoadmap> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String? duration;
  String? selectedLevel;

  List<Skill> skills = [
    Skill(name: 'Flutter', points: 10),
    Skill(name: 'Dart', points: 8),
    Skill(name: 'Firebase', points: 7),
    Skill(name: 'UI/UX', points: 5),
    Skill(name: 'GitHub', points: 6),
    Skill(name: 'REST API', points: 9),
  ];

  List<Skill> selectedSkills = [];
  List<String> uploadedFiles = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted ||
          await Permission.storage.isGranted ||
          await Permission.photos.isGranted ||
          await Permission.videos.isGranted) return true;

      var status = await Permission.manageExternalStorage.request();
      if (status.isGranted) return true;

      status = await Permission.storage.request();
      if (status.isGranted) return true;

      status = await Permission.photos.request();
      if (status.isGranted) return true;

      status = await Permission.videos.request();
      if (status.isGranted) return true;

      return false;
    } else if (Platform.isIOS) return true;

    return false;
  }

  IconData getIcon(String fileName) {
    if (fileName.endsWith(".pdf")) return Icons.picture_as_pdf;
    if (fileName.endsWith(".mp4") || fileName.endsWith(".mov")) return Icons.video_library;
    if (fileName.endsWith(".doc") || fileName.endsWith(".docx") || fileName.endsWith(".txt")) return Icons.description;
    if (fileName.endsWith(".png") || fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) return Icons.image;
    return Icons.insert_drive_file;
  }

  @override
  Widget build(BuildContext context) {
    int totalPoints = selectedSkills.fold(0, (sum, skill) => sum + skill.points);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create New Roadmap", style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.w600)),
            SizedBox(height: 2),
            Text("Design a learning path for students", style: TextStyle(color: Colors.grey, fontSize: 13)),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Roadmap Title", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: "e.g., Flutter Developer Internship",
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF385798), width: 2)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Description", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                minLines: 4,
                maxLines: 6,
                decoration: InputDecoration(
                  hintText: "Briefly describe the roadmap and what students will learn...",
                  contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF385798), width: 2)),
                ),
              ),
              const SizedBox(height: 20),

              const Text("Required Skills", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var skill in skills)
                          ChoiceChip(
                            label: Text('${skill.name} (${skill.points} pts)'),
                            selected: selectedSkills.contains(skill),
                            selectedColor: const Color(0xFF385798),
                            backgroundColor: const Color(0xFF385798).withOpacity(0.1),
                            labelStyle: TextStyle(color: selectedSkills.contains(skill) ? Colors.white : const Color(0xFF385798), fontWeight: FontWeight.w500),
                            onSelected: (selected) => setState(() => selected ? selectedSkills.add(skill) : selectedSkills.remove(skill)),
                          ),
                        ActionChip(label: const Text('+ Add Skill'), backgroundColor: Colors.green.withOpacity(0.1), labelStyle: const TextStyle(color: Colors.green), onPressed: () => _showAddSkillDialog(context)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Total Points: $totalPoints', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text("Upload Materials", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
              const SizedBox(height: 6),
              const Text("Attach useful files for students to learn from", style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _buildFilePickerButton(Icons.picture_as_pdf, "PDF / DOC / TXT", ['pdf', 'doc', 'docx', 'txt']),
                      _buildImageVideoPickerButton(Icons.image, "Image / Video"),
                    ]),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text("Uploaded Files", style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 6),
                    if (uploadedFiles.isEmpty)
                      const Text("No files uploaded yet", style: TextStyle(color: Colors.grey))
                    else
                      Column(
                        children: uploadedFiles.map((file) => ListTile(
                          leading: Icon(getIcon(file), color: const Color(0xFF385798)),
                          title: Text(file),
                          trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() => uploadedFiles.remove(file))),
                        )).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Duration & Level
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Duration", style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: "4 weeks", border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                            onChanged: (value) => setState(() => duration = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(left: 8),
                      decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Level", style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 6),
                          DropdownButton<String>(
                            isExpanded: true,
                            value: selectedLevel,
                            hint: const Text("Select level"),
                            items: ["Beginner", "Intermediate", "Advanced"].map((level) {
                              Color textColor;
                              if (level == "Beginner") {
                                textColor = Colors.green;
                              } else if (level == "Intermediate") {
                                textColor = Colors.orange;
                              } else {
                                textColor = Colors.red;
                              }

                              return DropdownMenuItem<String>(
                                value: level,
                                child: Text(
                                  level,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => selectedLevel = value!),
                          ),


                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => print("Public Roadmap clicked"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Public Roadmap", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => print("Save Draft clicked"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade400, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text("Save Draft", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final TextEditingController skillController = TextEditingController();
    final TextEditingController pointsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Skill", style: TextStyle(color: Color(0xFF385798))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: skillController, decoration: const InputDecoration(hintText: "Enter skill name")),
          const SizedBox(height: 10),
          TextField(controller: pointsController, keyboardType: TextInputType.number, decoration: const InputDecoration(hintText: "Enter skill points")),
        ]),
        actions: [
          TextButton(child: const Text("Cancel", style: TextStyle(color: Color(0xFF385798))), onPressed: () => Navigator.pop(context)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF385798)),
            child: const Text("Add", style: TextStyle(color: Colors.white)),
            onPressed: () {
              if (skillController.text.isNotEmpty && pointsController.text.isNotEmpty) {
                setState(() {
                  final newSkill = Skill(name: skillController.text.trim(), points: int.parse(pointsController.text.trim()));
                  skills.insert(0, newSkill);
                  selectedSkills.add(newSkill);
                });
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  // زر رفع ملفات عادية
  Widget _buildFilePickerButton(IconData icon, String label, List<String> allowedExtensions) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            try {
              if (!await _requestStoragePermission()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permission denied ❌")));
                return;
              }

              FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: allowedExtensions, allowMultiple: true);

              if (result != null) {
                setState(() {
                  uploadedFiles.addAll(result.files.map((f) => f.name)); // هنا استخدمنا f.name بدل path
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label uploaded ✅")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No file selected")));
              }
            } catch (e) {
              print("❌ File pick error: $e");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking file: $e")));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF385798).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF385798), size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF385798), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // زر رفع صور وفيديوهات
  Widget _buildImageVideoPickerButton(IconData icon, String label) {
    return Column(
      children: [
        InkWell(
          onTap: () async {
            try {
              if (!await _requestStoragePermission()) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Permission denied ❌")));
                return;
              }

              final XFile? media = await _picker.pickImage(source: ImageSource.gallery);
              if (media != null) {
                setState(() => uploadedFiles.add(media.name));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$label uploaded ✅")));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("No file selected")));
              }
            } catch (e) {
              print("❌ Media pick error: $e");
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error picking media: $e")));
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF385798).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF385798), size: 28),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Color(0xFF385798), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
