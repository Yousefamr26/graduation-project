import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadContainerWidget extends StatefulWidget {
  final String title;
  final String? selectedImagePath; // بدل File
  final Function(String?)? onImageChanged; // يرجع path بدل File

  const UploadContainerWidget({
    Key? key,
    required this.title,
    this.selectedImagePath,
    this.onImageChanged,
  }) : super(key: key);

  @override
  State<UploadContainerWidget> createState() => _UploadContainerWidgetState();
}

class _UploadContainerWidgetState extends State<UploadContainerWidget> {
  String? _imagePath; // مسار الصورة

  @override
  void initState() {
    super.initState();
    _imagePath = widget.selectedImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imagePath = pickedFile.path; // نخزن المسار
          });
          if (widget.onImageChanged != null) widget.onImageChanged!(_imagePath);
        }
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: _imagePath == null || _imagePath!.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.upload, size: 40, color: Colors.blue),
              SizedBox(height: 8),
              Text(widget.title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15)),
            ],
          ),
        )
            : Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(_imagePath!),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover, // Banner style
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _imagePath = null;
                  });
                  if (widget.onImageChanged != null) widget.onImageChanged!(null);
                },
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
