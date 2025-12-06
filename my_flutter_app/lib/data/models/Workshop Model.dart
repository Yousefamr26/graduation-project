import 'dart:io';
import 'package:flutter/material.dart';

class Workshop {
  String title;
  String description;
  File? coverImage;
  String? university;
  String location;
  String startDate;
  String endDate;
  String startTime;
  String endTime;
  String capacity;
  String workshopType;
  List<MaterialItem> materials;
  List<ActivityItem> activities;
  bool requireCv;
  bool requireRoadmap;
  double minProgress;

  Workshop({
    this.title = '',
    this.description = '',
    this.coverImage,
    this.university,
    this.location = '',
    this.startDate = '',
    this.endDate = '',
    this.startTime = '',
    this.endTime = '',
    this.capacity = '',
    this.workshopType = 'Online',
    List<MaterialItem>? materials,
    List<ActivityItem>? activities,
    this.requireCv = false,
    this.requireRoadmap = false,
    this.minProgress = 0,
  })  : materials = materials ?? [],
        activities = activities ?? [];
}

class MaterialItem {
  TextEditingController titleController;
  File? file;
  String? type;
  int points;
  String? fileName;

  MaterialItem({
    String initialTitle = '',
    this.file,
    this.type,
    this.points = 0,
    this.fileName,
  }) : titleController = TextEditingController(text: initialTitle);
}

class ActivityItem {
  TextEditingController titleController;
  TextEditingController descController;
  String difficulty;
  int points;

  ActivityItem({
    String initialTitle = '',
    String initialDesc = '',
    this.difficulty = 'Easy',
    this.points = 10,
  })  : titleController = TextEditingController(text: initialTitle),
        descController = TextEditingController(text: initialDesc);
}
