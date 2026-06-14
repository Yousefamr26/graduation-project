import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class MaterialRowWidget extends StatefulWidget {
  final TextEditingController titleController;
  final int points;
  final String? fileName;
  final File? file;
  final Function(int) onPointsChanged;
  final Function(File?, String?) onFileChanged;
  final Function() onRemove;

  const MaterialRowWidget({
    super.key,
    required this.titleController,
    required this.points,
    this.fileName,
    this.file,
    required this.onPointsChanged,
    required this.onFileChanged,
    required this.onRemove,
  });

  @override
  State<MaterialRowWidget> createState() => _MaterialRowWidgetState();
}

class _MaterialRowWidgetState extends State<MaterialRowWidget> {
  late TextEditingController _pointsController;
  File? selectedFile;
  String? fileName;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: widget.points.toString());
    selectedFile = widget.file;
    fileName = widget.fileName;
  }

  @override
  void dispose() {
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'mp4', 'mov', 'jpg', 'jpeg', 'png'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = File(result.files.first.path!);
        fileName = result.files.first.name;
      });
      widget.onFileChanged(selectedFile, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Material", style: TextStyle(fontWeight: FontWeight.w600)),
              IconButton(
                onPressed: widget.onRemove,
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: widget.titleController,
            decoration: InputDecoration(
              labelText: "Material Title",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Center(
                      child: Text(fileName ?? "Upload (pdf/video/image)", style: TextStyle(color: fileName == null ? Colors.blue : Colors.green)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 80,
                child: TextField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Pts",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: (val) {
                    int pts = int.tryParse(val) ?? 0;
                    widget.onPointsChanged(pts);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
