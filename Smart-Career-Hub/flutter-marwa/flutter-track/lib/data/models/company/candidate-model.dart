class CandidateModel {
  final String id;
  final String name;
  final String email;
  final String profileImagePath;
  final String degreeLevel; // Under Graduate / Graduate
  final int skillMatchPercentage;
  final int totalPoints;
  final String roadmap;
  final bool isAIPick;
  final String status; // Scheduled, Pending, Completed, Cancelled
  final String? interviewDate;
  final String? interviewTime;

  CandidateModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profileImagePath,
    required this.degreeLevel,
    required this.skillMatchPercentage,
    required this.totalPoints,
    required this.roadmap,
    this.isAIPick = false,
    required this.status,
    this.interviewDate,
    this.interviewTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImagePath': profileImagePath,
      'degreeLevel': degreeLevel,
      'skillMatchPercentage': skillMatchPercentage,
      'totalPoints': totalPoints,
      'roadmap': roadmap,
      'isAIPick': isAIPick,
      'status': status,
      'interviewDate': interviewDate,
      'interviewTime': interviewTime,
    };
  }

  factory CandidateModel.fromJson(Map<String, dynamic> json) {
    return CandidateModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImagePath: json['profileImagePath'],
      degreeLevel: json['degreeLevel'],
      skillMatchPercentage: json['skillMatchPercentage'],
      totalPoints: json['totalPoints'],
      roadmap: json['roadmap'],
      isAIPick: json['isAIPick'] ?? false,
      status: json['status'],
      interviewDate: json['interviewDate'],
      interviewTime: json['interviewTime'],
    );
  }

  CandidateModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImagePath,
    String? degreeLevel,
    int? skillMatchPercentage,
    int? totalPoints,
    String? roadmap,
    bool? isAIPick,
    String? status,
    String? interviewDate,
    String? interviewTime,
  }) {
    return CandidateModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      degreeLevel: degreeLevel ?? this.degreeLevel,
      skillMatchPercentage: skillMatchPercentage ?? this.skillMatchPercentage,
      totalPoints: totalPoints ?? this.totalPoints,
      roadmap: roadmap ?? this.roadmap,
      isAIPick: isAIPick ?? this.isAIPick,
      status: status ?? this.status,
      interviewDate: interviewDate ?? this.interviewDate,
      interviewTime: interviewTime ?? this.interviewTime,
    );
  }
}