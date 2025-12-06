import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class VideosListWidget extends StatefulWidget {
  VideosListWidget({Key? key}) : super(key: key);

  @override
  VideosListWidgetState createState() => VideosListWidgetState();
}

class VideosListWidgetState extends State<VideosListWidget> {
  List<Map<String, dynamic>> videos = [];

  // قائمة مدد الفيديوهات
  final List<String> durationOptions = [
    '1 min',
    '2 min',
    '3 min',
    '5 min',
    '10 min',
    '15 min',
    '20 min',
    '30 min',
    '45 min',
    '60 min',
  ];

  void addEmptyVideo() {
    setState(() {
      videos.add({
        "title": "",
        "file": null,
        "points": 0,
        "duration": durationOptions[0], // القيمة الافتراضية
      });
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

                // Row: Upload Video Button
                GestureDetector(
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
                          ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.upload, size: 20, color: Colors.blue),
                          SizedBox(width: 6),
                          Text("Upload Video", style: TextStyle(color: Colors.blue)),
                        ],
                      )
                          : Text("Video Selected", style: TextStyle(color: Colors.green)),
                    ),
                  ),
                ),
                SizedBox(height: 10),

                // Row: Duration Dropdown + Points
                Row(
                  children: [
                    // Duration Dropdown
                    Expanded(
                      child: CustomDropdown(
                        value: video["duration"] ?? durationOptions[0],
                        items: durationOptions,
                        label: "Duration",
                        onChanged: (val) {
                          setState(() {
                            video["duration"] = val;
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10),
                    // Editable Points
                    Container(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: video["points"].toString()),
                        decoration: InputDecoration(
                          labelText: "Points",
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

// Custom Dropdown Widget
class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final String label;
  final Function(String) onChanged;

  const CustomDropdown({
    Key? key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      isExpanded: true,
    );
  }
}