class CalendarEventModel {
  final String id;
  final String title;
  final String type; // Interview, Workshop, Event, Meeting, Deadline
  final DateTime date;
  final String? time;
  final String? location;
  final String? description;
  final List<String>? attendees;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    this.time,
    this.location,
    this.description,
    this.attendees,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'description': description,
      'attendees': attendees,
    };
  }

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      location: json['location'],
      description: json['description'],
      attendees: json['attendees'] != null
          ? List<String>.from(json['attendees'])
          : null,
    );
  }
}