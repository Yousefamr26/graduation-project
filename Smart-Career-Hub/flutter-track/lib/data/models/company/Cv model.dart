class CvModel {
  final int id;
  final String fileName;
  final String? uploadDate;
  final String? fileUrl;

  CvModel({
    required this.id,
    required this.fileName,
    this.uploadDate,
    this.fileUrl,
  });

  factory CvModel.fromJson(Map<String, dynamic> json) {
    return CvModel(
      id: json['id'] ?? json['cvId'] ?? json['Id'] ?? 0,
      fileName: json['fileName'] ?? json['name'] ?? json['title'] ?? 'CV',
      uploadDate: json['uploadDate'] ?? json['createdAt'],
      fileUrl: json['fileUrl'] ?? json['url'],
    );
  }

  String get formattedDate {
    if (uploadDate == null) return '';
    try {
      final dt = DateTime.parse(uploadDate!);
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
    } catch (_) {
      return uploadDate!;
    }
  }
}

class CvTemplateModel {
  final int id;
  final String name;
  final String? category;
  final String? previewUrl;

  CvTemplateModel({
    required this.id,
    required this.name,
    this.category,
    this.previewUrl,
  });

  factory CvTemplateModel.fromJson(Map<String, dynamic> json) {
    return CvTemplateModel(
      id: json['id'] ?? json['templateId'] ?? json['Id'] ?? 0,
      name: json['name'] ?? json['title'] ?? 'Template',
      category: json['category'] ?? json['type'],
      previewUrl: json['previewUrl'] ?? json['imageUrl'],
    );
  }
}