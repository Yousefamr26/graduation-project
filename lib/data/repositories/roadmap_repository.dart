import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class RoadmapRepository {
  final Dio _dio = Dio();
  static const String _baseUrl = "http://smartcareerhub.runasp.net/api/Roadmaps";

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    // Video types
    if (['mp4', 'avi', 'mov', 'mkv', 'wmv', 'flv', 'webm'].contains(extension)) {
      return 'video/$extension';
    }

    // Document types
    if (extension == 'pdf') return 'application/pdf';
    if (['doc', 'docx'].contains(extension)) {
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    }
    if (['xls', 'xlsx'].contains(extension)) {
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    }
    if (['ppt', 'pptx'].contains(extension)) {
      return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
    }

    // Image types
    if (['jpg', 'jpeg'].contains(extension)) return 'image/jpeg';
    if (extension == 'png') return 'image/png';
    if (extension == 'gif') return 'image/gif';
    if (extension == 'webp') return 'image/webp';

    // Text types
    if (extension == 'txt') return 'text/plain';

    // Default
    return 'application/octet-stream';
  }

  void _validateRequiredLists({
    required List<Map<String, dynamic>> skills,
    required List<Map<String, dynamic>> learningMaterials,
    required List<Map<String, dynamic>> projects,
    required List<Map<String, dynamic>> quizzes,
  }) {
    List<String> errors = [];

    if (skills.isEmpty) {
      errors.add("❌ Skills list cannot be empty! Add at least one skill.");
    }

    if (learningMaterials.isEmpty) {
      errors.add("❌ Learning Materials list cannot be empty! Add at least one material.");
    }

    if (projects.isEmpty) {
      errors.add("❌ Projects list cannot be empty! Add at least one project.");
    }

    if (quizzes.isEmpty) {
      errors.add("❌ Quizzes list cannot be empty! Add at least one quiz.");
    } else {
      for (int i = 0; i < quizzes.length; i++) {
        List<Map<String, dynamic>> questions = quizzes[i]["questions"] ?? [];
        bool hasPDF = quizzes[i]["pdfBytes"] != null && quizzes[i]["pdfFileName"] != null;

        if (questions.isEmpty && !hasPDF) {
          errors.add(
              "❌ Quiz '${quizzes[i]["title"] ?? "Quiz ${i + 1}"}' must have at least one question or a PDF file!"
          );
        }
      }
    }

    if (errors.isNotEmpty) {
      debugPrint("=" * 60);
      debugPrint("❌ VALIDATION FAILED:");
      for (var error in errors) {
        debugPrint(error);
      }
      debugPrint("=" * 60);
      throw Exception(errors.join("\n"));
    }

    debugPrint("✅ All required lists validation passed!");
  }

  Future<Response?> createRoadmap({
    required String title,
    required String description,
    required String targetRole,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublished,
    File? coverImage,
    List<Map<String, dynamic>> skills = const [],
    List<Map<String, dynamic>> learningMaterials = const [],
    List<Map<String, dynamic>> projects = const [],
    List<Map<String, dynamic>> quizzes = const [],
    bool isFree = true,   // ✅
    double? price,         // ✅
  }) async {
    try {
      debugPrint("=" * 60);
      debugPrint("📤 Creating Roadmap:");
      debugPrint("Title: $title");
      debugPrint("Target Role: $targetRole");
      debugPrint("Skills: ${skills.length}");
      debugPrint("Learning Materials: ${learningMaterials.length}");
      debugPrint("Projects: ${projects.length}");
      debugPrint("Quizzes: ${quizzes.length}");
      debugPrint("IsFree: $isFree");
      debugPrint("Price: $price");
      debugPrint("=" * 60);

      _validateRequiredLists(
        skills: skills,
        learningMaterials: learningMaterials,
        projects: projects,
        quizzes: quizzes,
      );

      FormData formData = FormData();

      // ====== General Info ======
      formData.fields.addAll([
        MapEntry("Title", title),
        MapEntry("Description", description),
        MapEntry("TargetRole", targetRole),
        MapEntry("StartDate", startDate.toUtc().toIso8601String()),
        MapEntry("EndDate", endDate.toUtc().toIso8601String()),
        MapEntry("IsPublished", isPublished.toString()),
        MapEntry("IsFree", isFree.toString()),                              // ✅
        if (!isFree && price != null) MapEntry("Price", price.toString()), // ✅
      ]);

      // ====== Cover Image ======
      if (coverImage != null && coverImage.existsSync()) {
        final mimeType = _getMimeType(coverImage.path);
        formData.files.add(MapEntry(
          "CoverImage",
          await MultipartFile.fromFile(
            coverImage.path,
            filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.${coverImage.path.split('.').last}',
            contentType: DioMediaType.parse(mimeType),
          ),
        ));
        debugPrint("✅ Cover Image added");
      }

      // ====== Skills ======
      debugPrint("\n📊 Processing Skills:");
      for (int i = 0; i < skills.length; i++) {
        String skillName = skills[i]["name"]?.toString().trim() ?? '';
        String level = skills[i]["level"]?.toString() ?? 'Beginner';
        String points = (skills[i]["points"] ?? 0).toString();

        debugPrint("  Skill[$i]: $skillName ($level) - $points pts");

        String? skillId = skills[i]["id"]?.toString();
        formData.fields.addAll([
          if (skillId != null && skillId.isNotEmpty)
            MapEntry("SkillRequests[$i].Id", skillId),
          MapEntry("SkillRequests[$i].SkillName", skillName),
          MapEntry("SkillRequests[$i].Level", level),
          MapEntry("SkillRequests[$i].LevelPoints", points),
        ]);
      }

      // ====== Learning Materials ======
      debugPrint("\n📚 Processing Learning Materials:");
      for (int i = 0; i < learningMaterials.length; i++) {
        var material = learningMaterials[i];

        String materialTitle = material["title"]?.toString().trim() ?? '';
        String duration = material["duration"]?.toString() ?? 'Medium';
        String type = material["type"]?.toString() ?? 'Video';
        String points = (material["points"] ?? 0).toString();

        debugPrint("  Material[$i]: $materialTitle ($type)");

        formData.fields.addAll([
          MapEntry("LearningMaterialRequests[$i].TitleVideos", materialTitle),
          MapEntry("LearningMaterialRequests[$i].Duration", duration),
          MapEntry("LearningMaterialRequests[$i].Type", type),
          MapEntry("LearningMaterialRequests[$i].Points", points),
        ]);

        if (material["file"] != null && material["file"] is File) {
          File file = material["file"];
          if (file.existsSync()) {
            final mimeType = _getMimeType(file.path);
            formData.files.add(MapEntry(
              "LearningMaterialRequests[$i].FilePath",
              await MultipartFile.fromFile(
                file.path,
                filename: '${type}_${i}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
                contentType: DioMediaType.parse(mimeType),
              ),
            ));
            debugPrint("    ✅ File attached");
          }
        }
      }

      // ====== Projects ======
      debugPrint("\n🚀 Processing Projects:");
      for (int i = 0; i < projects.length; i++) {
        debugPrint("  Project[$i]: ${projects[i]["title"]}");

        formData.fields.addAll([
          MapEntry("ProjectRequests[$i].Title", projects[i]["title"] ?? ''),
          MapEntry("ProjectRequests[$i].Description", projects[i]["description"] ?? ''),
          MapEntry("ProjectRequests[$i].Difficulty", projects[i]["difficulty"] ?? 'Easy'),
          MapEntry("ProjectRequests[$i].Points", (projects[i]["points"] ?? 0).toString()),
        ]);
      }

      // ====== Quizzes ======
      debugPrint("\n📝 Processing Quizzes:");
      for (int i = 0; i < quizzes.length; i++) {
        var quiz = quizzes[i];

        String quizTitle = quiz["title"]?.toString().trim() ?? '';
        String quizType = quiz["type"]?.toString() ?? 'MCQ';
        String quizPoints = (quiz["points"] ?? 0).toString();

        debugPrint("  Quiz[$i]: $quizTitle");

        formData.fields.addAll([
          MapEntry("QuizRequests[$i].Title", quizTitle),
          MapEntry("QuizRequests[$i].Type", quizType),
          MapEntry("QuizRequests[$i].Points", quizPoints),
        ]);

        // Attach PDF if exists
        bool hasPDF = quiz["pdfBytes"] != null && quiz["pdfFileName"] != null;
        if (hasPDF) {
          List<int> pdfBytes = quiz["pdfBytes"];
          String pdfFileName = quiz["pdfFileName"];

          formData.files.add(MapEntry(
            "QuizRequests[$i].QuestionsFile",
            MultipartFile.fromBytes(
              pdfBytes,
              filename: pdfFileName,
              contentType: DioMediaType.parse('application/pdf'),
            ),
          ));
          debugPrint("    ✅ PDF attached");
        }

        // Add Questions
        List questions = quiz["questions"] ?? [];

        if (questions.isEmpty && hasPDF) {
          questions = [
            {
              "text": "Please refer to the attached PDF for questions",
              "type": "MCQ",
              "optionsJson": jsonEncode(["See PDF"]),
              "correctAnswer": "See PDF",
            }
          ];
        }

        for (int j = 0; j < questions.length; j++) {
          var question = questions[j];

          formData.fields.addAll([
            MapEntry("QuizRequests[$i].QuestionRequests[$j].Text", question["text"] ?? ''),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].Type", question["type"] ?? 'MCQ'),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].OptionsJson", question["optionsJson"] ?? '[]'),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].CorrectAnswer", question["correctAnswer"] ?? ''),
          ]);
        }
      }

      debugPrint("\n=" * 60);
      debugPrint("📤 Sending to: $_baseUrl");
      debugPrint("=" * 60);

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(
          headers: {"Content-Type": "multipart/form-data"},
          validateStatus: (status) => true,
        ),
      );

      debugPrint("✅ Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint("✅ Roadmap created successfully!");
      } else {
        debugPrint("⚠️ Warning: Status ${response.statusCode}");
      }

      return response;

    } on DioException catch (e) {
      debugPrint("❌ DioException:");
      debugPrint("   Type: ${e.type}");
      debugPrint("   Message: ${e.message}");
      debugPrint("   Status Code: ${e.response?.statusCode}");
      debugPrint("   Response Data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      debugPrint("❌ Error creating roadmap: $e");
      rethrow;
    }
  }

  Future<Response?> updateRoadmap({
    required String roadmapId,
    required String title,
    required String description,
    required String targetRole,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublished,
    File? coverImage,
    List<Map<String, dynamic>> skills = const [],
    List<Map<String, dynamic>> learningMaterials = const [],
    List<Map<String, dynamic>> projects = const [],
    List<Map<String, dynamic>> quizzes = const [],
    bool isFree = true,   // ✅
    double? price,         // ✅
  }) async {
    try {
      debugPrint("=" * 60);
      debugPrint("🔄 Updating Roadmap ID: $roadmapId");
      debugPrint("IsFree: $isFree");
      debugPrint("Price: $price");
      debugPrint("=" * 60);

      _validateRequiredLists(
        skills: skills,
        learningMaterials: learningMaterials,
        projects: projects,
        quizzes: quizzes,
      );

      FormData formData = FormData();

      // ====== General Info ======
      formData.fields.addAll([
        MapEntry("Title", title),
        MapEntry("Description", description),
        MapEntry("TargetRole", targetRole),
        MapEntry("StartDate", startDate.toUtc().toIso8601String()),
        MapEntry("EndDate", endDate.toUtc().toIso8601String()),
        MapEntry("IsPublished", isPublished.toString()),
        MapEntry("IsFree", isFree.toString()),                              // ✅
        if (!isFree && price != null) MapEntry("Price", price.toString()), // ✅
      ]);

      // ====== Cover Image ======
      if (coverImage != null && await coverImage.exists()) {
        final mimeType = _getMimeType(coverImage.path);
        formData.files.add(MapEntry(
          'CoverImage',
          await MultipartFile.fromFile(
            coverImage.path,
            filename: 'cover_${DateTime.now().millisecondsSinceEpoch}.${coverImage.path.split('.').last}',
            contentType: DioMediaType.parse(mimeType),
          ),
        ));
        debugPrint("✅ Cover image attached");
      }

      // ====== Skills ======
      debugPrint("\n📊 Processing Skills:");
      for (int i = 0; i < skills.length; i++) {
        String? skillId = skills[i]["id"]?.toString();
        String skillName = skills[i]["name"]?.toString().trim() ?? '';
        String level = skills[i]["level"]?.toString() ?? 'Beginner';
        String points = (skills[i]["points"] ?? 0).toString();

        debugPrint("  Skill[$i]: $skillName");

        if (skillId != null && skillId.isNotEmpty) {
          formData.fields.add(MapEntry("SkillRequests[$i].Id", skillId));
        }

        formData.fields.addAll([
          MapEntry("SkillRequests[$i].SkillName", skillName),
          MapEntry("SkillRequests[$i].Level", level),
          MapEntry("SkillRequests[$i].LevelPoints", points),
        ]);
      }

      // ====== Learning Materials ======
      debugPrint("\n📚 Processing Learning Materials:");
      for (int i = 0; i < learningMaterials.length; i++) {
        var material = learningMaterials[i];

        String? materialId = material['id']?.toString();
        String materialTitle = material["title"]?.toString().trim() ?? '';
        String duration = material["duration"]?.toString() ?? 'Medium';
        String type = material["type"]?.toString() ?? 'Video';
        String points = (material["points"] ?? 0).toString();

        debugPrint("  Material[$i]: $materialTitle ($type)");

        if (materialId != null && materialId.isNotEmpty) {
          formData.fields.add(MapEntry("LearningMaterialRequests[$i].Id", materialId));
        }

        formData.fields.addAll([
          MapEntry("LearningMaterialRequests[$i].TitleVideos", materialTitle),
          MapEntry("LearningMaterialRequests[$i].Duration", duration),
          MapEntry("LearningMaterialRequests[$i].Type", type),
          MapEntry("LearningMaterialRequests[$i].Points", points),
        ]);

        if (material["file"] != null && material["file"] is File) {
          File file = material["file"];
          if (file.existsSync()) {
            final mimeType = _getMimeType(file.path);
            formData.files.add(MapEntry(
              "LearningMaterialRequests[$i].FilePath",
              await MultipartFile.fromFile(
                file.path,
                filename: '${type}_${i}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
                contentType: DioMediaType.parse(mimeType),
              ),
            ));
            debugPrint("    ✅ File attached");
          }
        }
      }

      // ====== Projects ======
      debugPrint("\n🚀 Processing Projects:");
      for (int i = 0; i < projects.length; i++) {
        debugPrint("  Project[$i]: ${projects[i]["title"]}");

        formData.fields.addAll([
          MapEntry("ProjectRequests[$i].Title", projects[i]["title"] ?? ''),
          MapEntry("ProjectRequests[$i].Description", projects[i]["description"] ?? ''),
          MapEntry("ProjectRequests[$i].Difficulty", projects[i]["difficulty"] ?? 'Easy'),
          MapEntry("ProjectRequests[$i].Points", (projects[i]["points"] ?? 0).toString()),
        ]);
      }

      // ====== Quizzes ======
      debugPrint("\n📝 Processing Quizzes:");
      for (int i = 0; i < quizzes.length; i++) {
        var quiz = quizzes[i];

        String quizTitle = quiz["title"]?.toString().trim() ?? '';
        String quizType = quiz["type"]?.toString() ?? 'MCQ';
        String quizPoints = (quiz["points"] ?? 0).toString();

        debugPrint("  Quiz[$i]: $quizTitle");

        formData.fields.addAll([
          MapEntry("QuizRequests[$i].Title", quizTitle),
          MapEntry("QuizRequests[$i].Type", quizType),
          MapEntry("QuizRequests[$i].Points", quizPoints),
        ]);

        // Attach PDF if exists
        bool hasPDF = quiz["pdfBytes"] != null && quiz["pdfFileName"] != null;
        if (hasPDF) {
          List<int> pdfBytes = quiz["pdfBytes"];
          String pdfFileName = quiz["pdfFileName"];

          formData.files.add(MapEntry(
            "QuizRequests[$i].QuestionsFile",
            MultipartFile.fromBytes(
              pdfBytes,
              filename: pdfFileName,
              contentType: DioMediaType.parse('application/pdf'),
            ),
          ));
          debugPrint("    ✅ PDF attached");
        }

        // Add questions
        List<Map<String, dynamic>> questions = List<Map<String, dynamic>>.from(quiz["questions"] ?? []);

        if (questions.isEmpty && hasPDF) {
          questions = [{
            "text": "Please refer to the attached PDF for questions",
            "type": "MCQ",
            "optionsJson": jsonEncode(["See PDF"]),
            "correctAnswer": "See PDF",
          }];
        }

        for (int j = 0; j < questions.length; j++) {
          formData.fields.addAll([
            MapEntry("QuizRequests[$i].QuestionRequests[$j].Text", questions[j]["text"] ?? ''),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].Type", questions[j]["type"] ?? 'MCQ'),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].OptionsJson", questions[j]["optionsJson"] ?? '[]'),
            MapEntry("QuizRequests[$i].QuestionRequests[$j].CorrectAnswer", questions[j]["correctAnswer"] ?? ''),
          ]);
        }
      }

      debugPrint("\n=" * 60);
      debugPrint("📤 Sending UPDATE to: $_baseUrl/$roadmapId");
      debugPrint("=" * 60);

      final response = await _dio.put(
        "$_baseUrl/$roadmapId",
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint("✅ Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint("✅ Roadmap updated successfully!");
        return response;
      } else {
        debugPrint("⚠️ Update failed: ${response.data}");
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: 'Update failed: ${response.data}',
        );
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Error updating roadmap: $e");
      debugPrint("Stack trace: $stackTrace");
      rethrow;
    }
  }

  Future<Response?> togglePublishStatus(String roadmapId) async {
    try {
      debugPrint("🔄 Toggling publish status for roadmap: $roadmapId");
      final response = await _dio.get(
        "$_baseUrl/Toggle-Publish-Status/$roadmapId",
        options: Options(validateStatus: (status) => status! < 500),
      );
      debugPrint("✅ Toggle Response Status: ${response.statusCode}");
      return response;
    } catch (e) {
      debugPrint("❌ Error toggling publish status: $e");
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getRoadmap(String roadmapId) async {
    try {
      final response = await _dio.get("$_baseUrl/$roadmapId");
      return response.data;
    } catch (e) {
      debugPrint("❌ Error fetching roadmap: $e");
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAllRoadmaps() async {
    try {
      debugPrint("📥 Fetching ALL roadmaps...");
      final response = await _dio.get(_baseUrl);

      if (response.statusCode == 200 && response.data is List) {
        List<Map<String, dynamic>> allRoadmaps = List<Map<String, dynamic>>.from(response.data);
        debugPrint("✅ Loaded ${allRoadmaps.length} roadmaps");
        return allRoadmaps;
      }

      return [];
    } catch (e) {
      debugPrint("❌ Error: $e");
      return [];
    }
  }

  Future<Response?> deleteRoadmap(dynamic roadmapId) async {
    try {
      String id = roadmapId.toString();
      debugPrint("🗑️ Deleting roadmap: $id");

      final response = await _dio.delete(
        "$_baseUrl/$id",
        options: Options(
          validateStatus: (status) => status! < 500,
          headers: {'Content-Type': 'application/json'},
        ),
      );

      debugPrint("✅ Delete Response Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 204 || response.statusCode == 404) {
        debugPrint("✅ Roadmap deleted successfully!");
        return response;
      } else {
        debugPrint("⚠️ Unexpected status: ${response.statusCode}");
        return response;
      }
    } on DioException catch (e) {
      debugPrint("❌ DioException deleting roadmap:");
      debugPrint("   Status Code: ${e.response?.statusCode}");

      if (e.response?.statusCode == 404) {
        debugPrint("   → Treating 404 as success (already deleted)");
        return e.response;
      }

      rethrow;
    } catch (e) {
      debugPrint("❌ Error deleting roadmap: $e");
      rethrow;
    }
  }

  Future<Response?> permanentlyDeleteRoadmap(dynamic roadmapId) async {
    return await deleteRoadmap(roadmapId);
  }
}