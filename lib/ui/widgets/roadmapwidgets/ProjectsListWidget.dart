import 'package:flutter/material.dart';
import '../common/CustomDropdown.dart';

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
        "titleController": TextEditingController(),
        "descController": TextEditingController(),
        "pointsController": TextEditingController(text: "5"),
      });
    });
  }

  void removeProject(int index) {
    (projects[index]['titleController'] as TextEditingController).dispose();
    (projects[index]['descController'] as TextEditingController).dispose();
    (projects[index]['pointsController'] as TextEditingController).dispose();
    setState(() => projects.removeAt(index));
  }

  @override
  void dispose() {
    for (var p in projects) {
      (p['titleController'] as TextEditingController).dispose();
      (p['descController'] as TextEditingController).dispose();
      (p['pointsController'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...projects.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> project = entry.value;

          return Container(
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
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Project Details",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeProject(index),
                      child: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: project['titleController'] as TextEditingController,
                  decoration: InputDecoration(
                    labelText: "Project Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => project["title"] = val,
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: project['descController'] as TextEditingController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => project["description"] = val,
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: CustomDropdown(
                        label: "Difficulty",
                        items: const ["Easy", "Medium", "Hard"],
                        value: project["difficulty"],
                        onChanged: (val) => setState(() => project["difficulty"] = val!),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: project['pointsController'] as TextEditingController,
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) => project["points"] = int.tryParse(val) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),

        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptyProject,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Add Project",
                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1893ff),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}