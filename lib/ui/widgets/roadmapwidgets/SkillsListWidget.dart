import 'package:flutter/material.dart';
import '../common/CustomDropdown.dart';

class SkillsListWidget extends StatefulWidget {
  SkillsListWidget({Key? key}) : super(key: key);

  @override
  SkillsListWidgetState createState() => SkillsListWidgetState();
}

class SkillsListWidgetState extends State<SkillsListWidget> {
  List<Map<String, dynamic>> skills = [];

  void addEmptySkill() {
    setState(() {
      skills.add({
        "nameController": TextEditingController(),
        "level": "Beginner",
        "pointsController": TextEditingController(text: "5"), // ✅ default = 5
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
        return 15;
      default:
        return 5;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                    Text(
                      "Skill Details",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => removeSkill(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Skill Name
                TextField(
                  controller: skill["nameController"],
                  decoration: InputDecoration(
                    labelText: "Skill Name",
                    hintText: "e.g., Flutter Development",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                            final calculated = _calculatePoints(val);
                            skill["points"] = calculated;
                            // ✅ sync both map and controller
                            (skill["pointsController"] as TextEditingController)
                                .text = calculated.toString();
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),

                    Container(
                      width: 70,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: skill["pointsController"],
                        decoration: InputDecoration(
                          labelText: "Pts",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          // ✅ update map when user edits manually
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

        SizedBox(
          width: double.infinity,
          height: 40,
          child: ElevatedButton.icon(
            onPressed: addEmptySkill,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text(
              "Add Skill",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1893ff),
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
    for (var skill in skills) {
      skill["nameController"].dispose();
      skill["pointsController"].dispose();
    }
    super.dispose();
  }
}