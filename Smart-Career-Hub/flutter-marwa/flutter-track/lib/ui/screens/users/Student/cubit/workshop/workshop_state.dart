import 'package:flutter/foundation.dart';
import '../../../../../../data/models/Student/student-workshop-model.dart';

@immutable
abstract class WorkshopState {}

class WorkshopInitial extends WorkshopState {}

class WorkshopLoading extends WorkshopState {}

class WorkshopSuccess extends WorkshopState {
  final List<StudentWorkshop> myWorkshops;
  WorkshopSuccess({required this.myWorkshops});
}

class WorkshopError extends WorkshopState {
  final String message;
  WorkshopError(this.message);
}
