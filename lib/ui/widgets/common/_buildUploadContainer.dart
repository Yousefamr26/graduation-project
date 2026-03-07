import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UploadContainerWidget extends StatefulWidget {
  final String title;
  final String? selectedImagePath;
  final Function(String?)? onImageChanged;

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
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _imagePath = widget.selectedImagePath;
  }

  // ✅ إضافة didUpdateWidget - مهم جداً!
  @override
  void didUpdateWidget(UploadContainerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // لو الـ selectedImagePath اتغير من برة، حدث الـ state
    if (widget.selectedImagePath != oldWidget.selectedImagePath) {
      setState(() {
        _imagePath = widget.selectedImagePath;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // ✅ ضغط الصورة
        maxWidth: 1920, // ✅ حد أقصى للعرض
      );

      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
        widget.onImageChanged?.call(_imagePath);
      }
    } catch (e) {
      debugPrint("❌ Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeImage() {
    setState(() {
      _imagePath = null;
    });
    widget.onImageChanged?.call(null);
  }

  Widget _buildImagePreview() {
    // ✅ معالجة الصورة من Network أو File
    final imagePath = _imagePath!;

    debugPrint("🖼️ Building preview for: $imagePath");

    // صورة من الإنترنت
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      debugPrint("🌐 Loading network image");
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imagePath,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          headers: const {
            'Accept': 'image/*',
            'Cache-Control': 'no-cache',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              debugPrint("✅ Network image loaded");
              return child;
            }
            return Container(
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  color: Colors.blue,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            debugPrint("❌ Network image error: $error");
            return Container(
              color: Colors.red[50],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, size: 40, color: Colors.red),
                    SizedBox(height: 8),
                    Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    SizedBox(height: 4),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        imagePath.length > 40
                            ? '...${imagePath.substring(imagePath.length - 40)}'
                            : imagePath,
                        style: TextStyle(
                          color: Colors.red[700],
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    // صورة محلية
    debugPrint("📁 Loading file image");
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.file(
        File(imagePath),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          debugPrint("❌ File image error: $error");
          return Container(
            color: Colors.orange[50],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 40, color: Colors.orange),
                  SizedBox(height: 8),
                  Text(
                    'Image file not found',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
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
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Tap to select image',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
            : Stack(
          children: [
            _buildImagePreview(),

            // زر الحذف
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _removeImage,
                child: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),

            // زر تغيير الصورة
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Change',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}