import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_career_hub/data/services/RoadmapService.dart';
import '../../../../../../data/models/Student/student-roadmap-model.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  final RoadmapService roadmapService;
  String? _userType;
  String _userRole = 'student';

  RoadmapCubit([RoadmapService? service])
    : roadmapService = service ?? RoadmapService(),
      super(RoadmapInitial());

  String? get userType => _userType;
  String get userRole => _userRole;

  Future<void> loadRoadmaps() async {
    emit(RoadmapLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
        _userRole = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
        _userRole = 'graduate';
      }

      final myRoadmaps = await roadmapService
          .getMyRoadmaps(userType: _userType, userRole: _userRole)
          .catchError((_) => <StudentRoadmap>[]);
      log(myRoadmaps.map((e) => e.toMap()['id']).toList().toString());
      emit(RoadmapSuccess(myRoadmaps: myRoadmaps));
    } catch (e) {
      emit(RoadmapError(e.toString()));
    }
  }

  Future<void> enroll(dynamic id) async {
    try {
      await roadmapService.enrollRoadmap(
        id,
        userType: _userType,
        userRole: _userRole,
      );
      await loadRoadmaps();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unenroll(dynamic id) async {
    try {
      await roadmapService.unenrollRoadmap(
        id,
        userType: _userType,
        userRole: _userRole,
      );
      await loadRoadmaps();
    } catch (e) {
      rethrow;
    }
  }
}
