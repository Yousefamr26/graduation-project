import 'package:flutter/material.dart';

import '../screens/users/company/pages/Event/addnewevent.dart';
import 'CustomDropdown.dart';
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
                      child: CustomDropdown(
                        label: "Difficulty",
                        items: ["Easy", "Medium", "Hard"],
                        value: project["difficulty"],
                        onChanged: (val) {
                          setState(() {
                            project["difficulty"] = val!;
                          });
                        },
                      )
                      ,
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