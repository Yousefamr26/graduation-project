import 'dart:io';
import 'package:dio/dio.dart';

class RoadmapApiService {

  static const String baseUrl = "https://your-api-url.com/api";
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );


  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }
  static Future<Map<String, dynamic>> createRoadmap({
    required String title,
    required String description,
    required String targetRole,
    required String startDate,
    required String endDate,
    File? coverImage,
    required List<Map<String, dynamic>> skills,
    required List<Map<String, dynamic>> videos,
    required List<Map<String, dynamic>> materials,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> quizzes,
    required String status,
  }) async {
    try {
      FormData formData = FormData();
      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('targetRole', targetRole),
        MapEntry('startDate', startDate),
        MapEntry('endDate', endDate),
        MapEntry('status', status),
      ]);
      if (coverImage != null && coverImage.existsSync()) {
        formData.files.add(MapEntry(
          'coverImage',
          await MultipartFile.fromFile(
            coverImage.path,
            filename: coverImage.path.split('/').last,
          ),
        ));
      }
      List<Map<String, dynamic>> skillsData = skills.map((skill) => {
        'name': skill['nameController']?.text ?? '',
        'level': skill['level'] ?? 'Beginner',
        'points': skill['points'] ?? 0,
      }).toList();

      for (int i = 0; i < skillsData.length; i++) {
        formData.fields.addAll([
          MapEntry('skills[$i][name]', skillsData[i]['name']),
          MapEntry('skills[$i][level]', skillsData[i]['level']),
          MapEntry('skills[$i][points]', skillsData[i]['points'].toString()),
        ]);
      }
      for (int i = 0; i < videos.length; i++) {
        var video = videos[i];

        formData.fields.addAll([
          MapEntry('videos[$i][title]', video['title'] ?? ''),
          MapEntry('videos[$i][duration]', video['duration'] ?? '1 min'),
          MapEntry('videos[$i][points]', (video['points'] ?? 0).toString()),
        ]);

        if (video['file'] != null && video['file'] is File && video['file'].existsSync()) {
          formData.files.add(MapEntry(
            'videos[$i][file]',
            await MultipartFile.fromFile(
              video['file'].path,
              filename: video['file'].path.split('/').last,
            ),
          ));
        }
      }

      for (int i = 0; i < materials.length; i++) {
        var material = materials[i];


        formData.fields.addAll([
          MapEntry('materials[$i][name]', material['name'] ?? ''),
          MapEntry('materials[$i][points]', (material['points'] ?? 0).toString()),
        ]);

        if (material['file'] != null && material['file'] is File && material['file'].existsSync()) {
          formData.files.add(MapEntry(
            'materials[$i][file]',
            await MultipartFile.fromFile(
              material['file'].path,
              filename: material['file'].path.split('/').last,
            ),
          ));
        }
      }
      List<Map<String, dynamic>> projectsData = projects.map((project) => {
        'title': project['title'] ?? '',
        'description': project['description'] ?? '',
        'difficulty': project['difficulty'] ?? 'Easy',
        'points': project['points'] ?? 0,
      }).toList();

      for (int i = 0; i < projectsData.length; i++) {
        formData.fields.addAll([
          MapEntry('projects[$i][title]', projectsData[i]['title']),
          MapEntry('projects[$i][description]', projectsData[i]['description']),
          MapEntry('projects[$i][difficulty]', projectsData[i]['difficulty']),
          MapEntry('projects[$i][points]', projectsData[i]['points'].toString()),
        ]);
      }


      for (int i = 0; i < quizzes.length; i++) {
        var quiz = quizzes[i];

        formData.fields.addAll([
          MapEntry('quizzes[$i][title]', quiz['titleController']?.text ?? ''),
          MapEntry('quizzes[$i][type]', quiz['type'] ?? 'Multiple Choice'),
          MapEntry('quizzes[$i][points]', quiz['pointsController']?.text ?? '0'),
        ]);


        if (quiz['questionsFile'] != null && quiz['questionsFile'] is File && quiz['questionsFile'].existsSync()) {
          formData.files.add(MapEntry(
            'quizzes[$i][questionsFile]',
            await MultipartFile.fromFile(
              quiz['questionsFile'].path,
              filename: quiz['questionsFile'].path.split('/').last,
            ),
          ));
        }
      }

      final response = await _dio.post(
        '/roadmaps/create',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (sent, total) {
          print('Upload Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );


      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Roadmap created successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to create roadmap',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }


  static Future<Map<String, dynamic>> updateRoadmap({
    required String roadmapId,
    required String title,
    required String description,
    required String targetRole,
    required String startDate,
    required String endDate,
    File? coverImage,
    String? existingCoverImageUrl,
    required List<Map<String, dynamic>> skills,
    required List<Map<String, dynamic>> videos,
    required List<Map<String, dynamic>> materials,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> quizzes,
    required String status,
  }) async {
    try {
      FormData formData = FormData();


      formData.fields.addAll([
        MapEntry('title', title),
        MapEntry('description', description),
        MapEntry('targetRole', targetRole),
        MapEntry('startDate', startDate),
        MapEntry('endDate', endDate),
        MapEntry('status', status),
      ]);


      if (coverImage != null && coverImage.existsSync()) {
        formData.files.add(MapEntry(
          'coverImage',
          await MultipartFile.fromFile(
            coverImage.path,
            filename: coverImage.path.split('/').last,
          ),
        ));
      } else if (existingCoverImageUrl != null) {
        formData.fields.add(MapEntry('existingCoverImage', existingCoverImageUrl));
      }


      List<Map<String, dynamic>> skillsData = skills.map((skill) => {
        'name': skill['nameController']?.text ?? '',
        'level': skill['level'] ?? 'Beginner',
        'points': skill['points'] ?? 0,
      }).toList();

      for (int i = 0; i < skillsData.length; i++) {
        formData.fields.addAll([
          MapEntry('skills[$i][name]', skillsData[i]['name']),
          MapEntry('skills[$i][level]', skillsData[i]['level']),
          MapEntry('skills[$i][points]', skillsData[i]['points'].toString()),
        ]);
      }


      for (int i = 0; i < videos.length; i++) {
        var video = videos[i];

        formData.fields.addAll([
          MapEntry('videos[$i][title]', video['title'] ?? ''),
          MapEntry('videos[$i][duration]', video['duration'] ?? '1 min'),
          MapEntry('videos[$i][points]', (video['points'] ?? 0).toString()),
        ]);


        if (video['file'] != null && video['file'] is File && video['file'].existsSync()) {
          formData.files.add(MapEntry(
            'videos[$i][file]',
            await MultipartFile.fromFile(
              video['file'].path,
              filename: video['file'].path.split('/').last,
            ),
          ));
        } else if (video['file'] is String) {

          formData.fields.add(MapEntry('videos[$i][existingFile]', video['file']));
        }
      }


      for (int i = 0; i < materials.length; i++) {
        var material = materials[i];

        formData.fields.addAll([
          MapEntry('materials[$i][name]', material['name'] ?? ''),
          MapEntry('materials[$i][points]', (material['points'] ?? 0).toString()),
        ]);

        if (material['file'] != null && material['file'] is File && material['file'].existsSync()) {
          formData.files.add(MapEntry(
            'materials[$i][file]',
            await MultipartFile.fromFile(
              material['file'].path,
              filename: material['file'].path.split('/').last,
            ),
          ));
        } else if (material['file'] is String) {
          formData.fields.add(MapEntry('materials[$i][existingFile]', material['file']));
        }
      }


      List<Map<String, dynamic>> projectsData = projects.map((project) => {
        'title': project['title'] ?? '',
        'description': project['description'] ?? '',
        'difficulty': project['difficulty'] ?? 'Easy',
        'points': project['points'] ?? 0,
      }).toList();

      for (int i = 0; i < projectsData.length; i++) {
        formData.fields.addAll([
          MapEntry('projects[$i][title]', projectsData[i]['title']),
          MapEntry('projects[$i][description]', projectsData[i]['description']),
          MapEntry('projects[$i][difficulty]', projectsData[i]['difficulty']),
          MapEntry('projects[$i][points]', projectsData[i]['points'].toString()),
        ]);
      }

      for (int i = 0; i < quizzes.length; i++) {
        var quiz = quizzes[i];

        formData.fields.addAll([
          MapEntry('quizzes[$i][title]', quiz['titleController']?.text ?? ''),
          MapEntry('quizzes[$i][type]', quiz['type'] ?? 'Multiple Choice'),
          MapEntry('quizzes[$i][points]', quiz['pointsController']?.text ?? '0'),
        ]);

        if (quiz['questionsFile'] != null && quiz['questionsFile'] is File && quiz['questionsFile'].existsSync()) {
          formData.files.add(MapEntry(
            'quizzes[$i][questionsFile]',
            await MultipartFile.fromFile(
              quiz['questionsFile'].path,
              filename: quiz['questionsFile'].path.split('/').last,
            ),
          ));
        } else if (quiz['questionsFile'] is String) {
          formData.fields.add(MapEntry('quizzes[$i][existingQuestionsFile]', quiz['questionsFile']));
        }
      }


      final response = await _dio.put(
        '/roadmaps/$roadmapId/update',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
        onSendProgress: (sent, total) {
          print('Upload Progress: ${(sent / total * 100).toStringAsFixed(0)}%');
        },
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
          'message': 'Roadmap updated successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to update roadmap',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }


  static Future<Map<String, dynamic>> getRoadmapById(String roadmapId) async {
    try {
      final response = await _dio.get('/roadmaps/$roadmapId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': response.data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch roadmap',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> deleteRoadmap(String roadmapId) async {
    try {
      final response = await _dio.delete('/roadmaps/$roadmapId');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Roadmap deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete roadmap',
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'message': _handleDioError(e),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  static String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.sendTimeout:
        return 'Send timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout. Server took too long to respond.';
      case DioExceptionType.badResponse:
        return 'Server error: ${e.response?.data?['message'] ?? e.response?.statusMessage}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      default:
        return 'Unexpected error occurred: ${e.message}';
    }
  }
}