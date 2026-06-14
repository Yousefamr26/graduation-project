// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadmapRepository {
  late Dio _dio;
  static const String _baseUrl    = "http://smartcareerhub.runasp.net/api/Roadmaps";
  static const String _serverBase = "http://smartcareerhub.runasp.net";

  RoadmapRepository() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout:    const Duration(minutes: 10),
        headers: {'Accept': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('company_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          debugPrint("✅ [AUTH] Token attached: ${token.substring(0, 20)}...");
        } else {
          debugPrint("🛑 [AUTH] Warning: No token found!");
        }
        debugPrint("📤 [REQUEST] ${options.method} ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint("📥 [RESPONSE] Status: ${response.statusCode}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        debugPrint("🛑 [ERROR] Status: ${e.response?.statusCode}");
        debugPrint("🛑 [ERROR DATA]: ${e.response?.data}");
        debugPrint("🛑 [ERROR MSG]: ${e.message}");
        return handler.next(e);
      },
    ));
  }

  String? _fixImageUrl(dynamic imageUrl) {
    if (imageUrl == null) return null;
    final url = imageUrl.toString().trim();
    if (url.isEmpty || url.toLowerCase() == 'null') return null;
    final cleanUrl = url.replaceAll('\\', '/');
    if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://'))
      return cleanUrl;
    final fixedUrl = cleanUrl.startsWith('/')
        ? "$_serverBase$cleanUrl"
        : "$_serverBase/$cleanUrl";
    debugPrint("🖼️ [IMAGE URL] Fixed: $url → $fixedUrl");
    return fixedUrl;
  }

  String _getMimeType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    if (['mp4', 'avi', 'mov', 'mkv'].contains(extension)) return 'video/mp4';
    if (extension == 'pdf') return 'application/pdf';
    return 'image/jpeg';
  }

  String _toSafeDateString(DateTime date) {
    final safeDate = DateTime(date.year, date.month, date.day, 12, 0, 0);
    return safeDate.toIso8601String();
  }

  // ✅ FIX: robust AI quiz detection (matches Create_editRoadmap logic)
  bool _isAiQuiz(Map<String, dynamic> quiz) {
    final title = (quiz['title'] ?? '').toString().toLowerCase();
    if (title.startsWith('ai generated') || title.contains('ai generated'))
      return true;
    if (quiz['isAiGenerated'] == true) return true;
    if (quiz['isAi'] == true) return true;
    final source = (quiz['source'] ?? '').toString().toLowerCase();
    if (source == 'ai' || source == 'generated') return true;
    return false;
  }

  // ─── Create Roadmap ───────────────────────────────────────────
  Future<Response?> createRoadmap({
    required String title,
    required String description,
    required String targetRole,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublished,
    File? coverImage,
    List<Map<String, dynamic>> skills            = const [],
    List<Map<String, dynamic>> learningMaterials = const [],
    List<Map<String, dynamic>> projects          = const [],
    List<Map<String, dynamic>> quizzes           = const [],
    double? price,
  }) async {
    try {
      FormData formData = FormData();

      formData.fields.addAll([
        MapEntry("Title",       title),
        MapEntry("Description", description),
        MapEntry("TargetRole",  targetRole),
        MapEntry("StartDate",   _toSafeDateString(startDate)),
        MapEntry("EndDate",     _toSafeDateString(endDate)),
        MapEntry("IsPublished", isPublished.toString()),
        if (price != null) MapEntry("Price", price.toString()),
      ]);

      if (coverImage != null && coverImage.existsSync()) {
        formData.files.add(MapEntry(
          "CoverImage",
          await MultipartFile.fromFile(coverImage.path,
              filename: "cover.jpg"),
        ));
      }

      for (int i = 0; i < learningMaterials.length; i++) {
        var material = learningMaterials[i];
        formData.fields.addAll([
          MapEntry("LearningMaterialRequests[$i].Title",
              material["title"] ?? ""),
          MapEntry("LearningMaterialRequests[$i].Type",
              material["type"] ?? ""),
          MapEntry("LearningMaterialRequests[$i].Points",
              (material["points"] ?? 0).toString()),
          MapEntry("LearningMaterialRequests[$i].Duration",
              material["duration"] ?? "Medium"),
          MapEntry("LearningMaterialRequests[$i].TitlePdf",
              material["title"] ?? ""),
          MapEntry("LearningMaterialRequests[$i].Durationpdf",
              material["duration"] ?? "Medium"),
        ]);
        if (material["file"] != null && material["file"] is File) {
          File file = material["file"];
          formData.files.add(MapEntry(
            "LearningMaterialRequests[$i].FilePath",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType:
              DioMediaType.parse(_getMimeType(file.path)),
            ),
          ));
        }
      }

      for (int i = 0; i < projects.length; i++) {
        String pTitle = projects[i]["title"] ?? "";
        if (pTitle.length < 3) pTitle = "Project: $pTitle";
        formData.fields.addAll([
          MapEntry("ProjectRequests[$i].Title",       pTitle),
          MapEntry("ProjectRequests[$i].Description", projects[i]["description"] ?? ""),
          MapEntry("ProjectRequests[$i].Difficulty",  projects[i]["difficulty"]  ?? "Easy"),
          MapEntry("ProjectRequests[$i].Points",      (projects[i]["points"] ?? 5).toString()),
        ]);
      }

      _addSkillsToFormData(formData, skills);
      _addQuizFields(formData, quizzes);

      final response = await _dio.post(
        _baseUrl,
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("✅ [CREATE RESPONSE] Status: ${response.statusCode}");
      debugPrint("✅ [CREATE DATA]: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [CRITICAL ERROR in createRoadmap]: $e");
      rethrow;
    }
  }

  void _addSkillsToFormData(
      FormData formData, List<Map<String, dynamic>> skills) {
    for (int i = 0; i < skills.length; i++) {
      formData.fields.addAll([
        MapEntry("SkillRequests[$i].SkillName",
            skills[i]["name"]  ?? ""),
        MapEntry("SkillRequests[$i].Level",
            skills[i]["level"] ?? "Beginner"),
        MapEntry("SkillRequests[$i].LevelPoints",
            (skills[i]["points"] ?? 0).toString()),
      ]);
    }
  }

  /// ✅ FIX: _addQuizFields now handles AI quizzes that have 0 questions correctly.
  ///
  /// Key changes:
  /// 1. Sends quiz-level Points field for ALL quizzes (not only when > 0).
  /// 2. For AI quizzes with no questions, still sends the quiz title + points
  ///    so the backend can persist it — no questions field is sent in that case.
  /// 3. Per-question points distribution is clamped to at least 1.
  void _addQuizFields(
      FormData formData,
      List<Map<String, dynamic>> quizzes, {
        bool withIds = false,
      }) {
    for (int i = 0; i < quizzes.length; i++) {
      final quiz     = quizzes[i];
      final title    = quiz["title"]?.toString() ?? "";
      final points   = (quiz["points"] as num? ?? 0).toInt();
      List questions = quiz["questions"] ?? [];
      final isAi     = _isAiQuiz(quiz);

      debugPrint(
          "📤 [QUIZ FIELD $i] title='$title' | points=$points | "
              "questions=${questions.length} | isAi=$isAi | withIds=$withIds");

      // ── Optional: send existing ID on update ──────────────────
      if (withIds && quiz["id"] != null) {
        formData.fields
            .add(MapEntry("QuizRequests[$i].Id", quiz["id"].toString()));
      }

      // ── Quiz-level title ──────────────────────────────────────
      formData.fields
          .add(MapEntry("QuizRequests[$i].Title", title));

      // ── Quiz-level points (always send, even if 0) ────────────
      // ✅ FIX: was only sent when > 0, causing AI quiz points to be lost on edit
      formData.fields
          .add(MapEntry("QuizRequests[$i].Points", points.toString()));

      // ── Questions ─────────────────────────────────────────────
      // ✅ FIX: for AI quizzes with no questions list, skip question loop
      //    (the backend regenerates / already has them).  For manual quizzes
      //    with questions, send each question normally.
      if (questions.isEmpty) {
        // Nothing to send — the Points field above is enough for the backend.
        debugPrint(
            "⚠️ [QUIZ $i] No questions to send (AI quiz without local questions)");
        continue;
      }

      // Distribute points evenly when quiz has a total but questions don't.
      final int perQuestion = (points > 0 && questions.isNotEmpty)
          ? (points / questions.length).round().clamp(1, 9999)
          : 5;

      for (int j = 0; j < questions.length; j++) {
        final q = questions[j];

        final qPoints = (q["points"] as num?)?.toInt();
        final finalPoints =
        (qPoints != null && qPoints > 0) ? qPoints : perQuestion;

        formData.fields.addAll([
          MapEntry("QuizRequests[$i].QuestionRequests[$j].Text",
              q["text"]          ?? q["questionText"] ?? ""),
          MapEntry("QuizRequests[$i].QuestionRequests[$j].CorrectAnswer",
              q["correctAnswer"] ?? q["answer"]       ?? ""),
          MapEntry("QuizRequests[$i].QuestionRequests[$j].Points",
              finalPoints.toString()),
        ]);

        List options = q["options"] ?? _parseOptions(q["optionsJson"]);
        for (int k = 0; k < options.length; k++) {
          formData.fields.add(MapEntry(
              "QuizRequests[$i].QuestionRequests[$j].Options[$k]",
              options[k].toString()));
        }
      }
    }
  }

  // ✅ Helper: parse optionsJson whether it's a List or a JSON string
  List _parseOptions(dynamic optionsJson) {
    if (optionsJson == null) return [];
    if (optionsJson is List) return optionsJson;
    if (optionsJson is String) {
      try {
        final cleaned = optionsJson
            .replaceAll('[', '')
            .replaceAll(']', '')
            .split(',')
            .map((s) => s.trim().replaceAll('"', ''))
            .where((s) => s.isNotEmpty)
            .toList();
        return cleaned;
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  // ─── Update Roadmap ───────────────────────────────────────────
  Future<Response?> updateRoadmap({
    required String roadmapId,
    required String title,
    required String description,
    required String targetRole,
    required DateTime startDate,
    required DateTime endDate,
    required bool isPublished,
    File? coverImage,
    List<Map<String, dynamic>> skills            = const [],
    List<Map<String, dynamic>> learningMaterials = const [],
    List<Map<String, dynamic>> projects          = const [],
    List<Map<String, dynamic>> quizzes           = const [],
    double? price,
  }) async {
    try {
      FormData formData = FormData();

      formData.fields.addAll([
        MapEntry("Title",       title),
        MapEntry("Description", description),
        MapEntry("TargetRole",  targetRole),
        MapEntry("StartDate",   _toSafeDateString(startDate)),
        MapEntry("EndDate",     _toSafeDateString(endDate)),
        MapEntry("IsPublished", isPublished.toString()),
        if (price != null) MapEntry("Price", price.toString()),
      ]);

      if (coverImage != null && coverImage.existsSync()) {
        formData.files.add(MapEntry(
          "CoverImage",
          await MultipartFile.fromFile(
            coverImage.path,
            filename: coverImage.path.split('/').last,
            contentType:
            DioMediaType.parse(_getMimeType(coverImage.path)),
          ),
        ));
      }

      for (int i = 0; i < skills.length; i++) {
        if (skills[i]["id"] != null)
          formData.fields.add(MapEntry(
              "SkillRequests[$i].Id", skills[i]["id"].toString()));
        formData.fields.addAll([
          MapEntry("SkillRequests[$i].SkillName",
              skills[i]["name"]  ?? ""),
          MapEntry("SkillRequests[$i].Level",
              skills[i]["level"] ?? "Beginner"),
          MapEntry("SkillRequests[$i].LevelPoints",
              (skills[i]["points"] ?? 0).toString()),
        ]);
      }

      for (int i = 0; i < learningMaterials.length; i++) {
        if (learningMaterials[i]["id"] != null)
          formData.fields.add(MapEntry(
              "LearningMaterialRequests[$i].Id",
              learningMaterials[i]["id"].toString()));
        formData.fields.addAll([
          MapEntry("LearningMaterialRequests[$i].Title",
              learningMaterials[i]["title"]    ?? ""),
          MapEntry("LearningMaterialRequests[$i].Type",
              learningMaterials[i]["type"]     ?? ""),
          MapEntry("LearningMaterialRequests[$i].Points",
              (learningMaterials[i]["points"]  ?? 0).toString()),
          MapEntry("LearningMaterialRequests[$i].Duration",
              learningMaterials[i]["duration"] ?? "Medium"),
        ]);
        if (learningMaterials[i]["file"] != null &&
            learningMaterials[i]["file"] is File) {
          File file = learningMaterials[i]["file"];
          formData.files.add(MapEntry(
            "LearningMaterialRequests[$i].FilePath",
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
              contentType:
              DioMediaType.parse(_getMimeType(file.path)),
            ),
          ));
        }
      }

      for (int i = 0; i < projects.length; i++) {
        if (projects[i]["id"] != null)
          formData.fields.add(MapEntry(
              "ProjectRequests[$i].Id", projects[i]["id"].toString()));
        formData.fields.addAll([
          MapEntry("ProjectRequests[$i].Title",
              projects[i]["title"]       ?? ""),
          MapEntry("ProjectRequests[$i].Description",
              projects[i]["description"] ?? ""),
          MapEntry("ProjectRequests[$i].Difficulty",
              projects[i]["difficulty"]  ?? "Easy"),
          MapEntry("ProjectRequests[$i].Points",
              (projects[i]["points"] ?? 5).toString()),
        ]);
      }

      // withIds: true so existing quiz IDs are included in the PUT request
      _addQuizFields(formData, quizzes, withIds: true);

      return await _dio.put(
        "$_baseUrl/$roadmapId",
        data: formData,
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Update Roadmap Error: $e");
      rethrow;
    }
  }

  // ─── Get All Roadmaps ─────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAllRoadmaps() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("📥 [GET ALL] Status: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<Map<String, dynamic>> result = [];

        if (response.data is List) {
          result = List<Map<String, dynamic>>.from(response.data);
        } else if (response.data is Map &&
            response.data['data'] != null) {
          result =
          List<Map<String, dynamic>>.from(response.data['data']);
        }

        return result.map((roadmap) {
          final fixedUrl = _fixImageUrl(
              roadmap['coverImageUrl'] ?? roadmap['coverImage']);
          String status;
          if (roadmap['status'] != null) {
            status = roadmap['status'].toString();
          } else {
            status =
            (roadmap['isPublished'] == true) ? 'Published' : 'Draft';
          }
          debugPrint(
              "🖼️ [IMAGE] '${roadmap['title']}' → $fixedUrl | status: $status");
          return {
            ...roadmap,
            'coverImage': fixedUrl,
            'status':     status,
          };
        }).toList();
      }

      return [];
    } catch (e) {
      debugPrint("❌ Fetch Roadmaps Error: $e");
      return [];
    }
  }

  // ─── Delete Roadmap ───────────────────────────────────────────
  Future<Response?> deleteRoadmap(dynamic roadmapId) async {
    try {
      return await _dio.delete(
        "$_baseUrl/${roadmapId.toString()}",
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e) {
      debugPrint("❌ Delete Roadmap Error: $e");
      rethrow;
    }
  }

  Future<Response?> permanentlyDeleteRoadmap(dynamic roadmapId) async {
    return await deleteRoadmap(roadmapId);
  }

  // ─────────────────────────────────────────────────────────────
  // AI QUIZ ENDPOINTS
  // ─────────────────────────────────────────────────────────────

  /// POST /api/Roadmaps/{roadmapId}/generate-quiz
  Future<Response?> generateAiQuiz({
    required int roadmapId,
    required String quizType,
    required int numQuestions,
  }) async {
    try {
      final clampedNum = numQuestions.clamp(1, 5);
      debugPrint(
          "🤖 [AI QUIZ] Generating quiz for roadmap $roadmapId | "
              "Type: $quizType | Questions: $clampedNum");

      final response = await _dio.post(
        "$_baseUrl/$roadmapId/generate-quiz",
        queryParameters: {
          'quizType':     quizType,
          'numQuestions': clampedNum,
        },
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint(
          "🤖 [AI QUIZ GENERATE] Status: ${response.statusCode}");
      debugPrint("🤖 [AI QUIZ GENERATE] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [AI QUIZ GENERATE ERROR]: $e");
      rethrow;
    }
  }

  /// GET /api/Roadmaps/{roadmapId}/generated-quiz
  Future<Response?> getGeneratedQuiz(int roadmapId) async {
    try {
      debugPrint(
          "🤖 [GET QUIZ] Fetching generated quiz for roadmap $roadmapId");

      final response = await _dio.get(
        "$_baseUrl/$roadmapId/generated-quiz",
        options: Options(validateStatus: (status) => status! < 500),
      );

      debugPrint("🤖 [GET QUIZ] Status: ${response.statusCode}");
      debugPrint("🤖 [GET QUIZ] Data: ${response.data}");
      return response;
    } catch (e) {
      debugPrint("❌ [GET QUIZ ERROR]: $e");
      rethrow;
    }
  }
}