import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../common/CustomDropdown.dart';

class LearningMaterialsWidget extends StatefulWidget {
  const LearningMaterialsWidget({Key? key}) : super(key: key);

  @override
  LearningMaterialsWidgetState createState() => LearningMaterialsWidgetState();
}

class LearningMaterialsWidgetState extends State<LearningMaterialsWidget> {
  List<Map<String, dynamic>> materials = [];

  void addEmptyMaterial() {
    setState(() {
      materials.add({
        "title": "",
        "file": null,
        "filePath": null,
        "isExistingFile": false,
        "points": 0,
        "pointsController": TextEditingController(text: "0"), // ✅
        "duration": "Medium",
        "type": "Video",
      });
    });
  }

  void removeMaterial(int index) {
    setState(() {
      // ✅ Dispose controller before removing
      if (materials[index]["pointsController"] != null) {
        (materials[index]["pointsController"] as TextEditingController).dispose();
      }
      materials.removeAt(index);
    });
  }

  Future<void> pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        materials[index]["file"] = File(result.files.single.path!);
        materials[index]["filePath"] = result.files.single.path;
        materials[index]["isExistingFile"] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...materials.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> mat = entry.value; // ✅ Define material here

          return Container(
            key: ValueKey(mat),
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Learning Material",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => removeMaterial(index),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                TextField(
                  onChanged: (val) {
                    mat["title"] = val; // ✅ Now 'mat' is defined
                  },
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "e.g., Introduction to Flutter",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  controller: TextEditingController(text: mat["title"]),
                ),
                const SizedBox(height: 10),

                // Type & Duration
                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: "Type",
                        items: const ["Video", "PDF", "Document", "Link"],
                        value: mat["type"],
                        onChanged: (val) {
                          setState(() {
                            mat["type"] = val!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomDropdown(
                        label: "Duration",
                        items: const ["Short", "Medium", "Long"],
                        value: mat["duration"],
                        onChanged: (val) {
                          setState(() {
                            mat["duration"] = val!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Points Field
                TextField(
                  controller: mat["pointsController"], // ✅
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Points",
                    hintText: "e.g., 10",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    // ✅ Update both controller and direct value
                    mat["points"] = int.tryParse(val) ?? 0;
                    debugPrint("Material[$index] points updated to: ${mat["points"]}");
                  },
                ),
                const SizedBox(height: 10),

                // File Upload
                GestureDetector(
                  onTap: () => pickFile(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Color(0xff1893ff)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            mat["filePath"] != null
                                ? mat["filePath"].split('/').last
                                : "Upload File",
                            style: TextStyle(
                              color: mat["filePath"] != null
                                  ? Colors.black87
                                  : Colors.grey.shade600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 10),

        // Add Material Button
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptyMaterial,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              "Add Material",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1893ff),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // ✅ Dispose all controllers
    for (var mat in materials) {
      if (mat["pointsController"] != null) {
        (mat["pointsController"] as TextEditingController).dispose();
      }
    }
    super.dispose();
  }
}