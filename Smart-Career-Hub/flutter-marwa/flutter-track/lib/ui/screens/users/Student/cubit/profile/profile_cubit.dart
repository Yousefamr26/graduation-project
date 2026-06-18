import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../data/services/ProfileService.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService profileService;

  ProfileCubit([ProfileService? service])
      : profileService = service ?? ProfileService(),
        super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userType;
      if (prefs.getString('student_token') != null) {
        userType = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        userType = 'graduate';
      }
      
      final profileData = await profileService.getProfileSummary(userType: userType);
      emit(ProfileSuccess(profileData: profileData));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
