import 'package:flutter/foundation.dart';
import '../../../../../../data/models/Student/student-roadmap-model.dart';

@immutable
abstract class RoadmapState {}

class RoadmapInitial extends RoadmapState {}

class RoadmapLoading extends RoadmapState {}

class RoadmapSuccess extends RoadmapState {
  final List<StudentRoadmap> myRoadmaps;

  RoadmapSuccess({required this.myRoadmaps});
}

class RoadmapError extends RoadmapState {
  final String message;

  RoadmapError(this.message);
}
