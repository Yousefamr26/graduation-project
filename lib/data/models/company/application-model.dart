class ApplicationModel {
  final int id;
  final String applicantName;
  final String email;
  final String position;
  final String status;
  final String appliedDate;
  final String applicationType;
  final String degreeLevel;
  final int points;
  final List<String> skills;

  // Optional fields
  final String? university;
  final String? major;
  final String? year;
  final String? phoneNumber;
  final String? cvUrl;
  final String? linkedIn;
  final String? portfolio;
  final String? coverLetter;
  final String? companyName;
  final int? jobId;
  final int? internshipId; // ✅ جديد
  final String? userId;

  ApplicationModel({
    required this.id,
    required this.applicantName,
    required this.email,
    required this.position,
    required this.status,
    required this.appliedDate,
    required this.applicationType,
    required this.degreeLevel,
    required this.points,
    required this.skills,
    this.university,
    this.major,
    this.year,
    this.phoneNumber,
    this.cvUrl,
    this.linkedIn,
    this.portfolio,
    this.coverLetter,
    this.companyName,
    this.jobId,
    this.internshipId, // ✅ جديد
    this.userId,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    String mapStatus(dynamic s) {
      switch (s?.toString()) {
        case 'Applied':
          return 'Under Review';
        case 'UnderReview':
          return 'Under Review';
        case 'Shortlisted':
          return 'Shortlisted';
        case 'InterviewScheduled':
          return 'Interview Scheduled';
        case 'Accepted':
          return 'Accepted';
        case 'Rejected':
          return 'Rejected';
        default:
          return s?.toString() ?? 'Under Review';
      }
    }

    String formatDate(dynamic d) {
      if (d == null || d.toString().isEmpty) return '';
      try {
        final dt = DateTime.parse(d.toString());
        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}';
      } catch (_) {
        return d.toString().split('T')[0];
      }
    }

    return ApplicationModel(
      id: int.tryParse(
          (json['applicationId'] ?? json['id'] ?? 0).toString()) ??
          0,
      applicantName: json['applicantName']?.toString() ??
          json['name']?.toString() ??
          'Unknown',
      email: json['email']?.toString() ??
          json['applicantEmail']?.toString() ??
          '',
      position: json['jobTitle']?.toString() ??
          json['position']?.toString() ??
          json['internshipTitle']?.toString() ??
          '',
      status: mapStatus(json['status']),
      appliedDate:
      formatDate(json['appliedDate'] ?? json['applicationDate']),
      applicationType: json['applicationType']?.toString() ??
          json['_type']?.toString() ??
          'Job',
      degreeLevel: json['degreeLevel']?.toString() ??
          json['educationLevel']?.toString() ??
          'N/A',
      points: int.tryParse(
          (json['points'] ?? json['totalPoints'] ?? 0).toString()) ??
          0,
      skills: _parseSkills(json['skills'] ?? json['requiredSkills'] ?? []),
      university: json['university']?.toString() ??
          json['universityName']?.toString(),
      major: json['major']?.toString() ?? json['field']?.toString(),
      year: json['year']?.toString() ?? json['academicYear']?.toString(),
      phoneNumber:
      json['phoneNumber']?.toString() ?? json['phone']?.toString(),
      cvUrl: json['cvUrl']?.toString() ??
          json['resumeUrl']?.toString() ??
          json['cv']?.toString(),
      linkedIn:
      json['linkedIn']?.toString() ?? json['linkedInUrl']?.toString(),
      portfolio: json['portfolio']?.toString() ??
          json['portfolioUrl']?.toString(),
      coverLetter: json['coverLetter']?.toString(),
      companyName: json['companyName']?.toString(),
      jobId: int.tryParse(
          (json['jobId'] ?? json['_jobId'] ?? 0).toString()),
      internshipId: int.tryParse( // ✅ جديد
          (json['internshipId'] ?? json['_internshipId'] ?? 0).toString()),
      userId: json['userId']?.toString(),
    );
  }

  static List<String> _parseSkills(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is String && raw.isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }

  ApplicationModel copyWith({String? status}) => ApplicationModel(
    id: id,
    applicantName: applicantName,
    email: email,
    position: position,
    status: status ?? this.status,
    appliedDate: appliedDate,
    applicationType: applicationType,
    degreeLevel: degreeLevel,
    points: points,
    skills: skills,
    university: university,
    major: major,
    year: year,
    phoneNumber: phoneNumber,
    cvUrl: cvUrl,
    linkedIn: linkedIn,
    portfolio: portfolio,
    coverLetter: coverLetter,
    companyName: companyName,
    jobId: jobId,
    internshipId: internshipId, // ✅ جديد
    userId: userId,
  );
}