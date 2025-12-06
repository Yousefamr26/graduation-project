import 'package:flutter/material.dart';

import '../screens/users/company/pages/Event/addnewevent.dart';
import 'CustomDropdown.dart';
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
                      child: CustomDropdown(
                        label: "Skill Level",
                        items: ["Beginner", "Intermediate", "Advanced"],
                        value: skill["level"],
                        onChanged: (val) {
                          setState(() {
                            skill["level"] = val!;
                            skill["points"] = _calculatePoints(val);
                            skill["pointsController"].text = skill["points"].toString();
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