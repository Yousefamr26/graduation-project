class ApplicationModel {
  final String id;
  final String applicantName;
  final String email;
  final String university;
  final String major;
  final String year;
  final String position;
  final int points;
  final List<String> skills;
  final String appliedDate;
  final String status; // Under Review, Shortlisted, Interview Scheduled, Rejected, Accepted
  final String applicationType; // Internship, Job
  final String degreeLevel; // Under Graduate, Graduate
  final String? profileImagePath;

  ApplicationModel({
    required this.id,
    required this.applicantName,
    required this.email,
    required this.university,
    required this.major,
    required this.year,
    required this.position,
    required this.points,
    required this.skills,
    required this.appliedDate,
    required this.status,
    required this.applicationType,
    required this.degreeLevel,
    this.profileImagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'applicantName': applicantName,
      'email': email,
      'university': university,
      'major': major,
      'year': year,
      'position': position,
      'points': points,
      'skills': skills,
      'appliedDate': appliedDate,
      'status': status,
      'applicationType': applicationType,
      'degreeLevel': degreeLevel,
      'profileImagePath': profileImagePath,
    };
  }

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'],
      applicantName: json['applicantName'],
      email: json['email'],
      university: json['university'],
      major: json['major'],
      year: json['year'],
      position: json['position'],
      points: json['points'],
      skills: List<String>.from(json['skills'] ?? []),
      appliedDate: json['appliedDate'],
      status: json['status'],
      applicationType: json['applicationType'],
      degreeLevel: json['degreeLevel'],
      profileImagePath: json['profileImagePath'],
    );
  }

  ApplicationModel copyWith({
    String? id,
    String? applicantName,
    String? email,
    String? university,
    String? major,
    String? year,
    String? position,
    int? points,
    List<String>? skills,
    String? appliedDate,
    String? status,
    String? applicationType,
    String? degreeLevel,
    String? profileImagePath,
  }) {
    return ApplicationModel(
      id: id ?? this.id,
      applicantName: applicantName ?? this.applicantName,
      email: email ?? this.email,
      university: university ?? this.university,
      major: major ?? this.major,
      year: year ?? this.year,
      position: position ?? this.position,
      points: points ?? this.points,
      skills: skills ?? this.skills,
      appliedDate: appliedDate ?? this.appliedDate,
      status: status ?? this.status,
      applicationType: applicationType ?? this.applicationType,
      degreeLevel: degreeLevel ?? this.degreeLevel,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}