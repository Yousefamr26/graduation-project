class InternshipModel {
  final String id;
  final String title;
  final String description;
  final String? companyName;
  final String? logoPath;
  final String type; // On-site, Remote, Hybrid
  final String? location;
  final bool isPaid;
  final String duration; // e.g., "3 months", "6 months"
  final int? maxTrainees;
  final List<String> skills;
  final List<String> requirements;
  final String postedDate;
  final String deadline;
  final int applicantsCount;
  final String status; // Draft, Published, Closed
  final bool isFeatured;

  InternshipModel({
    required this.id,
    required this.title,
    required this.description,
    this.companyName,
    this.logoPath,
    required this.type,
    this.location,
    required this.isPaid,
    required this.duration,
    this.maxTrainees,
    required this.skills,
    required this.requirements,
    required this.postedDate,
    required this.deadline,
    this.applicantsCount = 0,
    required this.status,
    this.isFeatured = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'companyName': companyName,
      'logoPath': logoPath,
      'type': type,
      'location': location,
      'isPaid': isPaid,
      'duration': duration,
      'maxTrainees': maxTrainees,
      'skills': skills,
      'requirements': requirements,
      'postedDate': postedDate,
      'deadline': deadline,
      'applicantsCount': applicantsCount,
      'status': status,
      'isFeatured': isFeatured,
    };
  }

  factory InternshipModel.fromJson(Map<String, dynamic> json) {
    return InternshipModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      companyName: json['companyName'],
      logoPath: json['logoPath'],
      type: json['type'],
      location: json['location'],
      isPaid: json['isPaid'] ?? false,
      duration: json['duration'],
      maxTrainees: json['maxTrainees'],
      skills: List<String>.from(json['skills'] ?? []),
      requirements: List<String>.from(json['requirements'] ?? []),
      postedDate: json['postedDate'],
      deadline: json['deadline'],
      applicantsCount: json['applicantsCount'] ?? 0,
      status: json['status'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}