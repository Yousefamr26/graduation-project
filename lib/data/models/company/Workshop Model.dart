class Workshop {
  final String id;
  final String title;
  final String description;
  final String universityId; // خزنا ID بس
  final int capacity;
  final String status;
  final String? coverImagePath;
  final String location;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String workshopType; // Online / Onsite / Hybrid
  final bool requireCv;
  final bool requireRoadmap;
  final double minimumProgress;
  final List<MaterialItem> materials;
  final List<ActivityItem> activities;

  Workshop({
    required this.id,
    required this.title,
    required this.description,
    required this.universityId,
    required this.capacity,
    required this.status,
    this.coverImagePath,
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.startTime = '',
    this.endTime = '',
    this.workshopType = 'Online',
    this.requireCv = false,
    this.requireRoadmap = false,
    this.minimumProgress = 0,
    List<MaterialItem>? materials,
    List<ActivityItem>? activities,
  })  : materials = materials ?? [],
        activities = activities ?? [];
}

class MaterialItem {
  final String title;
  final String? fileName;
  final int points;

  MaterialItem({
    required this.title,
    this.fileName,
    this.points = 0,
  });
}

class ActivityItem {
  final String title;
  final String description;
  final int points;
  final String difficulty;

  ActivityItem({
    required this.title,
    required this.description,
    this.points = 10,
    this.difficulty = 'Easy',
  });
}