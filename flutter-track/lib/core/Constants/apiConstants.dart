class ApiConstants {
  ApiConstants._();

  //baseUrl
  static const String baseUrl = "http://smartcareerhub.runasp.net";

  //  ROADMAPS Endpoints
  static const String roadmaps = "$baseUrl/api/Roadmaps";
  static const String roadmapsAll = "$baseUrl/api/Roadmaps/all";
  static const String roadmapsPublished = "$baseUrl/api/Roadmaps/published";
  static const String roadmapsLatest = "$baseUrl/api/Roadmaps/latest";
  static const String roadmapsTop = "$baseUrl/api/Roadmaps/top";
  static const String roadmapsSearch = "$baseUrl/api/Roadmaps/search";
  static String roadmapById(int id) => "$baseUrl/api/Roadmaps/$id";
  static String roadmapsByTargetRole(String role) => "$baseUrl/api/Roadmaps/role/$role";
  static String roadmapTogglePublish(int id) => "$baseUrl/api/Roadmaps/$id/toggle-publish";
  static String roadmapBulkStatus(String status) => "$baseUrl/api/Roadmaps/bulk-status/$status";
  static String roadmapDelete(int id) => "$baseUrl/api/Roadmaps/$id";

  //  JOBS Endpoints
  static const String jobs = "$baseUrl/api/Jobs";
  static const String jobsSearch = "$baseUrl/api/Jobs/search";
  static const String jobsLatest = "$baseUrl/api/Jobs/latest";
  static const String jobsCount = "$baseUrl/api/Jobs/count";
  static String jobById(int id) => "$baseUrl/api/Jobs/$id";
  static String jobsByType(String type) => "$baseUrl/api/Jobs/type/$type";
  static String jobsByExperience(String level) => "$baseUrl/api/Jobs/experience/$level";
  static String jobsByLocation(String location) => "$baseUrl/api/Jobs/location/$location";
  static String jobDelete(int id) => "$baseUrl/api/Jobs/$id";
  static const String jobsBulkDelete = "$baseUrl/api/Jobs/bulk-delete";

  //  WORKSHOPS Endpoints
  static const String workshops = "$baseUrl/api/Workshops";
  static String workshopById(int id) => "$baseUrl/api/Workshops/$id";
  static String workshopTogglePublish(int id) => "$baseUrl/api/Workshops/$id/toggle-publish";
  static String workshopBulkStatus(String status) => "$baseUrl/api/Workshops/bulk-status/$status";
  static String workshopDelete(int id) => "$baseUrl/api/Workshops/$id";
  static const String workshopsBulkDelete = "$baseUrl/api/Workshops/bulk-delete";

  //  EVENTS Endpoints
  static const String events = "$baseUrl/api/Events";
  static const String eventsPublished = "$baseUrl/api/Events/published";
  static const String eventsSearch = "$baseUrl/api/Events/search";
  static const String eventsLatest = "$baseUrl/api/Events/latest";
  static String eventById(int id) => "$baseUrl/api/Events/$id";
  static String eventTogglePublish(int id) => "$baseUrl/api/Events/$id/toggle-publish";
  static String eventBulkStatus(String status) => "$baseUrl/api/Events/bulk-status/$status";
  static String eventDelete(int id) => "$baseUrl/api/Events/$id";
  static const String eventsBulkDelete = "$baseUrl/api/Events/bulk-delete";

  //  INTERVIEWS Endpoints
  static const String interviews = "$baseUrl/api/Interviews";
  static const String interviewsToday = "$baseUrl/api/Interviews/today";
  static const String interviewsSearch = "$baseUrl/api/Interviews/search";
  static const String interviewsLatest = "$baseUrl/api/Interviews/latest";
  static const String interviewsTotalCount = "$baseUrl/api/Interviews/count";
  static const String interviewsTodayCount = "$baseUrl/api/Interviews/today/count";
  static String interviewById(int id) => "$baseUrl/api/Interviews/$id";
  static String interviewsByRoadmap(int roadmapId) => "$baseUrl/api/Interviews/roadmap/$roadmapId";
  static String interviewUpdateStatus(int id, String status) => "$baseUrl/api/Interviews/$id/status/$status";
  static String interviewBulkStatus(String status) => "$baseUrl/api/Interviews/bulk-status/$status";
  static String interviewDelete(int id) => "$baseUrl/api/Interviews/$id";
  static const String interviewsBulkDelete = "$baseUrl/api/Interviews/bulk-delete";

  //  ANALYTICS Endpoints
  static const String analyticsDashboard = "$baseUrl/api/Analytics/dashboard";
  static const String analyticsRoadmaps = "$baseUrl/api/Analytics/roadmaps";
  static const String analyticsWorkshops = "$baseUrl/api/Analytics/workshops";
  static const String analyticsEvents = "$baseUrl/api/Analytics/events";
  static const String analyticsJobs = "$baseUrl/api/Analytics/jobs";
  static const String analyticsInterviews = "$baseUrl/api/Analytics/interviews";

  //  INTERNSHIPS Endpoints
  static const String internships = "$baseUrl/api/Internships";
  static String internshipById(int id) => "$baseUrl/api/Internships/$id";
  static String internshipDelete(int id) => "$baseUrl/api/Internships/$id";
  static const String internshipsSearch = "$baseUrl/api/Internships/search";
  static const String internshipsLatest = "$baseUrl/api/Internships/latest";

  //  APPLICATIONS Endpoints
  static const String applications = "$baseUrl/api/Applications";
  static String applicationById(int id) => "$baseUrl/api/Applications/$id";
  static String applicationsByJob(int jobId) => "$baseUrl/api/Applications/job/$jobId";
  static String applicationsByInternship(int internshipId) => "$baseUrl/api/Applications/internship/$internshipId";
  static String applicationUpdateStatus(int id, String status) => "$baseUrl/api/Applications/$id/status/$status";

  //  CALENDAR Endpoints (Expected)
  static const String calendar = "$baseUrl/api/Calendar";
  static String calendarByMonth(int year, int month) => "$baseUrl/api/Calendar/$year/$month";
  static String calendarByDateRange(String startDate, String endDate) => "$baseUrl/api/Calendar/range?start=$startDate&end=$endDate";

  // AUTH Endpoints
  static const String authLogin = "$baseUrl/api/Auth/login";
  static const String authRegister = "$baseUrl/api/Auth/register";
  static const String authLogout = "$baseUrl/api/Auth/logout";
  static const String authRefreshToken = "$baseUrl/api/Auth/refresh";
  static const String authProfile = "$baseUrl/api/Auth/profile";

  // USERS Endpoints
  static const String users = "$baseUrl/api/Users";
  static String userById(int id) => "$baseUrl/api/Users/$id";
  static String userDelete(int id) => "$baseUrl/api/Users/$id";



  ///////////////////////////////////////////////////////////////////
  //  HTTP Headers
  // ========================================

  /// Default JSON headers
  static Map<String, String> get jsonHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with authorization token
  static Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Headers for multipart/form-data (file uploads)
  static Map<String, String> getMultipartHeaders({String? token}) {
    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      // Note: Don't set Content-Type for multipart - Dio handles it automatically
    };
  }

  /// Image-specific headers
  static final Map<String, String> imageHeaders = {
    'Accept': 'image/*',
    'Cache-Control': 'no-cache',
  };

  // ========================================
  // ✅ Helper Methods
  // ========================================

  /// Construct full image URL from path
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.trim().isEmpty) {
      return '';
    }

    final cleanPath = imagePath.trim();

    // Already a full URL
    if (cleanPath.startsWith('http://') || cleanPath.startsWith('https://')) {
      return cleanPath;
    }

    // Add leading slash if missing
    if (cleanPath.startsWith('/')) {
      return '$baseUrl$cleanPath';
    }

    return '$baseUrl/$cleanPath';
  }

  /// Build query parameters string
  static String buildQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return '';

    final queryString = params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

    return queryString.isEmpty ? '' : '?$queryString';
  }

  // ========================================
  // ✅ Timeout Configurations
  // ========================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ========================================
  // ✅ Environment Checks
  // ========================================
  static bool get isProduction => baseUrl.startsWith('https://');
  static bool get isDevelopment => !isProduction;

  // ========================================
  // ✅ Pagination Defaults
  // ========================================
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // ========================================
  // ✅ Status Codes
  // ========================================
  static const int statusOk = 200;
  static const int statusCreated = 201;
  static const int statusNoContent = 204;
  static const int statusBadRequest = 400;
  static const int statusUnauthorized = 401;
  static const int statusForbidden = 403;
  static const int statusNotFound = 404;
  static const int statusUnprocessableEntity = 422;
  static const int statusInternalServerError = 500;
}