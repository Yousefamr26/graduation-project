import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_career_hub/data/services/CatalogService.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  final CatalogService catalogService;
  String? _userType;
  String _userRole = 'student';

  CatalogCubit([CatalogService? service])
      : catalogService = service ?? CatalogService(),
        super(CatalogInitial());

  String? get userType => _userType;
  String get userRole => _userRole;

  Future<void> loadCatalog() async {
    emit(CatalogLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString('student_token') != null) {
        _userType = 'student';
        _userRole = 'student';
      } else if (prefs.getString('graduate_token') != null) {
        _userType = 'graduate';
        _userRole = 'graduate';
      }

      final catalog = await catalogService.getCatalogRoadmaps(
        userType: _userType,
        userRole: _userRole,
      );
      emit(CatalogSuccess(catalogRoadmaps: catalog));
    } catch (e) {
      emit(CatalogError(e.toString()));
    }
  }
}
