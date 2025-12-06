class EventModel {
  final String? id;
  final String title;
  final String description;
  final String? coverImagePath;
  final String? type;
  final String? mode;
  final String location;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final double minPoints;
  final List<String> eligibilityFilters;
  final bool inviteOnly;
  final int eligibleStudents;
  final int capacity;
  final bool allowWaitingList;
  final bool sendAutoEmail;
  final int pointsAttendance;
  final int pointsParticipation;
  final String status; // "Draft", "Published", "Completed", "Cancelled"
  final String date;

  EventModel({
    this.id,
    required this.title,
    required this.description,
    this.coverImagePath,
    this.type,
    this.mode,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    this.minPoints = 0,
    this.eligibilityFilters = const [],
    this.inviteOnly = false,
    this.eligibleStudents = 0,
    this.capacity = 0,
    this.allowWaitingList = false,
    this.sendAutoEmail = false,
    this.pointsAttendance = 0,
    this.pointsParticipation = 0,
    this.status = "Draft",
    required this.date,
  });

  // Convert from Map (e.g., from API/Database)
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id']?.toString(),
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      coverImagePath: map['coverImagePath'],
      type: map['type'],
      mode: map['mode'],
      location: map['location'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      minPoints: (map['minPoints'] ?? 0).toDouble(),
      eligibilityFilters: List<String>.from(map['eligibilityFilters'] ?? []),
      inviteOnly: map['inviteOnly'] ?? false,
      eligibleStudents: map['eligibleStudents'] ?? 0,
      capacity: map['capacity'] ?? 0,
      allowWaitingList: map['allowWaitingList'] ?? false,
      sendAutoEmail: map['sendAutoEmail'] ?? false,
      pointsAttendance: map['pointsAttendance'] ?? 0,
      pointsParticipation: map['pointsParticipation'] ?? 0,
      status: map['status'] ?? 'Draft',
      date: map['date'] ?? '',
    );
  }

  // Convert to Map (e.g., for API/Database)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'coverImagePath': coverImagePath,
      'type': type,
      'mode': mode,
      'location': location,
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'minPoints': minPoints,
      'eligibilityFilters': eligibilityFilters,
      'inviteOnly': inviteOnly,
      'eligibleStudents': eligibleStudents,
      'capacity': capacity,
      'allowWaitingList': allowWaitingList,
      'sendAutoEmail': sendAutoEmail,
      'pointsAttendance': pointsAttendance,
      'pointsParticipation': pointsParticipation,
      'status': status,
      'date': date,
    };
  }

  // Convert to JSON (for API)
  Map<String, dynamic> toJson() => toMap();

  // Convert from JSON (for API)
  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel.fromMap(json);

  // Create a copy with modified fields
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImagePath,
    String? type,
    String? mode,
    String? location,
    String? startDate,
    String? endDate,
    String? startTime,
    String? endTime,
    double? minPoints,
    List<String>? eligibilityFilters,
    bool? inviteOnly,
    int? eligibleStudents,
    int? capacity,
    bool? allowWaitingList,
    bool? sendAutoEmail,
    int? pointsAttendance,
    int? pointsParticipation,
    String? status,
    String? date,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      type: type ?? this.type,
      mode: mode ?? this.mode,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      minPoints: minPoints ?? this.minPoints,
      eligibilityFilters: eligibilityFilters ?? this.eligibilityFilters,
      inviteOnly: inviteOnly ?? this.inviteOnly,
      eligibleStudents: eligibleStudents ?? this.eligibleStudents,
      capacity: capacity ?? this.capacity,
      allowWaitingList: allowWaitingList ?? this.allowWaitingList,
      sendAutoEmail: sendAutoEmail ?? this.sendAutoEmail,
      pointsAttendance: pointsAttendance ?? this.pointsAttendance,
      pointsParticipation: pointsParticipation ?? this.pointsParticipation,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'EventModel(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EventModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
