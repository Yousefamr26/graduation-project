import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class UploadMaterialWidget extends StatefulWidget {
  UploadMaterialWidget({Key? key}) : super(key: key);

  @override
  UploadMaterialWidgetState createState() => UploadMaterialWidgetState();
}

class UploadMaterialWidgetState extends State<UploadMaterialWidget> {
  List<Map<String, dynamic>> materials = [];

  void addEmptyMaterial() {
    setState(() {
      materials.add({
        "name": "",
        "file": null,
        "points": 0,
      });
    });
  }

  void removeMaterial(int index) {
    setState(() {
      materials.removeAt(index);
    });
  }

  Future<void> pickPDF(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        materials[index]["file"] = File(result.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...materials.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> material = entry.value;

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
                // Header: Material Details + Delete
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Material Details",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    GestureDetector(
                      onTap: () => removeMaterial(index),
                      child: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                SizedBox(height: 10),

                // Material Name
                TextField(
                  controller: TextEditingController(text: material["name"]),
                  decoration: InputDecoration(
                    labelText: "Material Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) => material["name"] = val,
                ),
                SizedBox(height: 10),

                // Row: Upload PDF + Points
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => pickPDF(index),
                        child: Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue),
                          ),
                          child: Center(
                            child: material["file"] == null
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.upload_file, size: 20, color: Colors.blue),
                                SizedBox(width: 6),
                                Text("Upload PDF", style: TextStyle(color: Colors.blue)),
                              ],
                            )
                                : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.picture_as_pdf, size: 20, color: Colors.green),
                                SizedBox(width: 6),
                                Text("PDF Selected", style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    // Editable Points
                    Container(
                      width: 80,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: material["points"].toString()),
                        decoration: InputDecoration(
                          labelText: "Points",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (val) {
                          setState(() {
                            material["points"] = int.tryParse(val) ?? 0;
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
            onPressed: addEmptyMaterial,
            icon: Icon(Icons.add, color: Colors.white),
            label: Text("Add Material",
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