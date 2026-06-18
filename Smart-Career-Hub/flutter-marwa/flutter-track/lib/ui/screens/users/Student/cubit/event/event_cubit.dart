import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../data/services/EventService.dart';
import 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventService eventService;
  String? _userType;

  EventCubit([EventService? service])
      : eventService = service ?? EventService(),
        super(EventInitial());

  Future<void> loadEvents() async {
    emit(EventLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
      }
      final events = await eventService.getMyEvents(userType: _userType);
      emit(EventSuccess(myEvents: events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
