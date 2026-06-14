class JobModel {
  final String id;
  final String title;
  final String description;
  final String? logoPath;
  final String? companyName;
  final String locationType; // Remote, Onsite, Hybrid
  final String? location;
  final String salaryMin;
  final String salaryMax;
  final String experienceLevel; // Junior, Mid-level, Senior
  final List<String> requirements;
  final List<String> skills;
  final String employmentType; // Full-time, Part-time, Contract, Internship
  final String postedDate;
  final String deadline;
  final int applicantsCount;
  final String status; // Draft, Published, Closed
  final bool isFeatured;

  JobModel({
    required this.id,
    required this.title,
    required this.description,
    this.logoPath,
    this.companyName,
    required this.locationType,
    this.location,
    required this.salaryMin,
    required this.salaryMax,
    required this.experienceLevel,
    required this.requirements,
    required this.skills,
    required this.employmentType,
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
      'logoPath': logoPath,
      'companyName': companyName,
      'locationType': locationType,
      'location': location,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'experienceLevel': experienceLevel,
      'requirements': requirements,
      'skills': skills,
      'employmentType': employmentType,
      'postedDate': postedDate,
      'deadline': deadline,
      'applicantsCount': applicantsCount,
      'status': status,
      'isFeatured': isFeatured,
    };
  }

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      logoPath: json['logoPath'],
      companyName: json['companyName'],
      locationType: json['locationType'],
      location: json['location'],
      salaryMin: json['salaryMin'],
      salaryMax: json['salaryMax'],
      experienceLevel: json['experienceLevel'],
      requirements: List<String>.from(json['requirements'] ?? []),
      skills: List<String>.from(json['skills'] ?? []),
      employmentType: json['employmentType'],
      postedDate: json['postedDate'],
      deadline: json['deadline'],
      applicantsCount: json['applicantsCount'] ?? 0,
      status: json['status'],
      isFeatured: json['isFeatured'] ?? false,
    );
  }
}