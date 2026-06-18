import 'package:flutter/foundation.dart';
import '../../../../../../data/models/Student/student-roadmap-model.dart';

@immutable
abstract class CatalogState {}

class CatalogInitial extends CatalogState {}

class CatalogLoading extends CatalogState {}

class CatalogSuccess extends CatalogState {
  final List<StudentRoadmap> catalogRoadmaps;

  CatalogSuccess({required this.catalogRoadmaps});
}

class CatalogError extends CatalogState {
  final String message;

  CatalogError(this.message);
}
