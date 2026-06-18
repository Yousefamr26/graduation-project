import 'package:flutter/foundation.dart';
import '../../../../../../data/models/Student/student-event-model.dart';

@immutable
abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventSuccess extends EventState {
  final List<StudentEvent> myEvents;
  EventSuccess({required this.myEvents});
}

class EventError extends EventState {
  final String message;
  EventError(this.message);
}
