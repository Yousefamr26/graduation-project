import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../data/services/WorkshopService.dart';
import 'workshop_state.dart';

class WorkshopCubit extends Cubit<WorkshopState> {
  final WorkshopService workshopService;
  String? _userType;

  WorkshopCubit([WorkshopService? service])
    : workshopService = service ?? WorkshopService(),
      super(WorkshopInitial());

  Future<void> loadWorkshops() async {
    emit(WorkshopLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
      }
      final workshops = await workshopService.getMyWorkshops(
        userType: _userType,
      );
      emit(WorkshopSuccess(myWorkshops: workshops));
    } catch (e) {
      emit(WorkshopError(e.toString()));
    }
  }
}
