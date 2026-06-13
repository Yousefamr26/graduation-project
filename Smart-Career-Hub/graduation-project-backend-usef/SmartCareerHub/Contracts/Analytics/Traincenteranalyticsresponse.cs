namespace SmartCareerHub.Contracts.Analytics;

public record TrainCenterSummaryResponse(
    int TotalTrainees,
    double AvgAttendanceRate,
    double CompletionRate,
    double AvgScore,
    double AttendanceChangePercent,
    double CompletionChangePercent,
    double ScoreChangePercent,
    int TraineesChangePercent
);

public record TrainCenterAttendanceResponse(
    string Month,
    double Rate
);

public record TrainCenterCourseCompletionResponse(
    int RoadmapId,
    string RoadmapTitle,
    double CompletionRate,
    int TotalEnrolled,
    int TotalCompleted
);

public record TrainCenterPerformanceResponse(
    int Excellent,   // 90-100
    int Good,        // 75-89
    int Average,     // 60-74
    int BelowAverage // < 60
);

public record TrainCenterMonthlyEnrollmentResponse(
    string Month,
    int Enrolled,
    int Completed
);

public record TrainCenterAnalyticsFullResponse(
    TrainCenterSummaryResponse Summary,
    IEnumerable<TrainCenterAttendanceResponse> AttendanceOverTime,
    IEnumerable<TrainCenterCourseCompletionResponse> CourseCompletionRates,
    TrainCenterPerformanceResponse PerformanceDistribution,
    IEnumerable<TrainCenterMonthlyEnrollmentResponse> MonthlyEnrollmentVsCompletion
);