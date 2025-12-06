class Roadmap {
  String title;
  String description;
  List<String> target;
  String status;
  String date;
  String startDate;
  String endDate;
  List<Map<String, dynamic>> skills;
  List<Map<String, dynamic>> videos;
  List<Map<String, dynamic>> projects;
  List<Map<String, dynamic>> quizzes;
  dynamic coverImage;
  int enrolled;
  int completion;

  Roadmap({
    required this.title,
    required this.description,
    required this.target,
    this.status = "Draft",
    required this.date,
    required this.startDate,
    required this.endDate,
    this.skills = const [],
    this.videos = const [],
    this.projects = const [],
    this.quizzes = const [],
    this.coverImage,
    this.enrolled = 0,
    this.completion = 0,
  });


  factory Roadmap.fromMap(Map<String, dynamic> map) {
    return Roadmap(
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      target: List<String>.from(map['target'] ?? []),
      status: map['status'] ?? 'Draft',
      date: map['date'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      skills: List<Map<String, dynamic>>.from(map['skills'] ?? []),
      videos: List<Map<String, dynamic>>.from(map['videos'] ?? []),
      projects: List<Map<String, dynamic>>.from(map['projects'] ?? []),
      quizzes: List<Map<String, dynamic>>.from(map['quizzes'] ?? []),
      coverImage: map['coverImage'],
      enrolled: map['enrolled'] ?? 0,
      completion: map['completion'] ?? 0,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'target': target,
      'status': status,
      'date': date,
      'startDate': startDate,
      'endDate': endDate,
      'skills': skills,
      'videos': videos,
      'projects': projects,
      'quizzes': quizzes,
      'coverImage': coverImage,
      'enrolled': enrolled,
      'completion': completion,
    };
  }
}
