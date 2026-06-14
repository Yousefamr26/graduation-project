import 'package:flutter/material.dart';

class UniversityDashboardCardModel {
  final IconData icon;
  final String title;
  final String count;
  final String subtitle;

  UniversityDashboardCardModel({
    required this.icon,
    required this.title,
    required this.count,
    required this.subtitle,
  });
}

class UpcomingEventModel {
  final String name;
  final String type;
  final String date;
  final int participants;

  UpcomingEventModel({
    required this.name,
    required this.type,
    required this.date,
    required this.participants,
  });
}

class PartnershipModel {
  final String company;
  final String type;
  final String status;

  PartnershipModel({
    required this.company,
    required this.type,
    required this.status,
  });
}

class TopProgramModel {
  final String name;
  final int students;
  final int completion;

  TopProgramModel({
    required this.name,
    required this.students,
    required this.completion,
  });
}

class RecentWorkshopModel {
  final String name;
  final String instructor;
  final String date;

  RecentWorkshopModel({
    required this.name,
    required this.instructor,
    required this.date,
  });
}